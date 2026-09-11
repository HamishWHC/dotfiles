#!/bin/sh

set -eu

host="$1"

worktree="$(git rev-parse --show-toplevel)"
worktree="$(cd "$worktree" && pwd -P)"
worktree_hash="$(printf '%s' "$worktree" | shasum -a 256 | cut -c 1-12)"

printf 'dotfiles-lima-nixos-%s-%s\n' "$host" "$worktree_hash"
