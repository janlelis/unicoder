module Unicoder
  module Builder
    class DisplayWidth
      include Builder
      include MultiDimensionalArrayBuilder

      ZERO_WIDTH_CATEGORIES = %w[Mn Me Cf].freeze

      ZERO_WIDTH_HANGUL = [
        *0x1160..0x11FF, # HANGUL JUNGSEONG
        *0xD7B0..0xD7FF, # HANGUL JUNGSEONG
      ].freeze

      WIDE_RANGES = [
        *0x3400..0x4DBF,
        *0x4E00..0x9FFF,
        *0xF900..0xFAFF,
        *0x20000..0x2FFFD,
        *0x30000..0x3FFFD,
      ].freeze

      SPECIAL_WIDTHS = {
        0x0    =>  0, # \0 NULL
        0x5    =>  0, #    ENQUIRY
        0x7    =>  0, # \a BELL
        0x8    => -1, # \b BACKSPACE
        0xA    =>  0, # \n LINE FEED
        0xB    =>  0, # \v LINE TABULATION
        0xC    =>  0, # \f FORM FEED
        0xD    =>  0, # \r CARRIAGE RETURN
        0xE    =>  0, #    SHIFT OUT
        0xF    =>  0, #    SHIFT IN
        0x00AD =>  nil, #    SOFT HYPHEN, nil = 1 (default)
        0x2E3A =>  2, #    TWO-EM DASH
        0x2E3B =>  3, #    THREE-EM DASH
      }.freeze

      def initialize_index
        @index = {
          WIDTH_ONE: [],
          WIDTH_TWO: [],
        }
        @ignorable = []
      end

      def parse!
        # Find Ignorables
        parse_file :core_properties, :line, begin: /^# Derived Property: Default_Ignorable_Code_Point$/, end: /^# ================================================$/, regex: /^(?<codepoints>\S+)\s+; Default_Ignorable_Code_Point.*$/ do |line|
          if line["codepoints"]['..']
            single_or_multiple_codepoints = Range.new(*line["codepoints"].split('..').map{ |codepoint|
              codepoint.to_i(16)
            })
          else
            single_or_multiple_codepoints = line["codepoints"].to_i(16)
          end

          @ignorable += [*single_or_multiple_codepoints]
        end

        # Assign based on East Asian Width
        parse_file :east_asian_width, :line, regex: /^(?<codepoints>\S+?)\s*;\s*(?<width>\S+)\s+#\s(?<category>\S+).*$/ do |line|
          if line["codepoints"]['..']
            codepoints = Range.new(*line["codepoints"].split('..').map{ |codepoint|
              codepoint.to_i(16)
            })
          else
            codepoints = [line["codepoints"].to_i(16)]
          end

          codepoints.each{ |codepoint|
            assign :WIDTH_ONE, codepoint, determine_width(codepoint, line["category"], line["width"], 1)
            assign :WIDTH_TWO, codepoint, determine_width(codepoint, line["category"], line["width"], 2)
          }
        end

        # Assign Ranges
        ## Zero-width
        (ZERO_WIDTH_HANGUL | @ignorable).each{ |codepoint|
          assign :WIDTH_ONE, codepoint, 0
          assign :WIDTH_TWO, codepoint, 0
        }

        ## Full-width
        WIDE_RANGES.each{ |codepoint|
          assign :WIDTH_ONE, codepoint, 2
          assign :WIDTH_TWO, codepoint, 2
        }

        ## Table
        SPECIAL_WIDTHS.each{ |codepoint, value|
          assign :WIDTH_ONE, codepoint, value
          assign :WIDTH_TWO, codepoint, value
        }

        # Compres Index
        4.times{ compress! @index[:WIDTH_ONE] }
        4.times{ compress! @index[:WIDTH_TWO] }
      end

      def determine_width(codepoint, category, east_asian_width, ambiguous)
        if  ( ZERO_WIDTH_CATEGORIES.include?(category) &&
              [codepoint].pack('U') !~ /\p{Cf}(?<=\p{Arabic})/ )
          0
        elsif east_asian_width == "F" || east_asian_width == "W"
          2
        elsif east_asian_width == "A"
          ambiguous == 1 ? nil : ambiguous
        else
          nil
        end
      end
    end
  end
end
