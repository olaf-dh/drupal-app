# composer
symfony-install: ## Install a symfony-skeleton
	${DC} exec app /bin/sh -c "composer create-project symfony/skeleton app"

composer-install: ## Composer install
	${DC} exec app /bin/sh -c "composer install --no-progress --no-interaction --prefer-dist --optimize-autoloader"

# database
export-db: ## create a new db-dump.
	${DC} exec database /bin/sh -c 'mysqldump --all-databases -uroot -proot' > data/sql/db.sql


# caches
cc: ## Clear Symfony cache.
	make exec app "bin/console cache:clear"

###
### Code Quality
###

test-unit: ## Run ibexa Unit tests.
	${DC} exec app /bin/sh -c "./bin/phpunit"
