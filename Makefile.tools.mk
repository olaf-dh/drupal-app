# composer
drupal-install: ## Install a new Drupal project
	rm -rf app
	composer create-project drupal/recommended-project app

composer-install: ## Composer install
	${DC} exec app /bin/sh -c "composer install --no-progress --no-interaction --prefer-dist --optimize-autoloader"

project-init: ## Initialize existing Drupal project
	make build
	make up
	make exec app "composer update"
	make import-db
	make import-conf

composer-drush: ## Install drush
	${DC} exec app /bin/sh -c "composer require drush/drush"

# database
export-db: ## create a new db-dump.
	mkdir -p "data/sql"
	${DC} exec database /bin/sh -c 'mysqldump --all-databases -udrupal_api -pdrupal_api' > data/sql/db.sql

import-db: ## import a dump into your database
	${DC} exec -T database /bin/sh -c 'mysql -udrupal_api -pdrupal_api drupal_api' < data/sql/db.sql

# drush - config export and import
export-conf: ## Export config file.
	make exec app "vendor/bin/drush cex"

import-conf: ## Import config from existing Drupal installation.
	make exec app "vendor/bin/drush cim"

# caches
cc: ## Clear and rebuild cache.
	make exec app "vendor/bin/drush cr"

###
### Code Quality
###

test-unit: ## Run ibexa Unit tests.
	${DC} exec app /bin/sh -c "./bin/phpunit"
