module Unicoder
  module Builder
    class Confusable
      include Builder

      def initialize_index
        @index = {
          CONFUSABLE: {},
          IGNORABLE: [],
        }
      end

      def parse!
        parse_file :confusables, :line, regex: /^(?<from>\S+)\s+;\s+(?<to>.+?)\s+;.*$/ do |line|
          source = line["from"].to_i(16)
          if line["to"].include?(" ")
            replace_with = line["to"].split(" ").map{ |codepoint|
              cp = codepoint.to_i(16)
              option =~ /charvalues/ ? [cp].pack("U") : cp
            }
          else
            cp = line["to"].to_i(16)
            replace_with = option =~ /charvalues/ ? [cp].pack("U") : cp
          end
          assign :CONFUSABLE, source, replace_with
        end

        parse_file :core_properties, :line, begin: /^# Derived Property: Default_Ignorable_Code_Point$/, end: /^# ================================================$/, regex: /^(?<codepoints>\S+)\s+; Default_Ignorable_Code_Point.*$/ do |line|
          if line["codepoints"]['..']
            single_or_multiple_codepoints = line["codepoints"].split('..').map{ |codepoint|
              codepoint.to_i(16)
            }
          else
            single_or_multiple_codepoints = line["codepoints"].to_i(16)
          end

          @index[:IGNORABLE] << single_or_multiple_codepoints
        end
      end
    end
  end
end
