require "open-uri"
require "fileutils"
require "zip"

module Unicoder
  module Downloader
    def self.fetch(identifier,
        unicode_version: CURRENT_UNICODE_VERSION,
        emoji_version: CURRENT_EMOJI_VERSION,
        destination_directory: LOCAL_DATA_DIRECTORY,
        destination: nil,
        filename: nil
      )
      filename = UNICODE_FILES[identifier.to_sym] || filename
      raise ArgumentError, "No valid file identifier or filename given" if !filename
      filename = filename.dup
      filename.sub! 'UNICODE_VERSION', unicode_version
      filename.sub! 'EMOJI_VERSION', emoji_version
      filename.sub! 'EMOJI_RELATED_VERSION', EMOJI_RELATED_UNICODE_VERSIONS[emoji_version]
      if filename =~ /\A(https?|ftp):\/\//
        source = filename
        destination ||= destination_directory + filename.sub(/\A(https?|ftp):\//, "")
      else
        source = UNICODE_DATA_ENDPOINT + filename
        destination ||= destination_directory + filename
      end

      puts "GET #{source} => #{destination}"

      if source =~ %r[^(?<outer_path>.*).zip/(?<inner_path>.*)$]
        # Too much magic, download unzip zip files
        zip = true
        source = $~[:outer_path] + ".zip"
        inner_zip_filename = $~[:inner_path]
        if destination =~ %r[^(?<outer_path>.*).zip/(?<inner_path>.*)$]
          destination = $~[:outer_path] + ".zip"
          destination_files = $~[:outer_path]
        else
          raise "uncoder bug"
        end
      else
        zip = false
      end

      if File.exists?(destination)
        puts "Skipping download of #{source} (already exists)"
      else
        URI.open(source){ |f|
          FileUtils.mkdir_p(File.dirname(destination))
          File.write(destination, f.read)
        }
      end

      if zip
        unzip(destination, [inner_zip_filename], destination_files)
      end
    rescue => e
      $stderr.puts "#{e.class}: #{e.message}"
    end

    def self.unzip(archive, files, destination_dir)
      Zip::File.open(archive) do |zip|
        zip.each do |file_in_zip|
          if files.include?(file_in_zip.name)
            FileUtils.mkdir_p(destination_dir)
            puts "Extract #{file_in_zip.name}"
            file_in_zip.extract(destination_dir + "/#{file_in_zip.name}")
          end
        end
        # entry = zip.glob('*.csv').first
      end
    end
  end
end
