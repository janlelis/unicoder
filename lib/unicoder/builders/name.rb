module Unicoder
  module Builder
    class Name
      include Builder

      def initialize_index
        @index = {
          NAMES: {},
          ALIASES: {},
        }
      end

      def parse!
        parse_file :unicode_data, :line, regex: /^(?<codepoint>.+?);(?<name>.+?);.*$/ do |line|
          unless line["name"][0] == "<" && line["name"][-1] == ">"
            assign_codepoint line["codepoint"].to_i(16), line["name"], @index[:NAMES]
          end
        end

        parse_file :name_aliases, :line, regex: /^(?<codepoint>.+?);(?<alias>.+?);(?<type>.*)$/ do |line|
          @index[:ALIASES][line["codepoint"].to_i(16)] ||= {}
          @index[:ALIASES][line["codepoint"].to_i(16)][line["type"].to_sym] ||= []
          @index[:ALIASES][line["codepoint"].to_i(16)][line["type"].to_sym] << line["alias"]
        end

        p @index
      end
    end
  end
end

