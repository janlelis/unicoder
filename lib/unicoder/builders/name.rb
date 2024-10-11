module Unicoder
  module Builder
    class Name

      include Builder
      include ReplaceCommonWords

      JAMO_INITIAL = 4352
      JAMO_MEDIAL = 4449
      JAMO_FINAL = 4520
      JAMO_END = 4697

      CJK = "CJK UNIFIED IDEOGRAPH-"
      TANGUT = "TANGUT IDEOGRAPH-"

      REPLACE_COUNT = 500
      REPLACE_BASE = ?[.ord

      def initialize_index
        @index = {
          NAMES: {},
          ALIASES: {},
          # HANGUL: [],
          CP_RANGES: {
            CJK => [], # filled while parsing
            TANGUT => [], # filled while parsing
            "EGYPTIAN HIEROGLYPH-" => [[0x13460, 0x143FA]],
            "KHITAN SMALL SCRIPT CHARACTER-" => [[0x18B00, 0x18CFF]],
            "NUSHU CHARACTER-" => [[0x1B170, 0x1B2FB]],
            "CJK COMPATIBILITY IDEOGRAPH-" => [[0x2F800, 0x2FA1D]],
          },
          # see https://en.wikipedia.org/wiki/Korean_language_and_computers#Hangul_Syllables_Area
          JAMO: {
            INITIAL: [],
            MEDIAL: [],
            FINAL: [""],
          },
        }
        @words = []
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
              case line["name"]
              when /Hangul/
                # currently not necessary
                # @index[:HANGUL] << [@range_start, line["codepoint"].to_i(16)]
              when /CJK/
                @index[:CP_RANGES][CJK] << [@range_start, line["codepoint"].to_i(16)]
              when /Tangut/
                @index[:CP_RANGES][TANGUT] << [@range_start, line["codepoint"].to_i(16)]
              else
                # no name
                warn "ignoring range: #{line["name"]}"
              end
              @range_start = nil
            elsif line["name"] != "<control>"
              raise ArgumentError, "inconsistent range found in data, don't know what to do"
            end
          elsif line["name"] =~ Regexp.union(@index[:CP_RANGES].keys.map{/^#{_1}/})
            # ignore
          else
            assign :NAMES, line["codepoint"].to_i(16), line["name"]
            @words += line["name"].split
          end
        end

        replace_common_words! :NAMES, @words, REPLACE_COUNT, REPLACE_BASE

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

