#!/usr/bin/env bash

set -e

function _check_setup {
  # Checking git and secret-plugin setup:
  local is_tree
  is_tree=$(_is_inside_git_tree)
  if [[ "$is_tree" -ne 0 ]]; then
    _abort "git cannot locate repo. Perhaps use 'git init'/'git clone', then 'git secret init'"
  fi

  # Checking if the '.gitsecret' dir (or as set by SECRETS_DIR) is not ignored:
  _secrets_dir_is_not_ignored

  # Checking gpg setup:
  local keys_dir
  keys_dir=$(_get_secrets_dir_keys)

  local secring="$keys_dir/secring.gpg"
  if [[ -f $secring ]] && [[ -s $secring ]]; then
    # secring.gpg exists and is not empty,
    # someone has imported a private key.
    _abort 'it seems that someone has imported a secret key.'
  fi
}

_other() {
  echo 'done'
}

function _init_script {
  if [[ $# == 0 ]]; then
    _incorrect_usage 'no input parameters provided. \n' 126 "$@"
  fi

  # Parse plugin-level options:
  local dry_run=0

  while [[ $# -gt 0 ]]; do
    local opt="$1"

    case "$opt" in
      # Options for quick-exit strategy:
      --dry-run)
        dry_run=1
        shift;;

      --version) _show_version;;

      *) break;;  # do nothing
    esac
  done

  if [[ "$dry_run" == 0 ]]; then
    # Checking for proper set-up:
    _check_setup

    # Routing the input command:
    local function_exists
    function_exists=$(_function_exists "$1")

    if [[ "$function_exists" == 0 ]] && [[ ! $1 == _* ]]; then
      $1 "${@:2}"
    else  # TODO: elif [[ $(_plugin_exists $1) == 0 ]]; then
      _incorrect_usage "command $1 not found." 126 "$@"
    fi
  fi

  for line in "${to_show[@]}"; do
    local filename
    local path
    filename=$(_get_record_filename "$line")
    path=$("$path_prepend_func" "$filename")
  fi
}

alias temp='temp -R'

_init_script "$@"
