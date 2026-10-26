#!/usr/bin/env bash
# Copyright (c) 2023-2026 Glen Muthoka Mutinda
#
# Bumps every version reference in the repo to the given version.
# Usage: bash .github/scripts/bump-version.sh <version> [repo-dir]
#   RELEASE_DATE=YYYY-MM-DD overrides today's date (UTC).
#
# Updates:
#   Install-GalaxyBookEnabler.ps1  $SCRIPT_VERSION and the .NOTES "Version :" line
#   README.md                      version badge
#   PACKAGES.md                    "Last Updated" line
#   CHANGELOG.md                   [Unreleased] -> [<version>] - <date>, compare links
#                                  (stable releases only; prereleases keep [Unreleased])

set -euo pipefail

VERSION="${1:?usage: bump-version.sh <version> [repo-dir]}"
ROOT="${2:-.}"
DATE="${RELEASE_DATE:-$(date -u +%Y-%m-%d)}"
LONG_DATE="$(date -u -d "$DATE" '+%B %-d, %Y')"
REPO_URL="https://github.com/Bananz0/GalaxyBookEnabler"

PRERELEASE=false
[[ "$VERSION" == *-* ]] && PRERELEASE=true

cd "$ROOT"

fail() {
    echo "❌ $*" >&2
    exit 1
}

# --- Installer ---------------------------------------------------------------
grep -q '^\$SCRIPT_VERSION = "' Install-GalaxyBookEnabler.ps1 || fail 'No $SCRIPT_VERSION line in Install-GalaxyBookEnabler.ps1'
sed -i -E 's/^\$SCRIPT_VERSION = ".*"/$SCRIPT_VERSION = "'"$VERSION"'"/' Install-GalaxyBookEnabler.ps1

# First "Version : x" line is the comment-based help .NOTES block
grep -qE '^\s*Version\s*:' Install-GalaxyBookEnabler.ps1 || fail 'No .NOTES "Version :" line in Install-GalaxyBookEnabler.ps1'
sed -i -E '0,/^(\s*Version\s*:\s*).*/s//\1'"$VERSION"'/' Install-GalaxyBookEnabler.ps1

# --- README badge (shields.io needs "-" escaped as "--") ---------------------
BADGE="${VERSION//-/--}"
grep -q 'img.shields.io/badge/version-' README.md || fail 'No version badge in README.md'
sed -i -E 's#(img\.shields\.io/badge/version-).*(-blue\.svg)#\1'"$BADGE"'\2#' README.md

# --- PACKAGES.md -------------------------------------------------------------
if grep -q '^\*\*Last Updated\*\*:' PACKAGES.md; then
    sed -i -E 's/^\*\*Last Updated\*\*:.*$/**Last Updated**: '"$LONG_DATE"' (v'"$VERSION"')/' PACKAGES.md
fi

# --- CHANGELOG.md ------------------------------------------------------------
if [[ "$PRERELEASE" == "false" ]]; then
    if grep -qF "## [$VERSION]" CHANGELOG.md; then
        echo "CHANGELOG already has a [$VERSION] section"
    elif grep -q '^## \[Unreleased\]' CHANGELOG.md; then
        # Keep an empty [Unreleased] on top for the next round of changes
        awk -v v="$VERSION" -v d="$DATE" '
            !done && /^## \[Unreleased\]/ { print "## [Unreleased]"; print ""; print "## [" v "] - " d; done = 1; next }
            { print }
        ' CHANGELOG.md > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md
    else
        fail "CHANGELOG.md has neither a [$VERSION] nor an [Unreleased] section"
    fi

    # Compare links: [unreleased]: .../compare/vPREV...HEAD
    PREV="$(sed -nE 's/^\[unreleased\]: .*\/compare\/v(.*)\.\.\.HEAD$/\1/Ip' CHANGELOG.md | head -n 1)"
    if [[ -n "$PREV" && "$PREV" != "$VERSION" ]]; then
        sed -i -E 's#^\[unreleased\]: .*$#[unreleased]: '"$REPO_URL"'/compare/v'"$VERSION"'...HEAD#I' CHANGELOG.md
        if ! grep -qF "[$VERSION]: " CHANGELOG.md; then
            awk -v line="[$VERSION]: $REPO_URL/compare/v$PREV...v$VERSION" '
                { print }
                !done && tolower($0) ~ /^\[unreleased\]: / { print line; done = 1 }
            ' CHANGELOG.md > CHANGELOG.md.tmp && mv CHANGELOG.md.tmp CHANGELOG.md
        fi
    fi
fi

echo "✓ Bumped to $VERSION ($DATE)"
