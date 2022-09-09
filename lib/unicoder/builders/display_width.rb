module Unicoder
  module Builder
    class DisplayWidth
      include Builder
      include MultiDimensionalArrayBuilder

      IGNORE_CATEGORIES     = %w[Cs Co Cn].freeze
      ZERO_WIDTH_CATEGORIES = %w[Mn Me Cf].freeze

      ZERO_WIDTH_RANGES = [
        *0x1160..0x11FF, # HANGUL JUNGSEONG
        *0xD7B0..0xD7FF, # HANGUL JUNGSEONG
        *0x2060..0x206F, # Ignorables
        *0xFFF0..0xFFF8, # Ignorables
        *0xE0000..0xE0FFF, # Ignorables
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
        0x00AD =>  1, #    SOFT HYPHEN
        0x2E3A =>  2, #    TWO-EM DASH
        0x2E3B =>  3, #    THREE-EM DASH
      }.freeze

      def initialize_index
        @index = []
      end

      def parse!
        parse_file :east_asian_width, :line, regex: /^(?<codepoints>\S+?);(?<width>\S+)\s+#\s(?<category>\S+).*$/ do |line|
          next if IGNORE_CATEGORIES.include?(line["category"])

          if line["codepoints"]['..']
            codepoints = Range.new(*line["codepoints"].split('..').map{ |codepoint|
              codepoint.to_i(16)
            })
          else
            codepoints = [line["codepoints"].to_i(16)]
          end

          codepoints.each{ |codepoint|
            assign_codepoint codepoint, determine_width(codepoint, line["category"], line["width"])
          }
        end

        ZERO_WIDTH_RANGES.each{ |codepoint|
          assign_codepoint codepoint, 0
        }

        WIDE_RANGES.each{ |codepoint|
          assign_codepoint codepoint, 2
        }

        SPECIAL_WIDTHS.each{ |codepoint, value|
          assign_codepoint codepoint, value
        }

        4.times{ compress! }
      end

      def determine_width(codepoint, category, east_asian_width)
        if  ( ZERO_WIDTH_CATEGORIES.include?(category) &&
              [codepoint].pack('U') !~ /\p{Cf}(?<=\p{Arabic})/ )
          0
        elsif east_asian_width == "F" || east_asian_width == "W"
          2
        elsif east_asian_width == "A"
          :A
        else
          nil
        end
      end
    end
  end
end
