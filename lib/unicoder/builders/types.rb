module Unicoder
  module Builder
    class Types
      include Builder
      include MultiDimensionalArrayBuilder

      NONCHARACTERS = [
          *0xFDD0..0xFDEF,
          0xFFFE,  0xFFFF,
         0x1FFFE, 0x1FFFF,
         0x2FFFE, 0x2FFFF,
         0x3FFFE, 0x3FFFF,
         0x4FFFE, 0x4FFFF,
         0x5FFFE, 0x5FFFF,
         0x6FFFE, 0x6FFFF,
         0x7FFFE, 0x7FFFF,
         0x8FFFE, 0x8FFFF,
         0x9FFFE, 0x9FFFF,
         0xAFFFE, 0xAFFFF,
         0xBFFFE, 0xBFFFF,
         0xCFFFE, 0xCFFFF,
         0xDFFFE, 0xDFFFF,
         0xEFFFE, 0xEFFFF,
         0xFFFFE, 0xFFFFF,
        0x10FFFE, 0x10FFFF,
      ]

      def initialize_index
        @index = {
          TYPES: [],
          TYPE_NAMES: %w[
            Graphic
            Format
            Control
            Private-use
            Surrogate
            Noncharacter
            Reserved
          ],
        }
      end

      def parse!
        parse_file :general_categories, :line, regex: /^(?<from>[^. ]+)(?:..(?<to>\S+))?\s*; (?<category>\S+).*$/ do |line|
          if line["to"]
            codepoints = Range.new(line["from"].to_i(16), line["to"].to_i(16))
          else
            codepoints = [line["from"].to_i(16)]
          end

          codepoints.each{ |codepoint|
            case line["category"]
            when "Cf", "Zl", "Zp"
              type = 1
            when "Cc"
              type = 2
            when "Co"
              type = 3
            when "Cs"
              type = 4
            when "Cn"
              if NONCHARACTERS.include?(codepoint)
                type = 5
              else
                type = 6
              end
            end
            
            assign_codepoint codepoint, type, @index[:TYPES]
          }
        end

        4.times{ compress! @index[:TYPES] }
      end
    end
  end
end
