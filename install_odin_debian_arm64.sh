#!/usr/bin/env bash
#
# Bootstrap Odin (disusdev/Odin, box3d branch) on Debian aarch64.
#
#   - installs build dependencies (clang, llvm, cmake, ...)
#   - clones (or updates) the fork's box3d branch over SSH
#   - builds the native Box3D static lib for arm64  -> lib/box3d_other.a
#   - builds the Odin compiler in release mode
#   - installs `odin` onto PATH via a symlink in $PREFIX
#   - commits the freshly built arm64 lib and pushes it to the box3d branch
#
# Run it straight off the branch:
#   curl -fsSL https://raw.githubusercontent.com/disusdev/Odin/box3d/install_odin_debian_arm64.sh | bash
# or download first and run:  bash install_odin_debian_arm64.sh
#
set -euo pipefail

# --- config -----------------------------------------------------------------
REPO_SSH="${REPO_SSH:-git@github.com:disusdev/Odin.git}"
BRANCH="${BRANCH:-box3d}"
CLONE_DIR="${CLONE_DIR:-$HOME/Odin}"      # where the repo lives / will be cloned
PREFIX="${PREFIX:-/usr/local/bin}"        # where the `odin` symlink goes
PUSH_LIB="${PUSH_LIB:-1}"                 # set to 0 to skip the commit+push step
# ----------------------------------------------------------------------------

log()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

ARCH="$(uname -m)"
case "$ARCH" in
	aarch64|arm64) : ;;
	*) warn "expected aarch64, found '$ARCH' — script will still run but was written for arm64." ;;
esac

# sudo only if we are not already root
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
	command -v sudo >/dev/null 2>&1 && SUDO="sudo" || die "need root or sudo to install packages"
fi

# --- 1. dependencies --------------------------------------------------------
# build_odin.sh supports LLVM 14/17/18/19/20/21/22. Install the distro default
# clang/llvm; if that major version is unsupported, install an explicit one.
log "Installing build dependencies (apt)..."
$SUDO apt-get update -y
$SUDO apt-get install -y --no-install-recommends \
	git curl ca-certificates build-essential make cmake \
	clang llvm llvm-dev

# verify the installed LLVM major is one build_odin.sh accepts
LLVM_MAJOR="$(llvm-config --version 2>/dev/null | cut -d. -f1 || echo 0)"
case " 14 17 18 19 20 21 22 " in
	*" $LLVM_MAJOR "*) log "Using LLVM $LLVM_MAJOR" ;;
	*)
		warn "default LLVM ($LLVM_MAJOR) not in Odin's supported set; installing llvm-19."
		$SUDO apt-get install -y --no-install-recommends \
			llvm-19 llvm-19-dev clang-19 || die "could not install llvm-19; install a supported LLVM manually"
		export LLVM_CONFIG="llvm-config-19"
		;;
esac

# --- 2. clone / update ------------------------------------------------------
if [ -d "$CLONE_DIR/.git" ]; then
	log "Updating existing checkout at $CLONE_DIR"
	git -C "$CLONE_DIR" fetch origin "$BRANCH"
	git -C "$CLONE_DIR" checkout "$BRANCH"
	git -C "$CLONE_DIR" pull --ff-only origin "$BRANCH"
else
	log "Cloning $REPO_SSH ($BRANCH) into $CLONE_DIR"
	git clone --branch "$BRANCH" "$REPO_SSH" "$CLONE_DIR"
fi
cd "$CLONE_DIR"

# --- 3. build Box3D native lib for arm64 ------------------------------------
# On non-x86_64 Linux this produces lib/box3d_other.a, which is exactly the
# path vendor/box3d expects (see vendor/box3d/box3d.odin).
log "Building Box3D native library for $ARCH..."
( cd vendor/box3d && ./build_box3d.sh )
[ -f vendor/box3d/lib/box3d_other.a ] || die "box3d_other.a was not produced; check the box3d build output above"
log "Built vendor/box3d/lib/box3d_other.a"

# --- 4. build the Odin compiler ---------------------------------------------
log "Building the Odin compiler (release)..."
./build_odin.sh release
[ -x ./odin ] || die "odin binary was not produced"

# --- 5. install on PATH -----------------------------------------------------
log "Installing odin symlink into $PREFIX"
$SUDO ln -sf "$CLONE_DIR/odin" "$PREFIX/odin"
log "Installed: $("$PREFIX/odin" version 2>/dev/null || echo '(run: odin version)')"

# --- 6. push the arm64 lib back to the branch -------------------------------
if [ "$PUSH_LIB" = "1" ]; then
	if ! git diff --quiet -- vendor/box3d/lib/box3d_other.a 2>/dev/null \
	   || [ -n "$(git status --porcelain -- vendor/box3d/lib/box3d_other.a)" ]; then
		log "Committing arm64 Box3D lib and pushing to $BRANCH..."
		git config user.name  >/dev/null 2>&1 || git config user.name  "disusdev"
		git config user.email >/dev/null 2>&1 || git config user.email "zigoriloo@gmail.com"
		git add vendor/box3d/lib/box3d_other.a
		git commit -m "box3d: add prebuilt Linux arm64 static lib (box3d_other.a)"
		git push origin "$BRANCH"
		log "Pushed arm64 lib to $BRANCH"
	else
		log "arm64 lib already committed and unchanged — nothing to push."
	fi
else
	log "PUSH_LIB=0 — skipping commit/push."
fi

log "Done. Ensure $PREFIX is on your PATH, then: odin version"
