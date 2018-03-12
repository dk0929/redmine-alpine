FROM dk0929/redmine-alpine:3.4-stable

RUN	set -ex \
&&	apk add --virtual .run-deps --update-cache \
	procps \
	pcre \
	zlib \
	libressl \
	libcurl \
	\
&&	apk add --virtual .build-deps \
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
&&	gem install passenger \
&&	passenger-config install-agent --skip-cache --working-dir /tmp/ --auto \
&&	passenger-config install-standalone-runtime --skip-cache --working-dir /tmp/ --auto \
&&	passenger-config build-native-support \
	\
&&	apk del --purge .build-deps \
&&	rm -fr /root/.bundle \
	/root/.gem \
	$(gem env gemdir)/cache \
	/tmp/*

CMD ["passenger", "start"]
