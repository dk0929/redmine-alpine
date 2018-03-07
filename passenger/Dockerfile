FROM dk0929/redmine-alpine:3.4-stable

RUN	set -ex \
&&	apk add --no-cache --virtual .run-deps \
	procps \
	ruby-libs \
	pcre \
	zlib \
	libressl \
	libcurl \
	\
&&	apk add --no-cache --virtual .build-deps \
	wget \
	make \
	gcc \
	g++ \
	libc-dev \
	linux-headers \
	ruby-dev \
	pcre-dev \
	zlib-dev \
	libressl-dev \
	curl-dev \
	\
&&	gem install passenger -N \
	\
&&	passenger-config install-agent --skip-cache --working-dir /tmp/ --auto \
	\
&&	passenger-config install-standalone-runtime --skip-cache --working-dir /tmp/ --auto \
	\
&&	passenger-config build-native-support \
	\
&&	apk del --purge .build-deps \
&&	rm -fr /var/cache/apk/ \
	/root/.bundle \
	/root/.gem \
	$(gem env gemdir)/cache \
	/tmp/*

CMD ["passenger", "start"]
