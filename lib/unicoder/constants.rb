# frozen_string_literal: true

module Unicoder
  VERSION = "0.1.0"

  UNICODE_VERSIONS = %w[
    14.0.0
    13.0.0
    12.1.0
    12.0.0
    11.0.0
    10.0.0
     9.0.0
     8.0.0
     7.0.0
     6.3.0
  ].freeze

  CURRENT_UNICODE_VERSION = UNICODE_VERSIONS.first

  EMOJI_VERSIONS = %w[
   14.0
   13.1
   13.0
   12.1
   12.0
   11.0
    5.0
    4.0
    3.0
    2.0
  ].freeze

  EMOJI_RELATED_UNICODE_VERSIONS = {
   "14.0" => "14.0.0",
   "13.1" => "13.0.0",
   "13.0" => "13.0.0",
   "12.1" => "12.1.0",
   "12.0" => "12.0.0",
   "11.0" => "11.0.0",
    "5.0" => "10.0.0",
    "4.0" => "9.0.0",
    "3.0" => "9.0.0",
    "2.0" => "8.0.0",
  }.freeze

  CURRENT_EMOJI_VERSION = EMOJI_VERSIONS.first

  IVD_VERSION = "2020-11-06"

  CLDR_VERSION = "40"

  UNICODE_DATA_ENDPOINT = "ftp://ftp.unicode.org/Public"

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
    named_sequences:           "/UNICODE_VERSION/ucd/NamedSequences.txt",
    named_sequences_prov:      "/UNICODE_VERSION/ucd/NamedSequencesProv.txt",
    standardized_variants:     "/UNICODE_VERSION/ucd/StandardizedVariants.txt",
    ivd_sequences:             "https://www.unicode.org/ivd/data/#{IVD_VERSION}/IVD_Sequences.txt",
    # emoji_data:                "/EMOJI_VERSION/ucd/emoji/",
    emoji_data:                "/EMOJI_RELATED_VERSION/ucd/emoji/emoji-data.txt",
    emoji_sequences:           "/emoji/EMOJI_VERSION/emoji-sequences.txt",
    # emoji_variation_sequences: "/emoji/EMOJI_VERSION/emoji-variation-sequences.txt",
    emoji_variation_sequences: "/EMOJI_RELATED_VERSION/ucd/emoji/emoji-variation-sequences.txt",
    emoji_zwj_sequences:       "/emoji/EMOJI_VERSION/emoji-zwj-sequences.txt",
    emoji_test:                "/emoji/EMOJI_VERSION/emoji-test.txt",
    # valid_subdivisions:        "https://www.unicode.org/repos/cldr/tags/release-#{CLDR_VERSION}/common/validity/subdivision.xml",
    valid_subdivisions:        "https://raw.githubusercontent.com/unicode-org/cldr/release-#{CLDR_VERSION}/common/validity/subdivision.xml",
    # ""
  }
end

