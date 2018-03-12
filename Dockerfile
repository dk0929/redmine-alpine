FROM	alpine:latest

ENV	REDMINE_BRANCH=3.4-stable \
	REDMINE_HOME=/home/redmine \
	RAILS_ENV=production

WORKDIR	${REDMINE_HOME}

RUN	set -ex \
&&	apk add --virtual .run-deps --update-cache \
	tzdata \
	tini \
	ruby \
	ruby-json \
	ruby-bigdecimal \
	libressl \
	libxml2 \
	libxslt \
	xz-libs \
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
	libxslt-dev \
	xz-dev \
	imagemagick6-dev \
	mariadb-dev \
	postgresql-dev \
	freetds-dev \
	sqlite-dev \
	\
&&	echo "gem: --no-document" > /etc/gemrc \
&&	gem update --system $(ruby -e "print RUBY_VERSION") \
&&	gem install bundler \
&&	git clone -b ${REDMINE_BRANCH} https://github.com/redmine/redmine.git . \
&&      for adapter in mysql2 postgresql sqlserver sqlite3; do \
		echo -e "${RAILS_ENV}:\n  adapter: ${adapter}\n" > config/database.yml; \
                bundle install --without development test; \
                mv Gemfile.lock Gemfile.lock.${adapter}; \
        done \
	\
&&	apk del --purge .build-deps \
&&	rm -fr /root/.bundle \
	/root/.gem \
	$(gem env gemdir)/cache \
	.git* \
	.*ignore \
	config/database.yml

COPY	docker-entrypoint.sh /root/
ENTRYPOINT ["sh", "/root/docker-entrypoint.sh"]

VOLUME	["${REDMINE_HOME}/files", "${REDMINE_HOME}/log", "${REDMINE_HOME}/db"]
EXPOSE	3000
CMD	["rails", "server", "-b", "0.0.0.0"]
