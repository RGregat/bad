FROM rhardih/stand:r10e--android-21--arm-linux-androideabi-4.9

RUN apt-get update && apt-get -y install \
  wget \
  automake \
  libtool \
  pkg-config

RUN wget -O 1.74.4.tar.gz \
      https://github.com/DanBloomberg/leptonica/archive/1.74.4.tar.gz && \
      tar -xzvf 1.74.4.tar.gz && \
      rm 1.74.4.tar.gz

WORKDIR /leptonica-1.74.4

ENV PATH $PATH:/android-21-toolchain/bin

RUN ./autobuild

RUN ./configure \
      --host=arm-linux-androideabi \
      --disable-programs \
      --without-zlib \
      --without-libpng \
      --without-jpeg \
      --without-giflib \
      --without-libtiff \
      --without-libwebp \
      --without-libopenjpeg \
      --prefix=/leptonica-build/

RUN make && make install