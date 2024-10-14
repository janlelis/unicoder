module Unicoder
  module Builder
    class Blocks
      include Builder

      def initialize_index
        @index = {
          BLOCKS: []
        }
      end

      def parse!
        parse_file :blocks, :line, regex: /^(?<from>\S+?)\.\.(?<to>\S+);\s(?<name>.+)$/ do |line|
          @index[:BLOCKS] << [line["from"].to_i(16), line["to"].to_i(16), line["name"]]
        end
      end
    end
  end
end
