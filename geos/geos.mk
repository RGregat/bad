geos-x86/%:
	docker build --build-arg VERSION=${@F} \
		--build-arg HOST=i686-linux-android \
		--build-arg TOOLCHAIN=x86-4.9 \
		-t bad-geos:${@F}-x86 -f geos/geos.Dockerfile ${BUILD_ARGS} .

geos-armv7-a/%:
	docker build --build-arg VERSION=${@F} \
		-t bad-geos:${@F}-armv7-a -f geos/geos.Dockerfile ${BUILD_ARGS} .
