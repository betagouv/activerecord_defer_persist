install:
	./bin/setup

test:
	bundle exec rspec spec

deploy_gem:
	bundle exec ruby scripts/deploy_gem.rb $$VERSION
