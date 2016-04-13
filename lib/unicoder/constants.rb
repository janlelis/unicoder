module Unicoder
  VERSION = "0.1.0".freeze

  CURRENT_UNICODE_VERSION = "8.0.0".freeze

  UNICODE_VERSIONS = %w[
     6.3.0
     7.0.0
     8.0.0
     9.0.0
  ].freeze

  UNICODE_DATA_ENDPOINT = "ftp://ftp.unicode.org/Public".freeze

  LOCAL_DATA_DIRECTORY = File.expand_path(File.dirname(__FILE__) + "/../../data/unicode").freeze

  UNICODE_FILES = {
    east_asian_width:         "/VERSION/ucd/EastAsianWidth.txt",
    unicode_data:             "/VERSION/ucd/UnicodeData.txt",
    name_aliases:             "/VERSION/ucd/NameAliases.txt",
    confusables:              "/security/VERSION/confusables.txt",
    blocks:                   "/VERSION/ucd/Blocks.txt",
    scripts:                  "/VERSION/ucd/Scripts.txt",
    script_extensions:        "/VERSION/ucd/ScriptExtensions.txt",
    property_value_aliases:   "/VERSION/ucd/PropertyValueAliases.txt",
    general_categories:       "/VERSION/ucd/extracted/DerivedGeneralCategory.txt",
  }
end

