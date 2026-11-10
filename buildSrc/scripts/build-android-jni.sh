#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WORK="$ROOT/build/android-jni"
UPSTREAM="$WORK/imgui-java"
JNI_DIR="/tmp/imgui/jni"
OUT="$ROOT/build/android-native"

rm -rf "$WORK" "$OUT"
mkdir -p "$WORK" "$OUT"

git clone --depth 1 --branch v1.92.7.1 --recurse-submodules https://github.com/SpaiR/imgui-java.git "$UPSTREAM"
cd "$UPSTREAM"

# Reuse the upstream JNI generator so Java bindings, ImGui, ImPlot and extension
# sources are exactly the same revision as the Java binding used by ImGuiMC.
./gradlew --no-daemon :imgui-binding:generateLibs -Denvs=linux

test -d "$JNI_DIR"
cmake -S "$ROOT/buildSrc/android-jni" -B "$WORK/cmake" \
  -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-24 \
  -DIMGUI_JNI_DIR="$JNI_DIR" \
  -DCMAKE_BUILD_TYPE=Release
cmake --build "$WORK/cmake" --config Release --parallel

mkdir -p "$OUT/io/imgui/java/native-bin"
cp "$WORK/cmake/libimgui-java64.so" "$OUT/io/imgui/java/native-bin/libimgui-java64.so"
file "$OUT/io/imgui/java/native-bin/libimgui-java64.so"
readelf -h "$OUT/io/imgui/java/native-bin/libimgui-java64.so" | grep -E 'Class:|Machine:'
jar --create --file "$ROOT/build/imgui-java-natives-android-arm64.jar" -C "$OUT" .
