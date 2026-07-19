#!/usr/bin/env bash
set -eu

VERSION="main"
RELEASE="https://github.com/erincatto/box3d/archive/refs/heads/$VERSION.tar.gz"

cd "$(dirname "$0")"

curl -O -L "$RELEASE"
tar -xzvf "$VERSION.tar.gz"

cd "box3d-$VERSION"

FLAGS="-DCMAKE_BUILD_TYPE=Release -DBOX3D_SAMPLES=OFF -DBOX3D_BENCHMARKS=OFF -DBOX3D_UNIT_TESTS=OFF -DBOX3D_DOCS=OFF -DBOX3D_VALIDATE=OFF"

build() {
	rm -rf build
	mkdir build
	cmake $FLAGS "$@" -S . -B build
	cmake --build build
}

case "$(uname -s)" in
Darwin)
	export MACOSX_DEPLOYMENT_TARGET="11"

	case "$(uname -m)" in
	"x86_64" | "amd64")
		build -DCMAKE_OSX_ARCHITECTURES=x86_64
		cp build/src/libbox3d.a ../lib/box3d_darwin_amd64.a
		;;
	*)
		build -DCMAKE_OSX_ARCHITECTURES=arm64
		cp build/src/libbox3d.a ../lib/box3d_darwin_arm64.a
		;;
	esac
	;;
*)
	case "$(uname -m)" in
	"x86_64" | "amd64")
		build
		cp build/src/libbox3d.a ../lib/box3d_other_amd64.a
		;;
	*)
		build
		cp build/src/libbox3d.a ../lib/box3d_other.a
		;;
	esac
	;;
esac

cd ..

set +e
make -f wasm.Makefile
if [[ $? -ne 0 ]]; then
	printf "\e[30;43mwarning:\e[0m Native Box3D libraries were built successfully, the WASM build failed, likely because your default C compiler and/or linker doesn't support WASM, you can set the CC and LD environment variables to point to a compiler and linker that support it\n"
fi
make -f wasm.Makefile clean
set -e

rm -rf "$VERSION.tar.gz"
rm -rf box3d-"$VERSION"
