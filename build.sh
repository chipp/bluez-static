#!/bin/bash

set -e
set -o pipefail

FFI_VER="3.4.6"
FFI_SHA="b0dea9df23c863a7a50e825440f3ebffabd65df1497108e5d437747843895a4e"

EXPAT_VER="2.6.4"
EXPAT_SHA="fd03b7172b3bd7427a3e7a812063f74754f24542429b634e0db6511b53fb2278"

ZLIB_VER="1.3.1"
ZLIB_SHA="9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23"

PCRE2_VER="10.44"
PCRE2_SHA="86b9cb0aa3bcb7994faa88018292bc704cdbb708e785f7c74352ff6ea7d3175b"

GLIB_VER="2.82.4"
GLIB_SHA="37dd0877fe964cd15e9a2710b044a1830fb1bd93652a6d0cb6b8b2dff187c709"

DBUS_VER="1.15.8"
DBUS_SHA="84fc597e6ec82f05dc18a7d12c17046f95bad7be99fc03c15bc254c4701ed204"

BLUEZ_VER="5.66"
BLUEZ_SHA="39fea64b590c9492984a0c27a89fc203e1cdc74866086efb8f4698677ab2b574"

curl -sSOL https://github.com/libffi/libffi/releases/download/v${FFI_VER}/libffi-${FFI_VER}.tar.gz
echo "${FFI_SHA}  libffi-${FFI_VER}.tar.gz" | sha256sum -c -
tar xfz libffi-${FFI_VER}.tar.gz
cd libffi-${FFI_VER}

./configure --host=$TARGET --prefix=$PREFIX --disable-shared --enable-static
make -j$(nproc) && make install
cd .. && rm -rf libffi-${FFI_VER}.tar.gz libffi-${FFI_VER}


EXPAT_TAG=R_$(printf ${EXPAT_VER} | tr . _)
curl -sSOL https://github.com/libexpat/libexpat/releases/download/${EXPAT_TAG}/expat-${EXPAT_VER}.tar.gz
echo "${EXPAT_SHA}  expat-${EXPAT_VER}.tar.gz" | sha256sum -c -
tar xfz expat-${EXPAT_VER}.tar.gz
cd expat-${EXPAT_VER}

./configure --host=$TARGET --prefix=$PREFIX --disable-shared --enable-static
make -j$(nproc) && make install
cd .. && rm -rf expat-${EXPAT_VER}.tar.gz expat-${EXPAT_VER}


curl -sSL -O https://zlib.net/zlib-${ZLIB_VER}.tar.gz
echo "${ZLIB_SHA}  zlib-${ZLIB_VER}.tar.gz" | sha256sum -c -
tar xfz zlib-${ZLIB_VER}.tar.gz
cd zlib-$ZLIB_VER

CC="$CC -fPIC -pie" LDFLAGS="-L$PREFIX/lib" CFLAGS="-I$PREFIX/include" \
  ./configure --static --prefix=$PREFIX
make -j$(nproc) && make install
cd .. && rm -rf zlib-${ZLIB_VER} zlib-${ZLIB_VER}.tar.gz


curl -sSL -O https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE2_VER}/pcre2-${PCRE2_VER}.tar.gz
echo "${PCRE2_SHA}  pcre2-${PCRE2_VER}.tar.gz" | sha256sum -c -
tar xfz pcre2-${PCRE2_VER}.tar.gz
cd pcre2-${PCRE2_VER}

CC="$CC -fPIC -pie" LDFLAGS="-L$PREFIX/lib" CFLAGS="-I$PREFIX/include" \
  ./configure --host=$TARGET --disable-shared --prefix=$PREFIX
make -j$(nproc) && make install
cd .. && rm -rf pcre2-${PCRE2_VER} pcre2-${PCRE2_VER}.tar.gz


GLIB_MAJOR_MINOR=$(echo $GLIB_VER | cut -d. -f1-2)
curl -sSOL https://download.gnome.org/sources/glib/${GLIB_MAJOR_MINOR}/glib-${GLIB_VER}.tar.xz
echo "${GLIB_SHA}  glib-${GLIB_VER}.tar.xz" | sha256sum -c -
tar xfJ glib-${GLIB_VER}.tar.xz
cd glib-${GLIB_VER}

pip3 install packaging
meson setup --cross-file /musl/meson.cross --prefix $PREFIX --pkg-config-path $PKG_CONFIG_PATH \
  --default-library static -Dlibmount=disabled -Dselinux=disabled \
  -Dtests=false _build
meson compile -C _build
meson install -C _build
cd .. && rm -rf glib-${GLIB_VER}.tar.xz glib-${GLIB_VER}


curl -sSOL https://dbus.freedesktop.org/releases/dbus/dbus-${DBUS_VER}.tar.xz
echo "${DBUS_SHA}  dbus-${DBUS_VER}.tar.xz" | sha256sum -c -
tar xfJ dbus-${DBUS_VER}.tar.xz
cd dbus-${DBUS_VER}

meson setup --cross-file /musl/meson.cross --prefix $PREFIX --pkg-config-path $PKG_CONFIG_PATH \
  --default-library static -Ddoxygen_docs=disabled -Dducktype_docs=disabled \
  -Dmessage_bus=false -Dxml_docs=disabled _build
meson compile -C _build
meson install -C _build
cd .. && rm -rf dbus-${DBUS_VER}.tar.gz dbus-${DBUS_VER}


curl -sSOL https://www.kernel.org/pub/linux/bluetooth/bluez-${BLUEZ_VER}.tar.xz
echo "${BLUEZ_SHA} bluez-${BLUEZ_VER}.tar.xz" | sha256sum -c -
tar xfJ bluez-${BLUEZ_VER}.tar.xz
cd bluez-${BLUEZ_VER}

patch -p0 <<EOF
--- src/shared/util.c 2022-11-10 20:24:03.000000000 +0000
+++ src/shared/util.c 2024-06-23 09:05:23.632007315 +0000
@@ -28,6 +28,11 @@
 #include <sys/random.h>
 #endif

+/* define MAX_INPUT for musl */
+#ifndef MAX_INPUT
+#define MAX_INPUT _POSIX_MAX_INPUT
+#endif
+
 #include "src/shared/util.h"

 void *util_malloc(size_t size)
EOF

./configure --host=$TARGET --prefix=$PREFIX --disable-shared --enable-static \
  --disable-test --disable-monitor --disable-tools --disable-client --disable-systemd \
  --disable-udev --disable-cups --disable-obex --enable-library --disable-manpages
make -j$(nproc) && make install
cd .. && rm -rf bluez-${BLUEZ_VER}.tar.xz bluez-${BLUEZ_VER}
