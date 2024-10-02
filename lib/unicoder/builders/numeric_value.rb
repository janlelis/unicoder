module Unicoder
  module Builder
    class NumericValue
      include Builder

      def initialize_index
        @index = {}
      end

      def parse!
        if option =~ /charkeys/
          puts "Build using characters as index keys"
          get_key = ->(codepoint){ [codepoint].pack("U") }
        else
          puts "Build using codepoints as index keys"
          get_key = -> (codepoint){ codepoint }
        end

        parse_file :unicode_data, :line, regex: /^(?<codepoint>.+?);(.*?;){7}(?<value>.*?);.*$/ do |line|
          unless line["value"].empty?
            if line["value"] =~ %r</>
              @index[get_key[line["codepoint"].to_i(16)]] =  option =~ /stringfractions/ ? %%"#{line["value"]}"% : line["value"].to_r
            else
              @index[get_key[line["codepoint"].to_i(16)]] = line["value"].to_i
            end
          end
        end

        parse_file :unihan_numeric_values, :line, regex: /^U\+(?<codepoint>\S+)\s+\S+\s+(?<value>\S+)$/ do |line|
          @index[get_key[line["codepoint"].to_i(16)]] = line["value"].to_i
        end
      end
    end
  end
end
