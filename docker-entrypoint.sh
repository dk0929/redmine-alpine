#!/bin/sh
set -e

case "$1" in
	rails|rake|passenger)
		adapter=$(ruby -e "
require 'json'
require 'yaml'
unless ENV['REDMINE_CONFIGURATION'].nil?
	conf = YAML.load_file('config/configuration.yml.example')
	conf.merge!(JSON.parse(ENV['REDMINE_CONFIGURATION']))
	YAML.dump(conf,File.open('config/configuration.yml','w'))
end
if File.exist?('config/database.yml')
	conf = YAML.load_file('config/database.yml')
	puts conf['${RAILS_ENV}']['adapter']
else
	conf = YAML.load_file('config/database.yml.example')
	conf.merge!(JSON.parse(ENV['REDMINE_DATABASE']||'{\"production\":{\"adapter\":\"sqlite3\",\"database\":\"db/redmien.sqlite3\"}}'))
	YAML.dump(conf,File.open('config/database.yml','w'))
	puts conf['${RAILS_ENV}']['adapter']
end
		")
		
		cp "Gemfile.lock.${adapter}" Gemfile.lock
		bundle check || bundle install --without development test
		rm -fr /root/.bundle /root/.gem $(gem env gemdir)/cache
		
		if [ "$1" != 'rake' ]; then
			rake generate_secret_token
			rake redmine:plugins:migrate
			rake db:migrate
		fi
		
		if [ "$1" = 'passenger' ]; then
			set -- tini -- "$@"
		fi
		
		;;
esac

exec "$@"