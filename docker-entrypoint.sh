#!/bin/sh
set -e

case "$1" in
	rails|passenger)
		adapter=$(ruby -e "
require 'json'
require 'yaml'
unless File.exist?('config/configuration.yml') or ENV['REDMINE_CONFIGURATION'].nil?
	conf = YAML.load_file('config/configuration.yml.example')
	conf.merge!(JSON.parse(ENV['REDMINE_CONFIGURATION']))
	YAML.dump(conf,File.open('config/configuration.yml','w'))
end
if File.exist?('config/database.yml')
	conf = YAML.load_file('config/database.yml')
	puts conf[ENV['RAILS_ENV']]['adapter']
else
	conf = YAML.load_file('config/database.yml.example')
	conf.merge!(JSON.parse(ENV['REDMINE_DATABASE']||'{\"production\":{\"adapter\":\"sqlite3\",\"database\":\"db/redmien.sqlite3\"}}'))
	YAML.dump(conf,File.open('config/database.yml','w'))
	puts conf[ENV['RAILS_ENV']]['adapter']
end
		")
		
		cp "Gemfile.lock.${adapter}" Gemfile.lock
		bundle check || bundle install --without development test
		rm -fr /root/.bundle /root/.gem $(gem env gemdir)/cache
		
		rake generate_secret_token
		rake redmine:plugins:migrate
		rake db:migrate
		
		if [ "$1" = 'passenger' ]; then
			set -- tini -- "$@"
		fi
		
		;;
esac

exec "$@"
