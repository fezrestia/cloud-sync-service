#!/bin/sh -x

bundle install

yarn install

bundle exec rake assets:clobber RAILS_ENV=production
bundle exec rake assets:precompile RAILS_ENV=production

gcloud app deploy

RAILS_ENV=production bundle exec rake appengine:exec -- bundle exec rake db:migrate

