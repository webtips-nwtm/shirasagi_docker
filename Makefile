unicorn_start:
	docker compose exec app rm -rf /shirasagi/tmp/pids
	docker compose exec app rm -rf /shirasagi/tmp/sockets
	docker compose exec app bundle exec rake unicorn:start
	docker compose restart nginx
unicorn_stop:
	docker compose exec app bundle exec rake unicorn:stop
	docker compose exec app rm -rf /shirasagi/tmp/pids
	docker compose exec app rm -rf /shirasagi/tmp/sockets
db_init:
	./dbinit.sh
	docker compose exec db mongorestore /backup/mongodump
