module Unicoder
  module Builder
    class Emoji
      include Builder

      REVERSE_PROPERTY_NAMES = {
        "Emoji" => :E,
        "Emoji_Modifier_Base" => :B,
        "Emoji_Modifier" => :M,
        "Emoji_Component" => :C,
        "Emoji_Presentation" => :P,
        "Extended_Pictographic" => :X,
      }

      def initialize_index
        @index = {
          PROPERTIES: {},
          FLAGS: [],
          TAGS: [],
          KEYCAPS: [],
          ZWJ: [],
          SD: [],
          LIST: {},
        }
      end

      def parse!
        parse_file :emoji_data, :line, regex: /^(?<codepoints>\S+?) +; (?<property>\S+) +#/ do |line|
          if line["codepoints"]['..']
            codepoints = Range.new(*line["codepoints"].split('..').map{ |codepoint|
              codepoint.to_i(16)
            })
          else
            codepoints = [line["codepoints"].to_i(16)]
          end

          codepoints.each{ |codepoint|
            @index[:PROPERTIES][codepoint] ||= []
            @index[:PROPERTIES][codepoint] << (REVERSE_PROPERTY_NAMES[line["property"]] || line["property"])
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

        parse_file :emoji_test, :line, regex: /^(?:# (?<sub>sub)?group: (?<group_name>.*)$)|(?:(?<codepoints>.+?)\s*; fully-qualified )/ do |line|
          if line["group_name"]
            if !line["sub"]
              @current_group_name = line["group_name"]
              @index[:LIST][@current_group_name] = {}
            else
              @current_subgroup_name = line["group_name"]
              @index[:LIST][@current_group_name][@current_subgroup_name] = []
            end
          else
            codepoints = line["codepoints"].split
            @index[:LIST][@current_group_name][@current_subgroup_name] << codepoints.map{|e| e.to_i(16)}.pack("U*")
          end
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