.PHONY: db-reset db-setup create-site db-seed db-all unicorn-start unicorn-stop shirasagi-setup shirasagi-start

# MongoDB のリセット
db-reset:
	docker compose exec app bundle exec rake db:drop

# MongoDB のセットアップ
db-setup:
	docker compose exec app bundle exec rake db:create_indexes
	docker compose exec app bundle exec rake ss:migrate


# サイトの作成
create-site:
	docker compose exec app bundle exec rake ss:create_site data='{ name: "自治体サンプル", host: "www", domains: "172.20.0.4" }'
	docker compose exec app bundle exec rake ss:create_site data='{ name: "企業サンプル", host: "company", domains: "172.20.0.4", subdir:"company", parent_id:1 }'
	docker compose exec app bundle exec rake ss:create_site data='{ name: "子育て支援サンプル", host: "childcare", domains: "172.20.0.4", subdir:"childcare", parent_id:1 }'
	docker compose exec app bundle exec rake ss:create_site data='{ name: "オープンデータサンプル", host: "opendata", domains: "172.20.0.4", subdir:"opendata", parent_id:1 }'
	docker compose exec app bundle exec rake ss:create_site data='{ name: "ＬＰサンプル", host: "lp_", domains: "172.20.0.4", subdir:"lp_", parent_id:1 }'

# 初期データの投入
db-seed:
	docker compose exec app bundle exec rake db:seed site=www name=demo
	docker compose exec app bundle exec rake db:seed site=company name=company
	docker compose exec app bundle exec rake db:seed site=childcare name=childcare
	docker compose exec app bundle exec rake db:seed site=opendata name=opendata
	docker compose exec app bundle exec rake db:seed site=lp_ name=lp
	docker compose exec app bundle exec rake cms:generate_nodes
	docker compose exec app bundle exec rake cms:generate_pages
	
# すべての DB セットアップ
db-all: db-reset db-setup create-site db-seed

# Shirasagi のセットアップ
shirasagi-setup:
	docker compose exec app bash -c "if ls config/samples/*.{rb,yml} > /dev/null 2>&1; then cp -n config/samples/*.{rb,yml} config/; fi"
	docker compose exec app bash -c "sed -i 's/localhost/db/g' config/mongoid.yml"
	docker compose exec app bundle install
	docker compose exec app bundle exec rake assets:precompile RAILS_ENV=production
	docker compose exec app bundle exec rake ss:deploy RAILS_ENV=production
	
# Unicorn を手動で起動
unicorn-start:
	docker compose exec app rm -rf /var/www/shirasagi/tmp/pids/
	docker compose exec app rm -rf /var/www/shirasagi/tmp/sockets/
	docker compose exec app mkdir -p /var/www/shirasagi/tmp/pids
	docker compose exec app mkdir -p /var/www/shirasagi/tmp/sockets
	docker compose exec app bundle exec unicorn -c config/unicorn.rb -E production -D
	docker compose restart nginx

# Unicorn を停止
unicorn-stop:
	docker compose exec app bundle exec rake unicorn:stop
	docker compose exec app rm -rf /shirasagi/tmp/pids
	docker compose exec app rm -rf /shirasagi/tmp/sockets

# Shirasagi を手動で起動
shirasagi-start: shirasagi-setup unicorn-start

# すべてをセットアップ
all: shirasagi-start db-all

