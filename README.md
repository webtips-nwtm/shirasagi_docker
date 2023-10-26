# webtips-nwtm/dev-riken

## 環境構築

1. リモートリポジトリからクローン
   ```
   # git clone https://github.com/webtips-nwtm/dev-riken.git
   ```
2. データとプログラムをapp/にコピー
3. dumpファイルをdb/backupにコピー
4. コンテナを立ち上げunicornを立ち上げる。

   ```
   カレントディレクトリ
   # docker compose up -d --build
   # make unicorn_start

   ```

5. mongodbにrestoreする。
   ```
   # docker compose exec app bundle exec rake db:drop
   # docker compose exec db mongorestore {ダンプファイル名}
   ```

## 集計方法

1. 管理画面にアクセス<br>
   http://localhost/.g1/login?user=guest

2. データダウンロード画面で期間を指定し、メッセージのチェックボックスを外して、文字コードをUTF-8を選択しダウンロード<br>
   http://localhost/.g1/gws/histories/-/download<br>
   ![ダウンロード画面](https://github.com/webtips-nwtm/dev-riken/blob/images/download.png)

3. ダウンロードしたファイルを提出用(gws*histories*%Y%m.csv)と集計用.xlxsにリネーム

4. 集計用.xlsxを使用する。<br>1行目を選択しフィルター機能を有効化
   ![集計画面1](https://github.com/webtips-nwtm/dev-riken/blob/images/1.png)

5. Rk uidの空白セルのチェックボックスを外す
   ![集計画面2](https://github.com/webtips-nwtm/dev-riken/blob/images/2.png)

6. コントローラーの検索でgws/portal/main_controllerを検索し、チェックボックスを有効化
   ![集計画面3](https://github.com/webtips-nwtm/dev-riken/blob/images/3.png)

7. 検索結果をsheet1にコピー

8. [データ]の[重複を削除]で、ユーザー列のみをチェックし重複を削除
   ![集計画面4](https://github.com/webtips-nwtm/dev-riken/blob/images/4.png)

9. ユーザーの件数を集計

## rawデータ提出方法

- 提出用のCSVファイルをサーバにアップロード
  - ダウンロードフォルダが~/downloadの場合
  ```
  # scp ~/download/gws_histories_202309.csv root@35.73.67.250:/var/www/download/
  ```
