#!/usr/bin/env bash
set -euo pipefail

NDK=${NDK:-/home/dutra/libs/android-ndk-r28c}
API=${API:-21}
APP_PKG=./app

declare -A ABIS=(
  ["arm64-v8a"]="arm64;$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android$API-clang"
  ["armeabi-v7a"]="arm;$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi$API-clang"
  ["x86"]="386;$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android$API-clang"
  ["x86_64"]="amd64;$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android$API-clang"
)

rm -rf build
mkdir -p build

echo "[INFO] Using NDK: $NDK - GO VERSION: $(go version)"
echo "[INFO] Starting Android build (API $API)"

for abi in "${!ABIS[@]}"; do
    IFS=";" read -r goarch cc <<< "${ABIS[$abi]}"
    mkdir -p "build/$abi"
    echo "[INFO] Building for $abi..."
    CC="$cc" CGO_ENABLED=1 GOOS=android GOARCH="$goarch" \
        go build -ldflags="-s -w" -trimpath -o "build/$abi/libhysteria_v2.so" "$APP_PKG"
    echo "[OK] $abi build completed → build/$abi/libhysteria_v2.so"
done

echo "[INFO] Android build completed for all ABIs"
