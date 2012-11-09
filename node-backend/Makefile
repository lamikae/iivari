NAME=iivari-backend

INSTALLFILES ?= \
	app/*.coffee \
	app/styles/* \
	app/views/* \
	assets/javascripts/* \
	assets/stylesheets/* \
	site/* \
	package.json \
	site.js \
	log/.keep

all:

install:
	for file in $(INSTALLFILES); do \
		install -D -o infotv -g infotv -m 644 $$file \
			$(DESTDIR)/opt/iivari/node-backend/$$file || exit 1; \
	done

	install -D -o root -g root -m 755 bin/production \
		$(DESTDIR)/usr/bin/iivari-backend

	install -D -o root -g root -m 755 init/$(NAME) \
		$(DESTDIR)/etc/init.d/$(NAME)

clean:

deb:
	-rm -rf debian/$(NAME) deb_dist
	mkdir -p deb_dist/$(NAME)
	cp -r app assets bin debian init site log Makefile package.json README.md site.js deb_dist/$(NAME) && \
	cd deb_dist/$(NAME) && \
	dpkg-buildpackage -rfakeroot -uc -us || exit 1;

	@echo "\n *** PACKAGE CONTENTS\n"
	@dpkg-deb -c deb_dist/*.deb
	@echo "\n *** DEBIAN FILES\n"
	@ls -1 deb_dist/$(NAME)_*

