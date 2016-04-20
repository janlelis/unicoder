module Unicoder
  module Builder
    class NumericValue
      include Builder

      def initialize_index
        @index = {}
      end

      def parse!
        parse_file :unicode_data, :line, regex: /^(?<codepoint>.+?);(.*?;){7}(?<value>.*?);.*$/ do |line|
          unless line["value"].empty?
            if line["value"] =~ %r</>
              @index[line["codepoint"].to_i(16)] = line["value"].to_r
            else
              @index[line["codepoint"].to_i(16)] = line["value"].to_i
            end
          end
        end

        parse_file :unihan_numeric_values, :line, regex: /^U\+(?<codepoint>\S+)\s+\S+\s+(?<value>\S+)$/ do |line|
          @index[line["codepoint"].to_i(16)] = line["value"].to_i
        end
      end
    end
  end
end
