module Unicoder
  module Builder
    class Name
      include Builder

      def initialize_index
        @index = {
          NAMES: {},
          ALIASES: {},
          CJK: [],
          HANGUL: [],
        }
        @range_start = nil
      end

      def parse!
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
            assign_codepoint line["codepoint"].to_i(16), line["name"], @index[:NAMES]
          end
        end

        parse_file :name_aliases, :line, regex: /^(?<codepoint>.+?);(?<alias>.+?);(?<type>.*)$/ do |line|
          @index[:ALIASES][line["codepoint"].to_i(16)] ||= {}
          @index[:ALIASES][line["codepoint"].to_i(16)][line["type"].to_sym] ||= []
          @index[:ALIASES][line["codepoint"].to_i(16)][line["type"].to_sym] << line["alias"]
        end
      end
    end
  end
end

