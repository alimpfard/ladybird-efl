#!/bin/sh

: ${JAKT_HOME:=/usr/local/jakt}
: ${JAKT:=${JAKT_HOME}/bin/jakt}

if [ -n "$SERENITY_SOURCE_DIR" ]; then
    lagom_source_dir="$SERENITY_SOURCE_DIR"
    lagom_build_dir="$SERENITY_SOURCE_DIR/Build/lagom"
else
    mkdir _deps
    git clone https://github.com/serenityos/serenity --depth 1 _deps/serenity
    cmake -B _deps/serenity/Build -S _deps/serenity/Lagom
    lagom_source_dir="$(realpath _deps/serenity)"
    lagom_build_dir="$(realpath _deps/serenity/Build)"
fi

cmake --build "$lagom_build_dir"

${JAKT} ${1:-src/main.jakt} \
    -J "$(nproc)" \
    -d \
    -I "${JAKT_HOME}/runtime" \
    -I /opt/clang/lib/clang/17/include \
    $(pkg-config --cflags --libs elementary | sed -e 's/-pthread/-lpthread/g') \
    -I "$lagom_source_dir" \
    -I "$lagom_source_dir/Userland/Libraries" \
    -I "$lagom_build_dir/Userland/Libraries" \
    -I "$lagom_build_dir" \
    -L "$lagom_build_dir/lib" \
    -Wl-rpath="$lagom_build_dir/lib" \
    -llagom-core -llagom-gfx -llagom-webview -llagom-ipc \
    --ak-is-my-only-stdlib \
    -o main
