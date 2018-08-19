FROM	alpine:3.7
ENV	REDMINE_BRANCH=3.4-stable \
	REDMINE_HOME=/home/redmine \
	RAILS_ENV=production
WORKDIR	${REDMINE_HOME}
COPY	docker-entrypoint.sh /root/

RUN	set -ex \
&&	chmod +x /root/docker-entrypoint.sh \
	\
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
&&	for dir in `find $(gem env gemdir) -type f -name Makefile -exec dirname {} \;`; do \
		cd $dir; \
		make clean; \
	done \
&&	cd ${REDMINE_HOME} \
&&	apk del --purge .build-deps \
&&	rm -fr /var/cache/apk/* \
	/root/.bundle \
	/root/.gem \
	$(gem env gemdir)/cache \
	.git* \
	.*ignore \
	$(find . -type f -name delete.me) \
	config/database.yml

VOLUME	["${REDMINE_HOME}/files", "${REDMINE_HOME}/log"]
EXPOSE	3000
ENTRYPOINT ["/root/docker-entrypoint.sh"]
CMD	["rails", "server", "-b", "0.0.0.0"]
