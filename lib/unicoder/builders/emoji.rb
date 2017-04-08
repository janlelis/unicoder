module Unicoder
  module Builder
    class Emoji
      include Builder

      REVERSE_PROPERTY_NAMES = {
        "Emoji_Modifier_Base" => :B,
        "Emoji_Modifier" => :M,
        "Emoji_Component" => :C,
        "Emoji_Presentation" => :P,
      }

      def initialize_index
        @index = {
          PROPERTIES: {},
          FLAGS: [],
          TAGS: [],
          KEYCAPS: [],
          ZWJ: [],
          SD: [],
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
              @index[:PROPERTIES][codepoint] << REVERSE_PROPERTY_NAMES[line["property"]] || line["property"]
            end
          }
        end

        parse_file :emoji_sequences, :line, regex: /^(?<codepoints>.+?)\s*; Emoji_Flag_Sequence/ do |line|
          codepoints = line["codepoints"].split
          @index[:FLAGS] << codepoints.map{|e| e.to_i(16)}
        end

        parse_file :emoji_sequences, :line, regex: /^(?<codepoints>.+?)\s*; Emoji_Tag_Sequence/ do |line|
          codepoints = line["codepoints"].split
          @index[:TAGS] << codepoints.map{|e| e.to_i(16)}
        end

        parse_file :emoji_sequences, :line, regex: /^(?<codepoints>.+?)\s*; Emoji_Keycap_Sequence/ do |line|
          @index[:KEYCAPS] << line["codepoints"].split[0].to_i(16)
        end

        parse_file :emoji_zwj_sequences, :line, regex: /^(?!#)(?<codepoints>.+?)\s*;/ do |line|
          codepoints = line["codepoints"].split
          @index[:ZWJ] << codepoints.map{|e| e.to_i(16)}
        end

        parse_file :valid_subdivisions, :xml do |xml|
          subdivisions = []
          xml.css('[idStatus="regular"], [idStatus="deprecated"]').each{ |id|
            subdivisions += id.text.split
          }
          @index[:SD] = subdivisions.uniq
        end
      end
    end
  end
end

=begin alternative
current_index_level = @index[:SEQUENCES]
codepoints.each{ |cp|
  ord = cp.to_i(16)
  current_index_level[ord] ||= {}
  current_index_level = current_index_level[ord]
}
current_index_level[true] = true # end mark
=end