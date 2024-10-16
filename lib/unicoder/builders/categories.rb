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
          OFFSETS: [
            0x10000,
            0x1000,
            0x100,
            0x10
          ],
        }
        @range_start = nil
      end

      def parse!
        parse_file :general_categories, :line, regex: /^(?<from>[^. ]+)(?:..(?<to>\S+))?\s*; (?<category>\S+).*$/ do |line|
          if line["to"]
            (line["from"].to_i(16)..line["to"].to_i(16)).each{ |codepoint|
              assign_codepoint(codepoint, line["category"] == "Cn" ? nil : line["category"], @index[:CATEGORIES])
            }
          else
            assign_codepoint(line["from"].to_i(16), line["category"] == "Cn" ? nil : line["category"], @index[:CATEGORIES])
          end
        end

        4.times{ compress! @index[:CATEGORIES] }
        remove_trailing_nils! @index[:CATEGORIES]

        parse_file :property_value_aliases, :line, regex: /^gc ; (?<short>\S{2}?) *; (?<long>\S+).*$/ do |line|
          @index[:CATEGORY_NAMES][line["short"]] = line["long"]
        end

        @index
      end
    end
  end
end
