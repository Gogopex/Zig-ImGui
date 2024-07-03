#!/bin/bash#!/bin/bash

cd "$(dirname "$0")" || exit 1

git submodule update --init --recursive

which gcc >/dev/null || {
	echo "Couldn't find gcc, make sure it is installed and on your path."
	exit 1
}
which luajit >/dev/null || {
	echo "Couldn't find LuaJIT, make sure it is installed and on your path."
	exit 1
}
which python3 >/dev/null || {
	echo "Couldn't find python3, make sure it is installed and on your path."
	exit 1
}

echo "Generating C Bindings..."
pushd "cimgui/generator" || exit 1
rm -f ../../zig-imgui/cimgui.cpp ../../zig-imgui/cimgui.h
luajit ./generator.lua "gcc" ""
cp ../cimgui.cpp ../../zig-imgui/cimgui.cpp
cp ../cimgui.h ../../zig-imgui/cimgui.h
popd || exit 1

echo "Generating Zig Bindings..."
python3 "$(dirname "$0")/generate.py"

echo "Vendoring ImGui..."
pushd "$(dirname "$0")" || exit 1
rm -rf zig-imgui/imgui
mkdir -p zig-imgui/imgui
cp cimgui/imgui/*.h zig-imgui/imgui/
cp cimgui/imgui/*.cpp zig-imgui/imgui/
cp cimgui/imgui/LICENSE.txt zig-imgui/imgui/
popd || exit 1

pushd "cimgui/imgui" || exit 1
git rev-parse HEAD >../../zig-imgui/imgui/VERSION.txt
popd || exit 1

echo "Cleaning up..."
pushd "cimgui" || exit 1
git restore .
rm -f generator/preprocesed.h
popd || exit 1

echo "Done"
