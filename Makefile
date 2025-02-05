tag: VERSION=$(shell cat build.sh | grep "BLUEZ_VER=" | sed -e 's,BLUEZ_VER="\(.*\)",\1,' | tr -d '\n')
tag: NEXT_REVISION=$(shell echo $$(( $(shell git tag -l | grep $(VERSION) | sort -r | head -n 1 | sed -e 's,.*_\(.*\),\1,') + 1 )))
tag:
	git tag $(VERSION)_$(NEXT_REVISION) HEAD
	git push origin $(VERSION)_$(NEXT_REVISION)

arm64: IMAGE_ID = ghcr.io/chipp/bluez.static.arm64_musl
arm64:
	docker build . \
		--tag $(IMAGE_ID):latest \
		--build-arg VARIANT=arm64_musl \
		--load

amd64: IMAGE_ID = ghcr.io/chipp/bluez.static.x86_64_musl
amd64:
	docker build . \
		--tag $(IMAGE_ID):latest \
		--build-arg VARIANT=x86_64_musl \
		--load

checksums: libffi libexpat zlib pcre2 glib dbus bluez

libffi: FFI_VER=$(shell cat build.sh | grep "FFI_VER=" | sed -e 's,FFI_VER="\(.*\)",\1,' | tr -d '\n')
libffi: FFI_SHA=$(shell curl -sSL https://github.com/libffi/libffi/releases/download/v$(FFI_VER)/libffi-$(FFI_VER).tar.gz | sha256sum - | tr -d '-' | tr -d ' ')
libffi:
	@sed -i '' "s/FFI_SHA=\"[0-9,a-f]*\"/FFI_SHA=\"$(FFI_SHA)\"/g" build.sh
	@echo "libffi $(FFI_VER) $(FFI_SHA)"

libexpat: EXPAT_VER=$(shell cat build.sh | grep "EXPAT_VER=" | sed -e 's,EXPAT_VER="\(.*\)",\1,' | tr -d '\n')
libexpat: EXPAT_TAG=$(shell printf R_$(shell printf $(EXPAT_VER) | tr . _))
libexpat: EXPAT_SHA=$(shell curl -sSL https://github.com/libexpat/libexpat/releases/download/$(EXPAT_TAG)/expat-$(EXPAT_VER).tar.gz | sha256sum - | tr -d '-' | tr -d ' ')
libexpat:
	@sed -i '' "s/EXPAT_SHA=\"[0-9,a-f]*\"/EXPAT_SHA=\"$(EXPAT_SHA)\"/g" build.sh
	@echo "libexpat $(EXPAT_VER) $(EXPAT_SHA)"

zlib: ZLIB_VER=$(shell cat build.sh | grep "ZLIB_VER=" | sed -e 's,ZLIB_VER=\(.*\),\1,' | tr -d '\n')
zlib: ZLIB_SHA=$(shell curl -sSL https://zlib.net/zlib-$(ZLIB_VER).tar.gz | sha256sum - | tr -d '-' | tr -d ' ')
zlib:
	@sed -i '' "s/ZLIB_SHA=\"[0-9,a-f]*\"/ZLIB_SHA=\"$(ZLIB_SHA)\"/g" build.sh
	@echo "zlib $(ZLIB_VER) $(ZLIB_SHA)"

pcre2: PCRE2_VER=$(shell cat build.sh | grep "PCRE2_VER=" | sed -e 's,PCRE2_VER=\(.*\),\1,' | tr -d '\n')
pcre2: PCRE2_SHA=$(shell curl -sSL https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE2_VER}/pcre2-${PCRE2_VER}.tar.gz | sha256sum - | tr -d '-' | tr -d ' ')
pcre2:
	@sed -i '' "s/PCRE2_SHA=\"[0-9,a-f]*\"/PCRE2_SHA=\"$(PCRE2_SHA)\"/g" build.sh
	@echo "pcre2 $(PCRE2_VER) $(PCRE2_SHA)"

glib: GLIB_VER=$(shell cat build.sh | grep "GLIB_VER=" | sed -e 's,GLIB_VER="\(.*\)",\1,' | tr -d '\n')
glib: GLIB_MAJOR_MINOR=$(shell echo $(GLIB_VER) | cut -d. -f1-2)
glib: GLIB_SHA=$(shell curl -sSL https://download.gnome.org/sources/glib/$(GLIB_MAJOR_MINOR)/glib-$(GLIB_VER).tar.xz | sha256sum - | tr -d '-' | tr -d ' ')
glib:
	@sed -i '' "s/GLIB_SHA=\"[0-9,a-f]*\"/GLIB_SHA=\"$(GLIB_SHA)\"/g" build.sh
	@echo "glib $(GLIB_VER) $(GLIB_SHA)"

dbus: DBUS_VER=$(shell cat build.sh | grep "DBUS_VER=" | sed -e 's,DBUS_VER="\(.*\)",\1,' | tr -d '\n')
dbus: DBUS_SHA=$(shell curl -sSL https://dbus.freedesktop.org/releases/dbus/dbus-$(DBUS_VER).tar.xz | sha256sum - | tr -d '-' | tr -d ' ')
dbus:
	@sed -i '' "s/DBUS_SHA=\"[0-9,a-f]*\"/DBUS_SHA=\"$(DBUS_SHA)\"/g" build.sh
	@echo "dbus $(DBUS_VER) $(DBUS_SHA)"

bluez: BLUEZ_VER=$(shell cat build.sh | grep "BLUEZ_VER=" | sed -e 's,BLUEZ_VER="\(.*\)",\1,' | tr -d '\n')
bluez: BLUEZ_SHA=$(shell curl -sSL https://www.kernel.org/pub/linux/bluetooth/bluez-${BLUEZ_VER}.tar.xz | sha256sum - | tr -d '-' | tr -d ' ')
bluez:
	@sed -i '' "s/BLUEZ_SHA=\"[0-9,a-f]*\"/BLUEZ_SHA=\"$(BLUEZ_SHA)\"/g" build.sh
	@echo "bluez $(BLUEZ_VER) $(BLUEZ_SHA)"
