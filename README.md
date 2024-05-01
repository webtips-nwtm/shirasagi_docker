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

3. ダウンロードしたファイルを提出用.csvと集計用.xlxsにリネーム

4. 集計用.xlsxを使用する。<br>1行目を選択しフィルター機能を有効化
   ![集計画面1](https://github.com/webtips-nwtm/dev-riken/blob/images/1.png)

5. 区分の検索でloginを検索し、チェックボックスを有効化
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

## rawデータ提出方法

- 提出用のCSVファイルをサーバにアップロード
  - ダウンロードフォルダが~/downloadの場合
  ```
  # scp ~/download/gws_histories_$(date +%Y%m).csv root@35.73.67.250:/var/www/files/download/
  ```
