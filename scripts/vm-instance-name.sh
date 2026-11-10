#!/bin/sh

set -eu

provider="$1"
host="$2"

worktree="$(git rev-parse --show-toplevel)"
worktree="$(cd "$worktree" && pwd -P)"
worktree_hash="$(printf '%s' "$worktree" | shasum -a 256 | cut -c 1-12)"

printf 'dotfiles-%s-nixos-%s-%s\n' "$provider" "$host" "$worktree_hash"
