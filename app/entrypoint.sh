#!/bin/bash
set -e

# server.pidが残っているとrailsが起動できないので削除する
rm -rf /shirasagi/tmp/pids /shirasagi/tmp/sokets

# コンテナーのプロセスを実行する(Dockerfile 内の CMD に設定されているもの)
exec "$@"
