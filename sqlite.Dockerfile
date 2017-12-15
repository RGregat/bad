FROM rhardih/stand:r10e--android-21--arm-linux-androideabi-4.9

RUN apt-get update && apt-get -y install \
  wget \
  tcl

RUN wget -O sqlite.tar.gz https://www.sqlite.org/src/tarball/sqlite.tar.gz?r=release && \
      tar -xzvf sqlite.tar.gz && \
      rm sqlite.tar.gz

WORKDIR /sqlite

ENV PATH $PATH:/android-21-toolchain/bin

# Acquire newer versions of .guess and .sub files for configure

RUN wget -O config.guess \
  https://raw.githubusercontent.com/gcc-mirror/gcc/master/config.guess

RUN wget -O config.sub \
  https://raw.githubusercontent.com/gcc-mirror/gcc/master/config.sub

RUN ./configure --host=arm-linux-androideabi --prefix=/sqlite-build/ \
  --disable-tcl

RUN make && make install