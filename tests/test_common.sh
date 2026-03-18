#!/usr/bin/env bash
# Unit tests for lib/common.sh
# Run: bash tests/test_common.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"
source "$LIB_DIR/common.sh"

TESTS_PASSED=0
TESTS_FAILED=0
TEST_TEMP_DIR=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

cleanup() {
  if [[ -n "$TEST_TEMP_DIR" && -d "$TEST_TEMP_DIR" ]]; then
    rm -rf "$TEST_TEMP_DIR"
  fi
}
trap cleanup EXIT

setup() {
  TEST_TEMP_DIR=$(mktemp -d)
}

assert_equals() {
  local expected="$1"
  local actual="$2"
  local test_name="${3:-assertion}"
  
  if [[ "$expected" == "$actual" ]]; then
    echo -e "${GREEN}✓${NC} $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo -e "${RED}✗${NC} $test_name"
    echo "  Expected: $expected"
    echo "  Actual:   $actual"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_success() {
  local test_name="$1"
  echo -e "${GREEN}✓${NC} $test_name"
  TESTS_PASSED=$((TESTS_PASSED + 1))
}

assert_failure() {
  local test_name="$1"
  echo -e "${GREEN}✓${NC} $test_name (expected failure)"
  TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_has_embeddings_no_meta() {
  local test_dir="$TEST_TEMP_DIR/no-meta"
  mkdir -p "$test_dir"
  
  if _has_embeddings "$test_dir"; then
    echo -e "${RED}✗${NC} _has_embeddings returns false when meta.json missing"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  else
    assert_failure "_has_embeddings returns false when meta.json missing"
  fi
}

test_has_embeddings_zero() {
  local test_dir="$TEST_TEMP_DIR/zero-embeddings"
  mkdir -p "$test_dir/.gitnexus"
  echo '{"stats":{"embeddings":0}}' > "$test_dir/.gitnexus/meta.json"
  
  if _has_embeddings "$test_dir"; then
    echo -e "${RED}✗${NC} _has_embeddings returns false when embeddings=0"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  else
    assert_failure "_has_embeddings returns false when embeddings=0"
  fi
}

test_has_embeddings_present() {
  local test_dir="$TEST_TEMP_DIR/with-embeddings"
  mkdir -p "$test_dir/.gitnexus"
  echo '{"stats":{"embeddings":42}}' > "$test_dir/.gitnexus/meta.json"
  
  if _has_embeddings "$test_dir"; then
    assert_success "_has_embeddings returns true when embeddings > 0"
  else
    echo -e "${RED}✗${NC} _has_embeddings returns true when embeddings > 0"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

test_embedding_flag_empty() {
  local test_dir="$TEST_TEMP_DIR/no-flag"
  mkdir -p "$test_dir/.gitnexus"
  echo '{"stats":{"embeddings":0}}' > "$test_dir/.gitnexus/meta.json"
  
  local result
  result=$(embedding_flag "$test_dir")
  assert_equals "" "$result" "embedding_flag returns empty string when embeddings=0"
}

test_embedding_flag_present() {
  local test_dir="$TEST_TEMP_DIR/with-flag"
  mkdir -p "$test_dir/.gitnexus"
  echo '{"stats":{"embeddings":100}}' > "$test_dir/.gitnexus/meta.json"
  
  local result
  result=$(embedding_flag "$test_dir")
  assert_equals "--embeddings" "$result" "embedding_flag returns --embeddings when embeddings > 0"
}

test_is_dirty_repo_not_git() {
  local test_dir="$TEST_TEMP_DIR/not-git"
  mkdir -p "$test_dir"
  
  if is_dirty_repo "$test_dir"; then
    echo -e "${RED}✗${NC} is_dirty_repo returns false for non-git dir"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  else
    assert_failure "is_dirty_repo returns false for non-git dir"
  fi
}

test_is_dirty_repo_clean() {
  local test_dir="$TEST_TEMP_DIR/clean-repo"
  mkdir -p "$test_dir"
  (cd "$test_dir" && git init -q && git config user.email "test@test.com" && git config user.name "Test" && touch README.md && git add . && git commit -q -m "init")
  
  if is_dirty_repo "$test_dir"; then
    echo -e "${RED}✗${NC} is_dirty_repo returns false for clean repo"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  else
    assert_failure "is_dirty_repo returns false for clean repo"
  fi
}

test_is_dirty_repo_dirty() {
  local test_dir="$TEST_TEMP_DIR/dirty-repo"
  mkdir -p "$test_dir"
  (cd "$test_dir" && git init -q && git config user.email "test@test.com" && git config user.name "Test" && touch README.md && git add . && git commit -q -m "init" && echo "change" >> README.md)
  
  if is_dirty_repo "$test_dir"; then
    assert_success "is_dirty_repo returns true for dirty repo"
  else
    echo -e "${RED}✗${NC} is_dirty_repo returns true for dirty repo"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

test_skip_empty_repo_no_git() {
  local test_dir="$TEST_TEMP_DIR/no-git-skip"
  mkdir -p "$test_dir"
  
  if skip_empty_repo "$test_dir"; then
    assert_success "skip_empty_repo returns true for non-git dir"
  else
    echo -e "${RED}✗${NC} skip_empty_repo returns true for non-git dir"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

test_skip_empty_repo_empty() {
  local test_dir="$TEST_TEMP_DIR/empty-repo"
  mkdir -p "$test_dir"
  (cd "$test_dir" && git init -q)
  
  if skip_empty_repo "$test_dir"; then
    assert_success "skip_empty_repo returns true for empty repo (no commits)"
  else
    echo -e "${RED}✗${NC} skip_empty_repo returns true for empty repo"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

test_skip_empty_repo_with_commits() {
  local test_dir="$TEST_TEMP_DIR/repo-with-commits"
  mkdir -p "$test_dir"
  (cd "$test_dir" && git init -q && git config user.email "test@test.com" && git config user.name "Test" && touch README.md && git add . && git commit -q -m "init")
  
  if skip_empty_repo "$test_dir"; then
    echo -e "${RED}✗${NC} skip_empty_repo returns false for repo with commits"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  else
    assert_failure "skip_empty_repo returns false for repo with commits"
  fi
}

# Run tests
echo "Running tests for lib/common.sh..."
echo

setup

test_has_embeddings_no_meta
test_has_embeddings_zero
test_has_embeddings_present
test_embedding_flag_empty
test_embedding_flag_present
test_is_dirty_repo_not_git
test_is_dirty_repo_clean
test_is_dirty_repo_dirty
test_skip_empty_repo_no_git
test_skip_empty_repo_empty
test_skip_empty_repo_with_commits

echo
echo "=========================================="
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
echo "=========================================="

if [[ $TESTS_FAILED -gt 0 ]]; then
  exit 1
fi
