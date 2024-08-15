export COMPOSE_FILE := local.yml

buildlocal:
	docker compose build

# Notice that the `runlocal` target does not rebuild the images(--build) before running
# the containers. For that, use `make buildrunlocal`
runlocal:
	@docker compose up -d

buildrunlocal:
	@docker compose up --build -d

# Does not run in background mode
buildrunlocalx:
	@docker compose up --build

stoplocal:
	@docker compose down

localps:
	@docker compose ps

sync_mhp_spec:
	@docker compose run --rm django python manage.py runscript sync_specialities

sync_social_apps:
	docker compose run --rm django python manage.py runscript sync_social_apps

migrations:
	@docker compose run --rm django python manage.py makemigrations

migrate:
	@docker compose run --rm django python manage.py migrate

pre-commit:
	@docker compose run --rm django pre-commit run --show-diff-on-failure --color=always --all-files

test:
	@export COVERAGE=$$(docker compose -f local.yml run --rm -ti django bash -c "coverage run -m pytest && coverage report" | tee /dev/tty | grep TOTAL) && \
	python update_coverage_badge.py $$(echo $$COVERAGE | awk '{print $$4}' | sed 's/%//')

django-shell:
	@docker compose run --rm django python manage.py shell

bash:
	@docker compose run --rm django bash

coverage-html-report: test
	@docker compose run --rm django coverage html -d coverage_html