# Aptakube 1.19.7 reads both fields. An empty token causes its normal license
# check to validate the key online and save a token on the next app launch.
# Keep that app-owned token on subsequent activations with the same key.
secret_path="$1"
license_dir="$2"
license_path="$license_dir/license.bin"

umask 077

if [[ ! -r "$secret_path" ]]; then
  echo "Aptakube: the license secret is unavailable." >&2
  exit 1
fi

if [[ -L "$license_dir" || -L "$license_path" ]]; then
  echo "Aptakube: refusing to provision through a symlink." >&2
  exit 1
fi

mkdir -p "$license_dir"
chmod 700 "$license_dir"
temporary_license="$(mktemp "$license_dir/.license.bin.XXXXXXXX")"
trap 'rm -f "$temporary_license"' EXIT

# Read the secret from disk, never through argv or shell interpolation. Trim
# an editor's trailing newline, and reject empty or multiline license keys.
if ! jq --raw-input --slurp --exit-status '
  sub("[\\r\\n]+$"; "")
  | if length > 0 and (test("\\s") | not)
    then {license_key: ., token: ""}
    else error("invalid license key")
    end
' "$secret_path" > "$temporary_license" 2>/dev/null; then
  echo "Aptakube: the license secret must contain one nonempty key." >&2
  exit 1
fi

# No token snapshots or separate state marker: the license itself identifies
# which key was provisioned. This also preserves tokens refreshed by the app.
if [[ -f "$license_path" ]] && jq --slurp --exit-status \
  --slurpfile desired "$temporary_license" '
    length == 1
    and (.[0] | type == "object"
      and .license_key == $desired[0].license_key
      and (.token | type == "string"))
  ' "$license_path" >/dev/null 2>&1; then
  chmod 600 "$license_path"
  exit 0
fi

chmod 600 "$temporary_license"
mv -fT "$temporary_license" "$license_path"
