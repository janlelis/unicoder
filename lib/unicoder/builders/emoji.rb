module Unicoder
  module Builder
    class Emoji
      include Builder

      def initialize_index
        @index = {
          PROPERTIES: {},
          SEQUENCES: {},
        }
      end

      def parse!
        parse_file :emoji, :line, regex: /^(?<codepoints>\S+?) +; (?<property>\S+) +#/ do |line|
          if line["codepoints"]['..']
            codepoints = Range.new(*line["codepoints"].split('..').map{ |codepoint|
              codepoint.to_i(16)
            })
          else
            codepoints = [line["codepoints"].to_i(16)]
          end

          codepoints.each{ |codepoint|
            if line["property"] == "Emoji"
              @index[:PROPERTIES][codepoint] = []
            else
              @index[:PROPERTIES][codepoint] << line["property"].sub(/^Emoji_/, "")
            end
          }
        end

        [
          :emoji_sequences,
          # :emoji_variation_sequences,
          :emoji_zwj_sequences,
        ].each{ |file|
          parse_file file, :line, regex: /^(?<codepoints>.+?)\s*;/ do |line|
            codepoints = line["codepoints"].split
            # @index[:SEQUENCES] << codepoints.map{|e| e.to_i(16 )}
            current_index_level = @index[:SEQUENCES]
            codepoints.each{ |cp|
              ord = cp.to_i(16)
              current_index_level[ord] ||= {}
              current_index_level = current_index_level[ord]
            }
            current_index_level[true] = true # end mark
          end
        }
      end
    end
  end
end
