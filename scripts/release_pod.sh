#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/release_pod.sh VERSION [options]

Examples:
  scripts/release_pod.sh 2.0.5 --summary "2.0.5 release" --allow-warnings
  scripts/release_pod.sh 2.0.5 --dry-run

Options:
  --summary TEXT             Update s.summary in the podspec.
  --message TEXT             Commit message. Defaults to "Release VERSION".
  --remote NAME              Git remote to push to. Defaults to "origin".
  --dry-run                  Print actions without changing files.
  --skip-lint                Skip "pod lib lint".
  --allow-warnings           Pass --allow-warnings to CocoaPods lint/push.
  --skip-import-validation   Pass --skip-import-validation to CocoaPods lint/push.
  --skip-tests               Pass --skip-tests to CocoaPods lint/push.
  --repo-update              Pass --repo-update to CocoaPods lint/push.
  --lint-deployment-target N Use N as minimum deployment target for lint Pods.
                             Defaults to 13.0.
  --no-lint-target-patch     Do not patch CocoaPods lint Pods deployment target.
  --no-push                  Do not push commit/tag to git remote.
  --no-trunk                 Do not publish to CocoaPods trunk.
  -h, --help                 Show this help.

Notes:
  If the podspec already has VERSION, the script skips the version commit and
  continues with lint, tag, push, and trunk publish.

Environment:
  PODSPEC                    Podspec path. Auto-detected when only one exists.
USAGE
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

info() {
  printf '%s\n' "$*"
}

run() {
  printf '+'
  printf ' %q' "$@"
  printf '\n'

  if [[ "$DRY_RUN" == "0" ]]; then
    "$@"
  fi
}

run_with_cocoapods_args() {
  if [[ "$COCOAPODS_ARGS_COUNT" -gt 0 ]]; then
    run "$@" "${COCOAPODS_ARGS[@]}"
  else
    run "$@"
  fi
}

run_pod_with_cocoapods_args() {
  if [[ "$ENABLE_LINT_TARGET_PATCH" == "1" ]]; then
    if [[ "$COCOAPODS_ARGS_COUNT" -gt 0 ]]; then
      run env "RUBYOPT=$POD_RUBYOPT" "COCOAPODS_LINT_DEPLOYMENT_TARGET=$LINT_DEPLOYMENT_TARGET" pod "$@" "${COCOAPODS_ARGS[@]}"
    else
      run env "RUBYOPT=$POD_RUBYOPT" "COCOAPODS_LINT_DEPLOYMENT_TARGET=$LINT_DEPLOYMENT_TARGET" pod "$@"
    fi
  else
    run_with_cocoapods_args pod "$@"
  fi
}

podspec_has_release_values() {
  local podspec="$1"
  local version="$2"
  local summary="$3"

  ruby - "$podspec" "$version" "$summary" <<'RUBY'
path, version, summary = ARGV
text = File.read(path)

version_match = text.match(/\bs\.version\s*=\s*['"]([^'"]+)['"]/)
exit 1 unless version_match && version_match[1] == version

if summary && !summary.empty?
  summary_match = text.match(/\bs\.summary\s*=\s*['"]([^'"]*)['"]/)
  exit 1 unless summary_match && summary_match[1] == summary
end
RUBY
}

need_value() {
  local option="$1"
  local value="${2:-}"
  [[ -n "$value" ]] || die "$option requires a value."
}

detect_podspec() {
  if [[ -n "${PODSPEC:-}" ]]; then
    [[ -f "$PODSPEC" ]] || die "PODSPEC does not exist: $PODSPEC"
    printf '%s\n' "$PODSPEC"
    return
  fi

  local found=""
  local count=0
  local candidate
  for candidate in *.podspec; do
    [[ -f "$candidate" ]] || continue
    found="$candidate"
    count=$((count + 1))
  done

  [[ "$count" -eq 1 ]] || die "Expected exactly one podspec in repo root, found $count. Set PODSPEC=path/to/name.podspec."
  printf '%s\n' "$found"
}

replace_podspec_values() {
  local podspec="$1"
  local version="$2"
  local summary="$3"

  if [[ "$DRY_RUN" == "1" ]]; then
    info "Would update $podspec version to $version."
    if [[ -n "$summary" ]]; then
      info "Would update $podspec summary to: $summary"
    fi
    return
  fi

  ruby - "$podspec" "$version" "$summary" <<'RUBY'
path, version, summary = ARGV
text = File.read(path)

unless text.sub!(/(\bs\.version\s*=\s*)['"][^'"]+['"]/, "\\1'#{version}'")
  abort "Could not find s.version in #{path}"
end

if summary && !summary.empty?
  unless text.sub!(/(\bs\.summary\s*=\s*)['"][^'"]*['"]/, "\\1'#{summary}'")
    abort "Could not find s.summary in #{path}"
  end
end

File.write(path, text)
RUBY
}

VERSION=""
SUMMARY=""
COMMIT_MESSAGE=""
REMOTE="origin"
DRY_RUN=0
RUN_LINT=1
ALLOW_WARNINGS=0
SKIP_IMPORT_VALIDATION=0
SKIP_TESTS=0
REPO_UPDATE=0
LINT_DEPLOYMENT_TARGET="13.0"
ENABLE_LINT_TARGET_PATCH=1
PUSH=1
TRUNK=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --summary)
      need_value "$1" "${2:-}"
      SUMMARY="$2"
      shift 2
      ;;
    --message)
      need_value "$1" "${2:-}"
      COMMIT_MESSAGE="$2"
      shift 2
      ;;
    --remote)
      need_value "$1" "${2:-}"
      REMOTE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --skip-lint)
      RUN_LINT=0
      shift
      ;;
    --allow-warnings)
      ALLOW_WARNINGS=1
      shift
      ;;
    --skip-import-validation)
      SKIP_IMPORT_VALIDATION=1
      shift
      ;;
    --skip-tests)
      SKIP_TESTS=1
      shift
      ;;
    --repo-update)
      REPO_UPDATE=1
      shift
      ;;
    --lint-deployment-target)
      need_value "$1" "${2:-}"
      LINT_DEPLOYMENT_TARGET="$2"
      shift 2
      ;;
    --no-lint-target-patch)
      ENABLE_LINT_TARGET_PATCH=0
      shift
      ;;
    --no-push)
      PUSH=0
      shift
      ;;
    --no-trunk)
      TRUNK=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      die "Unknown option: $1"
      ;;
    *)
      [[ -z "$VERSION" ]] || die "Unexpected argument: $1"
      VERSION="$1"
      shift
      ;;
  esac
done

[[ -n "$VERSION" ]] || {
  usage
  exit 1
}

COMMIT_MESSAGE="${COMMIT_MESSAGE:-Release $VERSION}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LINT_TARGET_PATCH="$SCRIPT_DIR/cocoapods_lint_deployment_target_patch.rb"
if [[ -n "${RUBYOPT:-}" ]]; then
  POD_RUBYOPT="${RUBYOPT} -r$LINT_TARGET_PATCH"
else
  POD_RUBYOPT="-r$LINT_TARGET_PATCH"
fi
cd "$REPO_ROOT"

command -v git >/dev/null 2>&1 || die "git is required."
command -v ruby >/dev/null 2>&1 || die "ruby is required."
if [[ "$DRY_RUN" == "0" ]]; then
  command -v pod >/dev/null 2>&1 || die "CocoaPods is required."
fi
if [[ "$ENABLE_LINT_TARGET_PATCH" == "1" ]]; then
  [[ -f "$LINT_TARGET_PATCH" ]] || die "Lint deployment target patch not found: $LINT_TARGET_PATCH"
fi

PODSPEC="$(detect_podspec)"

[[ -d .git ]] || die "Run this script from a git repository."
git remote get-url "$REMOTE" >/dev/null 2>&1 || die "Git remote not found: $REMOTE"

BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null || true)"
[[ -n "$BRANCH" ]] || die "Cannot release from a detached HEAD."

git update-index -q --refresh || true
if [[ -n "$(git status --porcelain)" ]]; then
  if [[ "$DRY_RUN" == "1" ]]; then
    info "Working tree is not clean. A real release would stop here."
  else
    die "Working tree is not clean. Commit or stash local changes before releasing."
  fi
fi

if git rev-parse -q --verify "refs/tags/$VERSION" >/dev/null; then
  if [[ "$DRY_RUN" == "1" ]]; then
    info "Local git tag already exists: $VERSION. A real release would stop here."
  else
    die "Local git tag already exists: $VERSION"
  fi
fi

info "Releasing $PODSPEC version $VERSION from branch $BRANCH."
replace_podspec_values "$PODSPEC" "$VERSION" "$SUMMARY"

PODSPEC_CHANGED=1
if [[ "$DRY_RUN" == "1" ]]; then
  if podspec_has_release_values "$PODSPEC" "$VERSION" "$SUMMARY"; then
    PODSPEC_CHANGED=0
    info "$PODSPEC already has version $VERSION. A real release would skip the version commit."
  fi
elif git diff --quiet -- "$PODSPEC"; then
  PODSPEC_CHANGED=0
  info "$PODSPEC already has version $VERSION. Skipping version commit."
fi

COCOAPODS_ARGS=()
COCOAPODS_ARGS_COUNT=0
if [[ "$ALLOW_WARNINGS" == "1" ]]; then
  COCOAPODS_ARGS+=(--allow-warnings)
  COCOAPODS_ARGS_COUNT=$((COCOAPODS_ARGS_COUNT + 1))
fi
if [[ "$SKIP_IMPORT_VALIDATION" == "1" ]]; then
  COCOAPODS_ARGS+=(--skip-import-validation)
  COCOAPODS_ARGS_COUNT=$((COCOAPODS_ARGS_COUNT + 1))
fi
if [[ "$SKIP_TESTS" == "1" ]]; then
  COCOAPODS_ARGS+=(--skip-tests)
  COCOAPODS_ARGS_COUNT=$((COCOAPODS_ARGS_COUNT + 1))
fi
if [[ "$REPO_UPDATE" == "1" ]]; then
  COCOAPODS_ARGS+=(--repo-update)
  COCOAPODS_ARGS_COUNT=$((COCOAPODS_ARGS_COUNT + 1))
fi

if [[ "$RUN_LINT" == "1" ]]; then
  run_pod_with_cocoapods_args lib lint "$PODSPEC"
else
  info "Skipping pod lib lint."
fi

if [[ "$PODSPEC_CHANGED" == "1" ]]; then
  run git add "$PODSPEC"
  run git commit -m "$COMMIT_MESSAGE"
else
  info "Skipping git add/commit."
fi
run git tag "$VERSION"

if [[ "$PUSH" == "1" ]]; then
  run git push "$REMOTE" "HEAD:$BRANCH"
  run git push "$REMOTE" "$VERSION"
else
  info "Skipping git push."
fi

if [[ "$TRUNK" == "1" ]]; then
  run_pod_with_cocoapods_args trunk push "$PODSPEC"
else
  info "Skipping pod trunk push."
fi

info "Release flow finished for $VERSION."
