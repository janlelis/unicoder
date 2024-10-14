## CHANGELOG

### 1.1.1

- Fix bug related to unsafe characters
- Fix squared CJK
- Small adjustments for scripts and blocks index builders

### 1.1.0

- Improve name index size: Support ranges
- Improve name index size: Replace common words

### 1.0.0

With the first 1.0 release, unicoder supports 10 indexes:

- blocks
- categories
- confusable
- display_width
- emoji
- name
- numeric_value
- scripts
- sequence_name
- types

All indexes can be build in `marshal` format (Ruby's internal
serialization format) and some now support `esm` (JavaScript module)

### 0.1.0

* Initial release
