# unicoder [![[version]](https://badge.fury.io/rb/unicoder.svg)](https://badge.fury.io/rb/unicoder)

unicoder turns Unicode data into bundles for programming libraries.

## Usage

```
$ unicoder build <index_name> [--gzip]
```

Examples:

```
$ unicoder build emoji --format marshal --gzip
$ unicoder build numeric_value --format esm
```


## Libraries With unicoder-based Indexes

### Ruby

Index Name    | Gem
--------------|----
blocks        | [unicode-blocks](https://github.com/janlelis/unicode-blocks)
categories    | [unicode-categories](https://github.com/janlelis/unicode-categories)
confusable    | [unicode-confusable](https://github.com/janlelis/unicode-confusable)
emoji         | [unicode-emoji](https://github.com/janlelis/unicode-emoji)
display\_width| [unicode-display_width](https://github.com/janlelis/unicode-display_width)
name          | [unicode-name](https://github.com/janlelis/unicode-name)
numeric\_value| [unicode-numeric_value](https://github.com/janlelis/unicode-numeric_value)
scripts       | [unicode-scripts](https://github.com/janlelis/unicode-scripts)
sequence\_name| [unicode-sequence_name](https://github.com/janlelis/unicode-sequence_name)
types         | [unicode-types](https://github.com/janlelis/unicode-types)

### JavaScript (ESM)

Index Name    | Module
--------------|----
name, sequence\_name, type | [unicode-name.js](https://github.com/janlelis/unicode-name.js)
numeric\_value| [unicode-number.js](https://github.com/janlelis/unicode-number.js)

## MIT License

Copyright (C) 2016-2024 Jan Lelis <https://janlelis.com>. Released under the MIT license.
