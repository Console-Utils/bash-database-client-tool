# Database client

## Description

Tool to work with Repl.it database without explicit curl invocation.

## API

The following functions are provided for interacting with Repl.it database:

- `replit_keys_set` - sets existing keys or creates new ones
- `replit_keys_get` - gets existing keys
- `replit_keys_delete` - removes existing keys
- `replit_keys_list` - prints existing keys

### replit_keys_set

#### Syntax

```bash
replit_keys_set [{ -h | --help }] [--] <key1>=<value1> [<key2>=<value2>...]
```

#### Options

- `-h`|`--help` - write help and exit
- `-v`|`--version` - write version and exit
- `--` - stops option parsing

### replit_keys_get

#### Syntax

```bash
replit_keys_get [{ -h | --help }] [{ -r | --regex } [{ -e | --extended }]] [--] <key1> [<key2>...]
```

#### Options

- `-h`|`--help` - write help and exit
- `-v`|`--version` - write version and exit
- `-r`|`--regex` - use regex instead of literal strings
- `-e`|`--extended` - use ERE regex instead of BRE
- `--` - stops option parsing

### replit_keys_delete

#### Syntax

```bash
replit_keys_delete [{ -h | --help }] [{ -r | --regex } [{ -e | --extended }]] [--] <key1> [<key2>...]
```

#### Options

- `-h`|`--help` - write help and exit
- `-v`|`--version` - write version and exit
- `-r`|`--regex` - use regex instead of literal strings
- `-e`|`--extended` - use ERE regex instead of BRE
- `--` - stops option parsing

### replit_keys_list

#### Syntax

```bash
replit_keys_list usage: replit_keys_list [{ -h | --help }] [{ -r | --regex } [{ -e | --extended }]] [--] [<key1> [<key2>...]]
```

#### Options

- `-h`|`--help` - write help and exit
- `-v`|`--version` - write version and exit
- `-r`|`--regex` - use regex instead of literal strings
- `-e`|`--extended` - use ERE regex instead of BRE
- `--` - stops option parsing
