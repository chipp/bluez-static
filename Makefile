tag: VERSION=$(shell cat build.sh | grep "BLUEZ_VER.*BLUEZ_SHA" | sed -e 's,BLUEZ_VER="\(.*\)" *BLUEZ_SHA=".*",\1,' | tr -d '\n')
tag: NEXT_REVISION=$(shell echo $$(( $(shell git tag -l | grep $(VERSION) | sort -r | head -n 1 | sed -e 's,.*_\(.*\),\1,') + 1 )))
tag:
	git tag $(VERSION)_$(NEXT_REVISION) HEAD
	git push origin $(VERSION)_$(NEXT_REVISION)

arm64: IMAGE_ID = ghcr.io/chipp/bluez.static.arm64_musl
arm64:
	docker build . \
		--tag ${IMAGE_ID}:latest \
		--build-arg VARIANT=arm64_musl \
		--load \
		--cache-from=type=registry,ref=${IMAGE_ID}:cache

amd64: IMAGE_ID = ghcr.io/chipp/bluez.static.x86_64_musl
amd64:
	docker build . \
		--tag ${IMAGE_ID}:latest \
		--build-arg VARIANT=x86_64_musl \
		--load \
		--cache-from=type=registry,ref=${IMAGE_ID}:cache
