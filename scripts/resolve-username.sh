#!/usr/bin/env bash

set -eu

host="$1"
username="$2"
host_users="$3"
repository="$(cd "$(dirname "$0")/.." && pwd -P)"
lima_runtime="$repository/lima/runtime.json"

case "$host" in
  lima-nixos-*)
    if [ -f "$lima_runtime" ]; then
      runtime_username="$(jq -er '.username | select(type == "string" and length > 0)' "$lima_runtime")"
      valid_users="$(jq -cn --arg username "$runtime_username" '[ $username ]')"
    else
      valid_users="$(printf '%s\n' "$host_users" | jq -ce --arg host "$host" '.[$host] // []')"
    fi
    ;;
  *)
    valid_users="$(printf '%s\n' "$host_users" | jq -ce --arg host "$host" '.[$host] // []')"
    ;;
esac

user_count="$(printf '%s\n' "$valid_users" | jq 'length')"

print_users() {
  printf '%s\n' "$valid_users" | jq -r '.[]' | while IFS= read -r valid_user; do
    printf '  \033[1m%s\033[0m\n' "$valid_user" >&2
  done
}

if [ -z "$username" ]; then
  if [ "$user_count" -ne 1 ]; then
    printf '\033[1;31merror\033[0m: \033[1musername is required for host `%s`; valid usernames:\033[0m\n' "$host" >&2
    print_users
    exit 1
  fi

  username="$(printf '%s\n' "$valid_users" | jq -r '.[0]')"
elif ! printf '%s\n' "$valid_users" | jq -e --arg username "$username" 'index($username) != null' >/dev/null; then
  printf '\033[1;31merror\033[0m: \033[1minvalid username `%s` for host `%s`; valid usernames:\033[0m\n' "$username" "$host" >&2
  print_users
  exit 1
fi

printf '%s\n' "$username"
