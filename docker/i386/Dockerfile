FROM i386/debian:stretch

RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list \
 && sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list \
 && sed -i '/stretch-updates/d' /etc/apt/sources.list

RUN apt-get update
RUN apt-get install --quiet --yes \
    build-essential \
    curl \
    pkg-config \
    clang \
    python \
    libsecret-1-dev

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

ENV CC=clang
ENV CXX=clang++
ENV npm_config_clang=1
