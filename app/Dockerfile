#############################################
# Stage 0: Node.js ビルドステージ
#############################################
FROM node:20.9.0 AS node

#############################################
# Stage 1: MeCab 本体および mecab-ipadic のビルド
#############################################
FROM debian:bookworm AS mecab-build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential automake libtool pkg-config patch wget curl file && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src

ADD vendor/mecab-0.996.tar.gz /usr/local/src/
RUN cd mecab-0.996 && \
    ./configure --enable-utf8-only && \
    make && \
    make install && \
    ldconfig

ADD vendor/mecab-ipadic-2.7.0-20070801.tar.gz /usr/local/src/
COPY vendor/mecab-ipadic-2.7.0-20070801.patch /usr/local/src/
RUN cd mecab-ipadic-2.7.0-20070801 && \
    patch -p1 < ../mecab-ipadic-2.7.0-20070801.patch && \
    ./configure --with-charset=UTF-8 && \
    make && \
    make install && \
    ldconfig

#############################################
# Stage 2: Audio 関連ソフトのビルド（lame, sox, hts_engine_API, open_jtalk）
#############################################
FROM debian:bookworm AS audio-build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential automake libtool pkg-config patch wget curl file && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src

ADD vendor/lame-3.99.5.tar.gz /usr/local/src/
RUN cd lame-3.99.5 && \
    ./configure && \
    make && \
    make install

ADD vendor/sox-14.4.1.tar.gz /usr/local/src/
RUN cd sox-14.4.1 && \
    ./configure && \
    make && \
    make install

ADD vendor/hts_engine_API-1.08.tar.gz /usr/local/src/
RUN cd hts_engine_API-1.08 && \
    ./configure && \
    make && \
    make install

ADD vendor/open_jtalk-1.07.tar.gz /usr/local/src/
RUN cd open_jtalk-1.07 && \
    sed -i "s/#define MAXBUFLEN 1024/#define MAXBUFLEN 10240/" bin/open_jtalk.c && \
    sed -i "s/0x00D0 SPACE/0x000D SPACE/" mecab-naist-jdic/char.def && \
    ./configure --with-charset=UTF-8 && \
    make && \
    make install

RUN ldconfig

#############################################
# Stage 3: mecab‑ruby 拡張のビルド
#############################################
FROM ruby:3.2-bullseye AS mecab-ruby-build

RUN apt-get update && \
    apt-get install -y --no-install-recommends pkg-config && \
    rm -rf /var/lib/apt/lists/*

COPY --from=mecab-build /usr/local /usr/local

WORKDIR /usr/local/src

ADD vendor/mecab-ruby-0.996.tar.gz /usr/local/src/
RUN cd mecab-ruby-0.996 && \
    ruby extconf.rb --with-mecab-config=/usr/local/bin/mecab-config && \
    make && \
    make install && \
    ldconfig

RUN find /usr/local/lib/ruby -name "MeCab.so"

#############################################
# Stage 4: 本番環境用ランタイムイメージ
#############################################
FROM ruby:3.2 AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      libmecab-dev \
      lame \
      sox \
      git \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/shirasagi

# RUN mkdir -p config/samples && \
#     if [ -d config/samples ]; then \
#       find config/samples -type f \( -name "*.rb" -o -name "*.yml" \) -exec cp -n {} config/ \; || true; \
#     fi

COPY --from=node /opt/yarn-* /opt/yarn
COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules/ /usr/local/lib/node_modules/
RUN ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -fs /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npx && \
    ln -fs /usr/local/bin/node /usr/local/bin/nodejs && \
    ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn && \
    ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarnpkg

COPY --from=mecab-build /usr/local /usr/local
COPY --from=mecab-build /usr/lib /usr/lib

COPY --from=audio-build /usr/local /usr/local
COPY --from=audio-build /usr/lib /usr/lib

COPY --from=mecab-ruby-build /usr/local/lib/ruby/site_ruby/ /usr/local/lib/ruby/site_ruby/

ENV PKG_CONFIG_PATH=/usr/lib/pkgconfig:$PKG_CONFIG_PATH
ENV RUBYLIB=/usr/local/lib/ruby/site_ruby

CMD ["bash"]
