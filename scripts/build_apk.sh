#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pubspec="$project_root/pubspec.yaml"

if [[ ! -f "$pubspec" ]]; then
  echo "Error: pubspec.yaml was not found at $pubspec" >&2
  exit 1
fi

version_line="$(grep -E '^version:[[:space:]]*[^[:space:]]+' "$pubspec" | head -n 1 || true)"
version="${version_line#version:}"
version="${version#"${version%%[![:space:]]*}"}"
version="${version%%+*}"

if [[ -z "$version" || "$version" == "$version_line" ]]; then
  echo "Error: could not read a valid version from pubspec.yaml" >&2
  exit 1
fi

cd "$project_root"
flutter build apk --release

apk="$project_root/build/app/outputs/flutter-apk/app-release.apk"
if [[ -z "$apk" || ! -f "$apk" ]]; then
  echo "Error: Flutter build succeeded but no APK was found" >&2
  exit 1
fi

release_dir="$project_root/build/releases"
mkdir -p "$release_dir"
output="$release_dir/calcnova_v${version}.apk"
cp "$apk" "$output"

if [[ ! -s "$output" ]]; then
  echo "Error: versioned APK was not created at $output" >&2
  exit 1
fi

echo "APK: $output"
