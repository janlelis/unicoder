require "json"
require "rubygems/util"

module Unicoder
  # A builder defines a parse function which translates one (ore more) unicode data
  # files into an index hash
  module Builder
    attr_reader :index, :formats, :option
    attr_writer :option

    def formats
      {
        marshal: {
          ext: ".marshal",
        },
        json: {
          ext: ".json",
        },
        esm: {
          ext: ".mjs"
        }
      }
    end

    def meta
      {
        "META" => {
          "generator" => "unicoder",
          "unicodeVersion" => @unicode_version,
        },
        "INDEX" => "_PLACEHOLDER_"
      }
    end

    def initialize(unicode_version = nil, emoji_version = nil)
      @unicode_version = unicode_version || CURRENT_UNICODE_VERSION
      @emoji_version = emoji_version || CURRENT_EMOJI_VERSION
      @option = ""
      initialize_index
    end

    def initialize_index
      @index = {}
    end

    def assign_codepoint(codepoint, value, index = @index)
      index[codepoint] = value
    end

    def parse!
      raise ArgumentError, "abstract"
    end

    def parse_file(identifier, parse_mode, **parse_options)
      filename = UNICODE_FILES[identifier.to_sym] || filename
      raise ArgumentError, "No valid file identifier or filename given" if !filename
      filename = filename.dup
      filename.sub! 'UNICODE_VERSION', @unicode_version
      filename.sub! 'EMOJI_VERSION', @emoji_version
      filename.sub! 'EMOJI_RELATED_VERSION', EMOJI_RELATED_UNICODE_VERSIONS[@emoji_version]
      filename.sub! '.zip', ''
      filename.sub! /\A(https?|ftp):\//, ""
      Downloader.fetch(identifier) unless File.exist?(LOCAL_DATA_DIRECTORY + filename)
      file = File.read(LOCAL_DATA_DIRECTORY + filename)

      if parse_mode == :line
        file.each_line{ |line|
          yield Hash[ $~.names.zip( $~.captures ) ] if line =~ parse_options[:regex]
        }
      elsif parse_mode == :xml
        require "oga"
        yield Oga.parse_xml(file)
      else
        yield file
      end
    end

    def export(format: :marshal, **options)
      p index if options[:verbose]

      case format.to_sym
      when :marshal
        index_file = Marshal.dump(index)
      when :json
        index_file = JSON.dump(index)
      when :esm
        formatted_index = <<~JS
          {#{index.map{|k,v|%%"#{k}":#{v}%}*','}}
        JS

        if options[:meta]
          formatted_meta = JSON.dump(meta)
          formatted_index = formatted_meta.sub('"_PLACEHOLDER_"', formatted_index)
        end

        index_file = "export default " + formatted_index
      end

      if options[:gzip]
        Gem::Util.gzip(index_file)
      else
        index_file
      end
    end

    def self.build(identifier, **options)
      format = options[:format] || :marshal
      require_relative "builders/#{identifier}"
      # require "unicoder/builders/#{identifier}"
      builder_class = self.const_get(identifier.to_s.gsub(/(?:^|_)([a-z])/){ $1.upcase })
      builder = builder_class.new(
        options[:unicode_version],
        options[:emoji_version],
      )
      puts "Building index for #{identifier}…"
      if options[:option]
        builder.option = options[:option]
      end
      builder.parse!
      index_file = builder.export(**options)

      destination ||= options[:destination] || identifier.to_s
      destination += "#{builder.formats.dig(format.to_sym, :ext)}"
      destination += ".gz" if options[:gzip]
      bytes = File.write destination, index_file

      puts "Index created at: #{destination} (#{bytes} bytes written)"
    end
  end
end
