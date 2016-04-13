module Unicoder
  module Builder
    # Assigns categories to every codepoint using a multi dimensional Array index structure
    class Categories
      include Builder
      include MultiDimensionalArrayBuilder

      def initialize_index
        @index = {
          CATEGORIES: [],
          CATEGORY_NAMES: {},
        }
        @range_start = nil
      end

      def parse!
        parse_file :unicode_data, :line, regex: /^(?<codepoint>.+?);(?<range><(?!control).+>)?.*?;(?<category>.+?);.*$/ do |line|
          if line["range"]
            if line["range"] =~ /First/
              @range_start = line["codepoint"].to_i(16)
            elsif line["range"] =~ /Last/ && @range_start
              (@range_start..line["codepoint"].to_i(16)).each{ |codepoint|
                assign_codepoint(codepoint, line["category"], @index[:CATEGORIES])
              }
            else
              raise ArgumentError, "inconsistent range found in data, don't know what to do"
            end
          else
            assign_codepoint(line["codepoint"].to_i(16), line["category"], @index[:CATEGORIES])
          end
        end

        4.times{ compress! @index[:CATEGORIES] }

        parse_file :property_value_aliases, :line, regex: /^gc ; (?<short>\S{2}?) *; (?<long>\S+).*$/ do |line|
          @index[:CATEGORY_NAMES][line["short"]] = line["long"]
        end

        @index
      end
    end
  end
end
