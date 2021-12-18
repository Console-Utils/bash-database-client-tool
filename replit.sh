#!/usr/bin/env bash

# Prints pretty formatted help.
# 
# Environment variables to modify behaviour:
# - REPLIT_COMMAND_COLOR
# - REPLIT_BRACKETS_COLOR
# - REPLIT_BRACES_COLOR
# - REPLIT_ALTERNATION_COLOR
# - REPLIT_OPTION_COLOR
# - REPLIT_PLACEHOLDER_COLOR
__replit_colorize_help() {
  local command_color="\e[${REPLIT_COMMAND_COLOR:-92}m"
  local brackets_color="\e[${REPLIT_BRACKETS_COLOR:-34}m"
  local braces_color="\e[${REPLIT_BRACES_COLOR:-36}m"
  local alternation_color="\e[${REPLIT_ALTERNATION_COLOR:-35}m"
  local option_color="\e[${REPLIT_OPTION_COLOR:-94}m"
  local placeholder_color="\e[${REPLIT_PLACEHOLDER_COLOR:-94}m"

  local usage=$1

  local command=${usage%% *}
  local arguments=${usage#* }

  command="$command_color$command\e[0m"
  arguments=${arguments//[/$brackets_color['\e[0m'}
  arguments=${arguments//]/$brackets_color]'\e[0m'}
  arguments=${arguments//\{/$braces_color\{'\e[0m'}
  arguments=${arguments//\}/$braces_color\}'\e[0m'}
  arguments=${arguments//|/$alternation_color|'\e[0m'}
  arguments=$(sed --regexp-extended "s/--?\w*/\\\\$option_color&\\\\e[0m/g" <<< $arguments)
  arguments=$(sed --regexp-extended "s/<\w+>/\\\\$placeholder_color&\\\\e[0m/g" <<< $arguments)

  echo -e "$command $arguments\e[0m"
}

# Prints pretty formatted help with prefix.
# 
# Environment variables to modify behaviour:
# - REPLIT_PREFIX_COLOR
__replit_format_help() {
  local prefix_color="\e[${REPLIT_PREFIX_COLOR:-93}m"

  local prefix=$1
  local usage=$2

  echo -en "$prefix_color$prefix"
  __replit_colorize_help "$usage"
}

# Print pretty formatted help with prefix when error occures.
__replit_print_error() {
  local usage=$1

  __replit_format_help "Wrong option/argument used, please check usage: " "$usage"
}

# Sets existing keys or creates new ones.
replit_keys_set() {
  local help="$FUNCNAME [{ -h | --help }] [--] <key1>=<value1> [<key2>=<value2>...]"
  local argv
  argv=$(getopt --options h --longoptions help -- "$@" 2> /dev/null)

  if (( $? != 0 ))
  then
    __replit_print_error "$help" >&2
    return 2
  fi

  eval set -- "$argv"

  local -A pairs=()

  while [[ -n $1 ]]
  do
    case $1 in
      -h|--help)
        __replit_format_help "$FUNCNAME usage: " "$help" >&2
        return
        ;;
      --)
        shift
        break
        ;;
      *=*)
        key=${1%%=*}
        value=${1#*=}
        pairs+=(["$key"]="$value")
        shift
        ;;
      *)
        __replit_print_error "$help" >&2
        return 2
        ;;
    esac
  done

  while [[ -n $1 ]]
  do
    case $1 in
      *=*)
        key=${1%%=*}
        value=${1#*=}
        pairs+=(["$key"]="$value")
        shift
        ;;
      *)
        __replit_print_error "$help" >&2
        return 2
        ;;
    esac
  done

  for key in "${!pairs[@]}"
  do
    curl "$REPLIT_DB_URL" --data "$key=${pairs[$key]}" && echo "'$key' with '${pairs[$key]}' was created." >&2
  done
}

# Gets existing keys.
replit_keys_get() {
  local help="$FUNCNAME [{ -h | --help }] [--] <key1> [<key2>...]"
  local argv="$(getopt --options h --longoptions help -- "$@")"

  if (( $? != 0 ))
  then
    __replit_format_help "$FUNCNAME usage: " "$help" >&2
    return 2
  fi

  eval set -- "$argv"

  local keys=()

  while [[ -n $1 ]]
  do
    case $1 in
      -h|--help)
        __replit_format_help "$FUNCNAME usage: " "$help" >&2
        return
        ;;
      --)
        shift
        break
        ;;
      *)
        key=$1
        keys+=("$key")
        shift
        ;;
    esac
  done

  while [[ -n $1 ]]
  do
    key=$1
    keys+=("$key")
    shift
  done

  for key in "${keys[@]}"
  do
    local value=$(curl "$REPLIT_DB_URL/$key" 2> /dev/null)
    [[ -n $value ]] && echo "$key=$value"
  done
}

# Removes existing keys.
replit_keys_delete() {
  local help="$FUNCNAME [{ -h | --help }] [--] <key1> [<key2>...]"
  local argv="$(getopt --options h --longoptions help -- "$@")"

  if (( $? != 0 ))
  then
    __replit_format_help "$FUNCNAME usage: " "$help" >&2
    return 2
  fi

  eval set -- "$argv"

  local keys=()

  while [[ -n $1 ]]
  do
    case $1 in
      -h|--help)
        __replit_format_help "$FUNCNAME usage: " "$help" >&2
        return
        ;;
      --)
        shift
        ;;
      *)
        key=$1
        keys+=("$key")
        shift
        ;;
    esac
  done

  for key in "${keys[@]}"
  do
    local -i http_code=$(curl --include --request DELETE "$REPLIT_DB_URL/$key" 2> /dev/null | sed --regexp-extended --quiet 's#HTTP/2\s+([[:digit:]])#\1#; p')
    [[ $http_code == 204 ]] && echo "'$key' was deleted." >&2 || echo "'$key' not found." >&2
  done
}

# Prints existing keys.
replit_keys_list() {
  local help="$FUNCNAME [{ -h | --help }] [--]"
  local argv
  argv="$(getopt --options h --longoptions help -- "$@" 2> /dev/null)"

  if (( $? != 0 ))
  then
    __replit_print_error "$help" >&2
    return 2
  fi

  eval set -- "$argv"

  while [[ -n $1 ]]
  do
    case $1 in
      -h|--help)
        __replit_format_help "$FUNCNAME usage: " "$help" >&2
        return
        ;;
      --)
        shift
        break
        ;;
      *)
        __replit_print_error "$help" >&2
        return 2
        ;;
    esac
  done

  [[ -n $1 ]] && {
    __replit_print_error "$help" >&2
    return 2
  }

  curl --get --data 'prefix=' "$REPLIT_DB_URL"
}
