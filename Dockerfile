FROM	alpine:latest

ENV	REDMINE_BRANCH=3.4-stable \
	REDMINE_HOME=/home/redmine \
	RAILS_ENV=production

RUN	set -ex \
&&	apk add --virtual .run-deps --update-cache \
	tzdata \
	ruby \
	ruby-bundler \
	ruby-json \
	ruby-bigdecimal \
	tini \
	libressl \
	libxml2 \
	imagemagick6 \
	mariadb-client-libs \
	postgresql-libs \
	freetds \
	sqlite-libs \
&&	ln -s /usr/bin/convert-6 /usr/bin/convert \
	\
&&	apk add --virtual .build-deps \
	git \
	make \
	gcc \
	libc-dev \
	ruby-dev \
	libressl-dev \
	libxml2-dev \
	imagemagick6-dev \
	mariadb-dev \
	postgresql-dev \
	freetds-dev \
	sqlite-dev \
	\
&&	echo -e "install: --no-document\nupdate: --no-document\n" > /etc/gemrc \
&&	gem update --system $(ruby -e "print RUBY_VERSION") \
&&	git clone -b ${REDMINE_BRANCH} https://github.com/redmine/redmine.git ${REDMINE_HOME} \
&&	cd ${REDMINE_HOME} \
&&      for adapter in mysql2 postgresql sqlserver sqlite3; do \
		echo -e "${RAILS_ENV}:\n  adapter: ${adapter}\n" > config/database.yml; \
                bundle install --without development test; \
                mv Gemfile.lock Gemfile.lock.${adapter}; \
        done \
&&	ln -sf /dev/stdout log/${RAILS_ENV}.log \
	\
&&	apk del --purge .build-deps \
&&	rm -fr /root/.bundle \
        /root/.gem \
	$(gem env gemdir)/cache \
	config/database.yml

WORKDIR	${REDMINE_HOME}
VOLUME	${REDMINE_HOME}/files

COPY	docker-entrypoint.sh /root/
ENTRYPOINT ["sh", "/root/docker-entrypoint.sh"]

EXPOSE	3000
CMD	["rails", "server", "-b", "0.0.0.0"]
