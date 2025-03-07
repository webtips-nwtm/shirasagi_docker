#############################################
# Stage 1: MeCab 本体および mecab-ipadic のビルド
#############################################
FROM ruby:2.7-bullseye AS mecab-build
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential automake libtool pkg-config patch wget curl file && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /usr/local/src
# MeCab 本体
COPY vendor/mecab-0.996.tar.gz .
RUN tar -xzf mecab-0.996.tar.gz && \
    cd mecab-0.996 && \
    ./configure --enable-utf8-only && \
    make && \
    make install && \
    ldconfig
# mecab-ipadic（パッチファイルも同じディレクトリに配置）
COPY vendor/mecab-ipadic-2.7.0-20070801.tar.gz .
COPY vendor/mecab-ipadic-2.7.0-20070801.patch .
RUN tar -xzf mecab-ipadic-2.7.0-20070801.tar.gz && \
    cd mecab-ipadic-2.7.0-20070801 && \
    patch -p1 < ../mecab-ipadic-2.7.0-20070801.patch && \
    ./configure --with-charset=UTF-8 && \
    make && \
    make install && \
    ldconfig

#############################################
# Stage 2: Audio 関連ソフトのビルド
# （lame, sox, hts_engine_API, open_jtalk）
#############################################
FROM ruby:2.7-bullseye AS audio-build
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential automake libtool pkg-config patch wget curl file && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /usr/local/src

# lame のビルド
COPY vendor/lame-3.99.5.tar.gz .
RUN tar -xzf lame-3.99.5.tar.gz && \
    cd lame-3.99.5 && \
    ./configure && \
    make && \
    make install && \
    echo "Installed lame:" && \
    find /usr/local/bin -name 'lame*'

# sox のビルド
COPY vendor/sox-14.4.1.tar.gz .
RUN tar -xzf sox-14.4.1.tar.gz && \
    cd sox-14.4.1 && \
    ./configure && \
    make && \
    make install && \
    echo "Installed sox:" && \
    find /usr/local/bin -name 'sox*'

# hts_engine_API のビルド
COPY vendor/hts_engine_API-1.08.tar.gz .
RUN tar -xzf hts_engine_API-1.08.tar.gz && \
    cd hts_engine_API-1.08 && \
    ./configure && \
    make && \
    make install && \
    echo "Installed hts_engine_API:" && \
    find /usr/local/bin -type f -executable -name 'hts_engine_API*'

# open_jtalk のビルド
COPY vendor/open_jtalk-1.07.tar.gz .
RUN tar -xzf open_jtalk-1.07.tar.gz && \
    cd open_jtalk-1.07 && \
    sed -i "s/#define MAXBUFLEN 1024/#define MAXBUFLEN 10240/" bin/open_jtalk.c && \
    sed -i "s/0x00D0 SPACE/0x000D SPACE/" mecab-naist-jdic/char.def && \
    ./configure --with-charset=UTF-8 && \
    make && \
    make install && \
    ldconfig && \
    echo "Installed open_jtalk:" && \
    find /usr/local/bin -name 'open_jtalk*' && \
    echo "Open JTalk 辞書（dic）:" && \
    find /usr/local/src/open_jtalk-1.07 -type d -name "dic"

#############################################
# Stage 3: mecab‑ruby 拡張のビルド
#############################################
FROM ruby:2.7-bullseye AS mecab-ruby-build
RUN apt-get update && \
    apt-get install -y --no-install-recommends pkg-config && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /usr/local/src
# mecab-build の成果物をコピー
COPY --from=mecab-build /usr/local /usr/local
# mecab‑ruby 拡張
COPY vendor/mecab-ruby-0.996.tar.gz .
RUN tar -xzf mecab-ruby-0.996.tar.gz && \
    cd mecab-ruby-0.996 && \
    ruby extconf.rb --with-mecab-config=/usr/local/bin/mecab-config && \
    make && \
    make install && \
    ldconfig
RUN find /usr/local/lib/ruby -name "MeCab.so"

#############################################
# Stage 4: 本番環境用ランタイムイメージ
#############################################
FROM ruby:2.7 AS runtime
# 必要なパッケージと Yarn のインストール（apt 経由）
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      libmecab-dev \
      lame \
      sox \
      git \
      curl \
      gnupg && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /var/www/shirasagi

# GLIBC のバージョン依存の問題を回避するため、必要なバイナリのみコピー
# MeCab バイナリとライブラリ
COPY --from=mecab-build /usr/local/bin/mecab* /usr/local/bin/
COPY --from=mecab-build /usr/local/lib/libmecab* /usr/local/lib/
# 辞書・設定ファイルもコピー（/usr/local/etc/mecabrc と /usr/local/lib/mecab を含む）
COPY --from=mecab-build /usr/local/etc/mecabrc /usr/local/etc/mecabrc
COPY --from=mecab-build /usr/local/lib/mecab /usr/local/lib/mecab

# Audio 関連の実行ファイル
COPY --from=audio-build /usr/local/bin/lame /usr/local/bin/
COPY --from=audio-build /usr/local/bin/sox /usr/local/bin/
COPY --from=audio-build /usr/local/bin/open_jtalk /usr/local/bin/open_jtalk

# Open JTalk の辞書・設定ファイル（/usr/local/dic が正しい場合）
COPY --from=audio-build /usr/local/dic /usr/local/dic
# 必要な共有ライブラリのコピー（sox のライブラリ）
COPY --from=audio-build /usr/local/lib/libsox.so.2 /usr/local/lib/
COPY --from=audio-build /usr/local/lib/libsox.so.2* /usr/local/lib/
# ライブラリキャッシュの更新
RUN ldconfig

# Ruby 用 MeCab 拡張
COPY --from=mecab-ruby-build /usr/local/lib/ruby/site_ruby/ /usr/local/lib/ruby/site_ruby/

# 環境変数の設定
ENV PKG_CONFIG_PATH=/usr/lib/pkgconfig:$PKG_CONFIG_PATH
ENV RUBYLIB=/usr/local/lib/ruby/site_ruby

CMD ["bash"]

