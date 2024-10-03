module Unicoder
  module Builder
    class Name
      include Builder

      JAMO_INITIAL = 4352
      JAMO_MEDIAL = 4449
      JAMO_FINAL = 4520
      JAMO_END = 4697

      def initialize_index
        @index = {
          NAMES: {},
          ALIASES: {},
          CJK: [],
          HANGUL: [],
          # see https://en.wikipedia.org/wiki/Korean_language_and_computers#Hangul_Syllables_Area
          JAMO: {
            INITIAL: [],
            MEDIAL: [],
            FINAL: [""],
          },
        }
        @range_start = nil
      end

      def parse!
        if option =~ /charkeys/
          get_key = ->(codepoint){ [codepoint].pack("U*") }
        else
          get_key = -> (codepoint){ codepoint }
        end

        parse_file :unicode_data, :line, regex: /^(?<codepoint>.+?);(?<name>.+?);.*$/ do |line|
          if line["name"][0] == "<" && line["name"][-1] == ">"
            if line["name"] =~ /First/
              @range_start = line["codepoint"].to_i(16)
            elsif line["name"] =~ /Last/ && @range_start
              if line["name"] =~ /Hangul/
                @index[:HANGUL] << [@range_start, line["codepoint"].to_i(16)]
              elsif line["name"] =~ /CJK/
                @index[:CJK] << [@range_start, line["codepoint"].to_i(16)]
              else
                # no name
              end
              @range_start = nil
            elsif line["name"] != "<control>"
              raise ArgumentError, "inconsistent range found in data, don't know what to do"
            end
          else
            assign :NAMES, line["codepoint"].to_i(16), line["name"]
          end
        end

        parse_file :name_aliases, :line, regex: /^(?<codepoint>.+?);(?<alias>.+?);(?<type>.*)$/ do |line|
          @index[:ALIASES][get_key[line["codepoint"].to_i(16)]] ||= {}
          @index[:ALIASES][get_key[line["codepoint"].to_i(16)]][line["type"].to_sym] ||= []
          @index[:ALIASES][get_key[line["codepoint"].to_i(16)]][line["type"].to_sym] << line["alias"]
        end

        parse_file :jamo, :line, regex: /^(?<codepoint>.+?); (?<short_name>.*?) +#.*$/ do |line|
          case line["codepoint"].to_i(16)
          when JAMO_INITIAL...JAMO_MEDIAL
            @index[:JAMO][:INITIAL] << line["short_name"]
          when JAMO_MEDIAL...JAMO_FINAL
            @index[:JAMO][:MEDIAL] << line["short_name"]
          when JAMO_FINAL..JAMO_END
            @index[:JAMO][:FINAL] << line["short_name"]
          end
        end
      end
    end
  end
end

