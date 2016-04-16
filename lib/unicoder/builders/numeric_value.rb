module Unicoder
  module Builder
    class NumericalValue
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

        p @index
      end
    end
  end
end
