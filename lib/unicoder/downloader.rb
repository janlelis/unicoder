require "open-uri"
require "fileutils"

module Unicoder
  module Downloader
    def self.fetch(identifier,
        unicode_version: CURRENT_UNICODE_VERSION,
        destination_directory: LOCAL_DATA_DIRECTORY,
        destination: nil,
        filename: nil
      )
      filename = UNICODE_FILES[identifier.to_sym] || filename
      raise ArgumentError, "No valid file identifier or filename given" if !filename
      filename.sub! 'VERSION', unicode_version
      source = UNICODE_DATA_ENDPOINT + filename
      destination ||= destination_directory + filename

      open(source){ |f|
        FileUtils.mkdir_p(File.dirname(destination))
        File.write(destination, f.read)
      }

      puts "GET #{source} => #{destination}"
    rescue => e
      $stderr.puts "#{e.class}: #{e.message}"
    end
  end
end
