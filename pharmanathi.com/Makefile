export COMPOSE_FILE := local.yml

runlocal:
	docker compose up -d

stoplocal:
	docker compose down

localps:
	docker compose ps


sync_mhp_spec:
	docker compose run --rm django python manage.py runscript sync_specialities

migrations:
	docker compose run --rm django python manage.py makemigrations

migrate:
	docker compose run --rm django python manage.py migrate


pre-commit:
	docker compose run --rm django pre-commit run --show-diff-on-failure --color=always --all-files

test:
	docker compose run --rm django pytest

django-shell:
	docker compose run --rm django python manage.py shell

bash:
	docker compose run --rm django bash
