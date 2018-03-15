#!/bin/sh

set -e

cd ${REDMINE_HOME}/log

for logfile in passenger.*.log; do
	mv -f ${logfile} ${logfile}.0
done
passenger-config reopen-logs

mv -f ${RAILS_ENV}.log ${RAILS_ENV}.log.0
passenger-config restart-app ${REDMINE_HOME}
