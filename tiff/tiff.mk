tiff-x86/%:
	docker build --build-arg VERSION=${@F} \
		--build-arg STAND_TAG=r10e--android-21--x86-4.9 \
		--build-arg HOST=i686-linux-android \
		-t bad-tiff:${@F}-x86 -f tiff/tiff.Dockerfile ${BUILD_ARGS} .

tiff-armv7-a/%:
	docker build --build-arg VERSION=${@F} \
		-t bad-tiff:${@F}-armv7-a -f tiff/tiff.Dockerfile ${BUILD_ARGS} .
