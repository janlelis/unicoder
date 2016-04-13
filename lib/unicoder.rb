require_relative "unicoder/constants"
require_relative "unicoder/downloader"
require_relative "unicoder/builder"
require_relative "unicoder/multi_dimensional_array_builder"

if defined?(Rake)
  Rake.add_rakelib(File.expand_path('../unicoder', __FILE__))
end
