module Unicoder
  module Builder
    class Confusable
      include Builder

      def parse!
        parse_file :confusables, :line, regex: /^(?<from>\S+)\s+;\s+(?<to>.+)\s+;.*$/ do |line|
          source = line["from"].to_i(16)
          if line["to"].include?(" ")
            replace_with = line["to"].split(" ").map{ |codepoint|
              codepoint.to_i(16)
            }
          else
            replace_with = line["to"].to_i(16)
          end
          @index[source] = replace_with
        end
      end
    end
  end
end
