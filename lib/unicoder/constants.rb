module Unicoder
  VERSION = "0.1.0".freeze

  CURRENT_UNICODE_VERSION = "9.0.0".freeze

  CURRENT_EMOJI_VERSION = "5.0".freeze

  UNICODE_VERSIONS = %w[
     6.3.0
     7.0.0
     8.0.0
     9.0.0
  ].freeze

  EMOJI_VERSIONS = %[
    5.0
    4.0
    3.0
    2.0
  ].freeze

  UNICODE_DATA_ENDPOINT = "ftp://ftp.unicode.org/Public".freeze

  LOCAL_DATA_DIRECTORY = File.expand_path(File.dirname(__FILE__) + "/../../data/unicode").freeze

  UNICODE_FILES = {
    east_asian_width:          "/UNICODE_VERSION/ucd/EastAsianWidth.txt",
    unicode_data:              "/UNICODE_VERSION/ucd/UnicodeData.txt",
    name_aliases:              "/UNICODE_VERSION/ucd/NameAliases.txt",
    confusables:               "/security/UNICODE_VERSION/confusables.txt",
    blocks:                    "/UNICODE_VERSION/ucd/Blocks.txt",
    scripts:                   "/UNICODE_VERSION/ucd/Scripts.txt",
    script_extensions:         "/UNICODE_VERSION/ucd/ScriptExtensions.txt",
    property_value_aliases:    "/UNICODE_VERSION/ucd/PropertyValueAliases.txt",
    general_categories:        "/UNICODE_VERSION/ucd/extracted/DerivedGeneralCategory.txt",
    unihan_numeric_values:     "/UNICODE_VERSION/ucd/Unihan.zip/Unihan_NumericValues.txt",
    jamo:                      "/UNICODE_VERSION/ucd/Jamo.txt",
    emoji:                     "/emoji/EMOJI_VERSION/emoji-data.txt",
    emoji_sequences:           "/emoji/EMOJI_VERSION/emoji-sequences.txt",
    emoji_variation_sequences: "/emoji/EMOJI_VERSION/emoji-variation-sequences.txt",
    emoji_zwj_sequences:       "/emoji/EMOJI_VERSION/emoji-zwj-sequences.txt",
  }
end

