module Unicoder
  module Builder
    class Scripts
      include Builder
      include MultiDimensionalArrayBuilder

      def initialize_index
        @index = {
          SCRIPTS: [],
          SCRIPT_EXTENSIONS: {},
          SCRIPT_ALIASES: {},
          SCRIPT_NAMES: [],
          OFFSETS: [
            0x10000,
            0x1000,
            0x100,
            0x10
          ],
        }
        @reverse_script_names = {}
        @reverse_script_extension_names = {}
      end

      def lookup_extension_names(extension_scripts_string)
        extension_scripts_string.split(" ").map{ |extension_script|
          @reverse_script_extension_names[extension_script]
        }
      end

      # TODO refactor how multiple indexes are organized
      def assign_classic(sub_index_name, codepoint, value)
        idx = @index[sub_index_name]

        if option =~ /charkeys/
          idx[[codepoint].pack("U*")] = value
        else
          idx[codepoint] = value
        end
      end

      def parse!
        parse_file :property_value_aliases, :line, regex: /^sc ; (?<short>\S+?)\s*; (?<long>\S+?)(?:\s*; (?<short2>\S+))?$/ do |line|
          @index[:SCRIPT_NAMES] << line["long"]
          script_number = @reverse_script_names.size
          @reverse_script_names[line["long"]] = script_number

          @index[:SCRIPT_ALIASES][line["short" ]] = script_number
          @index[:SCRIPT_ALIASES][line["short2"]] = script_number if line["short2"]
          @reverse_script_extension_names[line["short"]] = script_number
        end

        parse_file :scripts, :line, regex: /^(?<from>\S+?)(\.\.(?<to>\S+))?\s+; (?<script>\S+) #.*$/ do |line|
          if line["to"]
            (line["from"].to_i(16)..line["to"].to_i(16)).each{ |codepoint|
              assign_codepoint codepoint, @reverse_script_names[line["script"]], @index[:SCRIPTS]
            }
          else
            assign_codepoint line["from"].to_i(16), @reverse_script_names[line["script"]], @index[:SCRIPTS]
          end
        end

        4.times{ compress! @index[:SCRIPTS] }

        parse_file :script_extensions, :line, regex: /^(?<from>\S+?)(\.\.(?<to>\S+))?\s+; (?<scripts>.+?) #.*$/ do |line|
          if line["to"]
            (line["from"].to_i(16)..line["to"].to_i(16)).each{ |codepoint|
              assign_classic :SCRIPT_EXTENSIONS, codepoint, lookup_extension_names(line["scripts"])
            }
          else
            assign_classic :SCRIPT_EXTENSIONS, line["from"].to_i(16), lookup_extension_names(line["scripts"])
          end
        end
      end
    end
  end
end
