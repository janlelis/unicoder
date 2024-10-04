module Unicoder
  module Builder
    class SequenceName
      include Builder

      def initialize_index
        @index = {
          SEQUENCES: {},
        }
      end

      def assign_codepoint(codepoints, value, idx = @index[:SEQUENCES], combine: false)
        if option =~ /charkeys/
          key = codepoints.pack("U*")
        else
          key = codepoints
        end

        if idx.has_key?(codepoints)
          if combine
            idx[key] << " / #{value}"
          else
            # ignore new one
          end
        else
          idx[key] = value
        end
      end

      def parse!
        parse_file :named_sequences, :line, regex: /^(?!#)(?<name>.+?);(?<codepoints>.+?)$/ do |line|
          assign_codepoint line["codepoints"].split.map{|cp| cp.to_i(16) }, line["name"]
        end

        parse_file :named_sequences_prov, :line, regex: /^(?!#)(?<name>.+?);(?<codepoints>.+?)$/ do |line|
          assign_codepoint line["codepoints"].split.map{|cp| cp.to_i(16) }, line["name"]
        end

        parse_file :standardized_variants, :line, regex: /^(?<codepoints>.+?);\s*(?<variant>.+?)\s*;\s*(?<context>.*?)\s*# (?<name>.+)$/ do |line|
          name = "#{line["name"].strip} (#{line["variant"]})"
          name << " [#{line["context"]}]" if line["context"] && !line["context"].empty?
          assign_codepoint line["codepoints"].split.map{|cp| cp.to_i(16) }, name, combine: true
        end

        parse_file :standardized_variants, :line, regex: /^(?<codepoints>.+?); (?<name>.+?)\s*;$/ do |line|
          assign_codepoint line["codepoints"].split.map{|cp| cp.to_i(16) }, line["name"]
        end

        parse_file :ivd_sequences, :line, regex: /^(?<codepoints>.+?);.*?; (?<name>.+?)$/ do |line|
          assign_codepoint line["codepoints"].split.map{|cp| cp.to_i(16) }, line["name"], combine: true
        end

        parse_file :emoji_variation_sequences, :line, regex: /^(?<codepoints>.+?)\s*;\s*(?<variant>.+?)\s*;\s*# \(.*\)\s*(?<name>.+?)\s*$/ do |line|
          name = "#{line["name"].strip} (#{line["variant"]})"
          assign_codepoint line["codepoints"].split.map{|cp| cp.to_i(16) }, name
        end

        parse_file :emoji_sequences, :line, regex: /^(?<codepoints>.+?)\s*;\s*(?<type>.+?)\s*; (?<name>.+?)\s*#/ do |line|
          next if line["type"] == "Basic_Emoji"
          name = line["name"].gsub(/\\x{(\h+)}/){ [$1.to_i(16)].pack("U") }.upcase
          assign_codepoint line["codepoints"].split.map{|cp| cp.to_i(16) }, name
        end

        parse_file :emoji_zwj_sequences, :line, regex: /^(?<codepoints>.+?)\s*;.*?; (?<name>.+?)\s*#/ do |line|
          name = line["name"].gsub(/\\x{(\h+)}/){ [$1.to_i(16)].pack("U") }.upcase
          assign_codepoint line["codepoints"].split.map{|cp| cp.to_i(16) }, name
        end
      end
    end
  end
end

