#!/usr/bin/env bash
# Refuses a tag that must not publish — §12.4.
#
# A BRANCH NEVER PUBLISHES. What publishes is an act named in advance: a release/* tag, on
# a commit that is on main. Both halves matter. A tag on a branch would ship work that never
# passed the pull request; a tag on a commit main has since moved past would ship something
# nobody can reconstruct from main's history.
#
# Run by the release workflow BEFORE the build, so a tag that should not publish costs
# nothing but a red check.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

tag="${1:-${GITHUB_REF_NAME:-}}"

if [[ -z $tag ]]; then
    echo "check-release-tag: no tag given, and GITHUB_REF_NAME is not set." >&2
    exit 1
fi

if [[ $tag != release/* ]]; then
    echo "check-release-tag: \"$tag\" is not a release/* tag. Only those publish." >&2
    exit 1
fi

# The workflow checks out the tag, so the commit under test is HEAD.
commit="$(git rev-parse HEAD)"

git fetch --quiet origin main

if ! git merge-base --is-ancestor "$commit" origin/main; then
    echo "check-release-tag: \"$tag\" points at $commit, which is not on main." >&2
    echo "  Merge the work first, then tag the merge commit." >&2
    exit 1
fi

echo "check-release-tag: $tag -> $commit, on main."
