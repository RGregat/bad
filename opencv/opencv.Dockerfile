ARG STAND_TAG=r10e--android-21--arm-linux-androideabi-4.9
ARG ARCH=armv7-a

FROM bad-leptonica:1.74.4-$ARCH AS leptonica-dep
FROM bad-tesseract:3.02.02-$ARCH AS tesseract-dep

FROM rhardih/stand:$STAND_TAG

ARG VERSION=3.3.1
ARG HOST=arm-linux-androideabi
ARG ANDROID_ABI=armeabi-v7a
ARG SCRIPT_NAME=cmake_android_arm
ARG SCRIPT_ARCH=arm
ARG WITH_OPENCL=ON

COPY --from=leptonica-dep /leptonica-build /leptonica-build
COPY --from=tesseract-dep /tesseract-build /tesseract-build

RUN apt-get update && apt-get -y install \
  wget \
  cmake

RUN wget -O $VERSION.tar.gz \
  https://github.com/opencv/opencv/archive/$VERSION.tar.gz && \
  tar -xzvf $VERSION.tar.gz && \
  rm $VERSION.tar.gz

RUN wget -O $VERSION.tar.gz \
  https://github.com/opencv/opencv_contrib/archive/$VERSION.tar.gz && \
  tar -xzvf $VERSION.tar.gz && \
  rm $VERSION.tar.gz

WORKDIR /opencv-$VERSION

ENV PATH $PATH:/android-21-toolchain/bin
ENV ANDROID_STANDALONE_TOOLCHAIN /android-21-toolchain

RUN mkdir -p build_android_$SCRIPT_ARCH
WORKDIR build_android_$SCRIPT_ARCH

RUN cmake \
  -DCMAKE_TOOLCHAIN_FILE=../platforms/android/android.toolchain.cmake \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib-$VERSION/modules \
  -D BUILD_SHARED_LIBS=ON \
  -D BUILD_ZLIB=ON \
  -D ANDROID_ABI=$ANDROID_ABI \
  -D ANDROID_NATIVE_API_LEVEL=21 \
  -D ANDROID_SDK_TARGET=android-25 \
  -D WITH_CAROTENE=ON \
  -D WITH_QT=ON \
  -D WITH_OPENGL=ON \
  -D CMAKE_BUILD_TYPE=Release \
  -D BUILD_TESTS=OFF \
  -D BUILD_PERF_TESTS=OFF \
  -D BUILD_ANDROID_EXAMPLES=OFF \
  -D WITH_TESSERACT=ON \
  -D Tesseract_INCLUDE_DIR=/tesseract-build/include \
  -D Tesseract_LIBRARY=/tesseract-build/libtesseract.so \
  -D Lept_LIBRARY=/leptonica-build/lib/liblept.so \
  -D 3P_LIBRARY_OUTPUT_PATH=/opencv-build/sdk/native/libs/$ANDROID_ABI/ \
  -D WITH_OPENCL=$WITH_OPENCL \
  -D CMAKE_INSTALL_PREFIX:PATH=/opencv-build \
  ..

RUN make -j2 && make install