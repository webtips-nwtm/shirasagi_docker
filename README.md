# Shirasagi Docker (Main)

このリポジトリは、[Shirasagi](https://shirasagi.github.io/) (Rails + Unicorn) を Docker 上で構築・運用するための環境を整備しています。  
Nginx + Unicorn + MongoDB を Docker Compose で起動し、Makefile を用いて各種操作を簡便に行えるようにしています。

---

## 前提条件

- [Docker](https://docs.docker.com/get-docker/) (推奨: v20 以上)
- [Docker Compose](https://docs.docker.com/compose/install/) (推奨: v1.29 以上)
- [Make](https://www.gnu.org/software/make/) (Unix系OS・WSLなどで利用可能)
- Git コマンドラインで `git submodule` コマンドが使用可能

---

```
├── app
│   ├── Dockerfile
│   ├── Dockerfile.bak.20250205
│   ├── Dockerfile.bak.20250206
│   ├── Dockerfile.mecab
│   ├── shirasagi
│   └── vendor
│       ├── hts_engine_API-1.08.tar.gz
│       ├── lame-3.99.5.tar.gz
│       ├── mecab-0.996.tar.gz
│       ├── mecab-ipadic-2.7.0-20070801.patch
│       ├── mecab-ipadic-2.7.0-20070801.tar.gz
│       ├── mecab-ruby-0.996.tar.gz
│       ├── open_jtalk-1.07.tar.gz
│       └── sox-14.4.1.tar.gz
├── compose.yml
├── db
│   └── data
└── nginx
    ├── Dockerfile
    ├── conf.d
    │   ├── common
    │   ├── header.conf
    │   ├── http.conf
    │   ├── server
    │   └── virtual.conf
    └── log
        ├── access.log
        └── error.log

```

---

## セットアップ手順

1~6を実行するとブラウザ上でhttp://172.20.0.4 にアクセス可能になります。

<<<<<<< HEAD

### 1. リポジトリのクローン

```bash
git clone --depth 1 --branch v1.19.1 --single-branch https://github.com/webtips-nwtm/shirasagi_docker.git
cd shirasagi_docker
```

### 2. サブモジュールの初期化・更新

```bash
git submodule init
git submodule update --recursive
```

### 3. Docker イメージのビルド

======= 5. 区分の検索でloginを検索し、チェックボックスを有効化
![集計画面3](https://github.com/webtips-nwtm/dev-riken/blob/images/3.png)

6. 検索結果をsheet1にコピー

7. [データ]の[重複を削除]で、ユーザー列のみをチェックし重複を削除
   ![集計画面4](https://github.com/webtips-nwtm/dev-riken/blob/images/4.png)

8. ユーザーの件数を集計

9. cpuタブ
   https://160.16.115.64/zabbix.php?name=load%20average%20(15m%20avg)&evaltype=0&tags%5B0%5D%5Btag%5D=&tags%5B0%5D%5Boperator%5D=0&tags%5B0%5D%5Bvalue%5D=&show_tags=3&tag_name_format=0&tag_priority=&filter_name=CPU(LoadAverate)&filter_show_counter=1&filter_custom_time=0&sort=name&sortorder=ASC&show_details=0&action=latest.view&hostids%5B%5D=10517&hostids%5B%5D=10518&hostids%5B%5D=10519&hostids%5B%5D=10520&hostids%5B%5D=10521&hostids%5B%5D=10522&hostids%5B%5D=10523&hostids%5B%5D=10525
10. MEMタブ
    https://160.16.115.64/zabbix.php?name=Available%20memory&evaltype=0&tags%5B0%5D%5Btag%5D=&tags%5B0%5D%5Boperator%5D=0&tags%5B0%5D%5Bvalue%5D=&show_tags=3&tag_name_format=0&tag_priority=&filter_name=Available%20memory&filter_show_counter=1&filter_custom_time=0&sort=name&sortorder=ASC&show_details=0&action=latest.view&hostids%5B%5D=10517&hostids%5B%5D=10518&hostids%5B%5D=10519&hostids%5B%5D=10520&hostids%5B%5D=10521&hostids%5B%5D=10522&hostids%5B%5D=10523&hostids%5B%5D=10525
11. DiskIO
    https://160.16.115.64/zabbix.php?name=CPU%20iowait%20time&evaltype=0&tags%5B0%5D%5Btag%5D=&tags%5B0%5D%5Boperator%5D=0&tags%5B0%5D%5Bvalue%5D=&show_tags=3&tag_name_format=0&tag_priority=&filter_name=CPU%20iowait%20time&filter_show_counter=0&filter_custom_time=0&sort=name&sortorder=ASC&show_details=0&action=latest.view&hostids%5B%5D=10519&hostids%5B%5D=10521&hostids%5B%5D=10523
    > > > > > > > e1edb24 (docs(設定ファイル): ✏ 手順書修正)

```bash
docker compose build
```

### 4. コンテナの起動

```bash
docker compose up -d
```

### 6. Makefile を使ったセットアップ

```bash
make all
```

---

## Makefile の主なターゲット

### 1. DB 関連

| ターゲット         | 説明                                                |
| ------------------ | --------------------------------------------------- |
| `make db-reset`    | MongoDB のデータベースを削除                        |
| `make db-setup`    | MongoDB のインデックスを作成                        |
| `make create-site` | Shirasagi 上にサイトを作成                          |
| `make db-seed`     | 初期データを投入                                    |
| `make db-all`      | `db-reset` → `db-setup` → `create-site` → `db-seed` |

### 2. Shirasagi (Unicorn) 関連

| ターゲット             | 説明                                                 |
| ---------------------- | ---------------------------------------------------- |
| `make shirasagi-setup` | Gem インストール & アセットプリコンパイル & デプロイ |
| `make unicorn-start`   | Unicorn を手動起動し、Nginx を再起動                 |
| `make unicorn-stop`    | Unicorn を停止                                       |
| `make shirasagi-start` | `shirasagi-setup` → `unicorn-start` の順で実行       |

### 3. 総合

| ターゲット | 説明                                                          |
| ---------- | ------------------------------------------------------------- |
| `make all` | `shirasagi-start` → `db-all` を順に実行し、環境をセットアップ |

---

## ログの確認

| ログ種類                    | コマンド                       |
| --------------------------- | ------------------------------ |
| Shirasagi / Rails (Unicorn) | `docker compose logs -f app`   |
| Nginx                       | `docker compose logs -f nginx` |
| MongoDB                     | `docker compose logs -f mongo` |

---

## コンテナの停止 / 削除

| コマンド                 | 説明                   |
| ------------------------ | ---------------------- |
| `docker compose stop`    | コンテナの停止         |
| `docker compose restart` | コンテナの再起動       |
| `docker compose down`    | コンテナの削除         |
| `docker compose down -v` | ボリュームを含めた削除 |

---

## サブモジュールの管理

| コマンド                                | 説明                           |
| --------------------------------------- | ------------------------------ |
| `git submodule init`                    | サブモジュールを初期化         |
| `git submodule update --recursive`      | サブモジュールを更新           |
| `git submodule update --remote --merge` | 最新の変更を取り込む           |
| `git add <submodule_dir> && git commit` | サブモジュールの変更をコミット |

---
