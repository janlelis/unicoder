require "json"

module Unicoder
  # A builder defines a parse function which translates one (ore more) unicode data
  # files into an index hash
  module Builder
    attr_reader :index

    def initialize(unicode_version = nil, emoji_version = nil)
      @unicode_version = unicode_version
      @emoji_version = emoji_version
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
      filename.sub! '.zip', ''
      filename.sub! /\A(https?|ftp):\//, ""
      Downloader.fetch(identifier) unless File.exists?(LOCAL_DATA_DIRECTORY + filename)
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
      end

      # if false# || options[:gzip]
      if options[:gzip]
        Gem.gzip(index_file)
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
        (options[:unicode_version] || CURRENT_UNICODE_VERSION),
        (options[:emoji_version]   || CURRENT_EMOJI_VERSION),
      )
      puts "Building index for #{identifier}…"
      builder.parse!
      index_file = builder.export(options)

      destination ||= options[:destination] || identifier.to_s
      destination += ".#{format}"
      destination += ".gz" if options[:gzip]
      bytes = File.write destination, index_file

      puts "Index created at: #{destination} (#{bytes} bytes written)"
    end
  end
end
