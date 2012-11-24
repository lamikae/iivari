NAME=iivari-express

INSTALLFILES ?= \
	server/*.coffee \
	client/*.coffee \
	client/styles/* \
	client/views/* \
	vendor/javascripts/* \
	vendor/stylesheets/* \
	package.json \
	site.js

INSTALLDIR=/var/lib/iivari-express

INCLUDE_NODE_MODULES=true

all:

install:
	for file in $(INSTALLFILES); do \
		install -D -o root -g root -m 644 $$file \
			$(DESTDIR)$(INSTALLDIR)/$$file || exit 1; \
	done

	# /usr/bin/iivari-express
	install -D -o root -g root -m 755 bin/production \
		$(DESTDIR)/usr/bin/$(NAME)

	# /usr/bin/iivari-slideshow client script
	install -D -o root -g root -m 755 bin/iivari-slideshow \
		$(DESTDIR)/usr/bin/iivari-slideshow

	# /etc/init.d/iivari-express
	install -D -o root -g root -m 755 init/$(NAME) \
		$(DESTDIR)/etc/init.d/$(NAME)

	# /etc/iivari-express.conf
	install -D -o root -g root -m 755 etc/iivari-express.conf \
		$(DESTDIR)/etc/iivari-express.conf
	# also to npm root config.json, these will be defaults
	install -D -o root -g root -m 755 etc/iivari-express.conf \
		$(DESTDIR)$(INSTALLDIR)/config.json

	# /usr/bin/iivari-slideshow will use
	# --rcfile /var/lib/iivari-express/iivarirc
	install -D -o root -g root -m 755 etc/iivarirc \
		$(DESTDIR)$(INSTALLDIR)/iivarirc

	# /etc/init.d/iivari nodm client script
	install -D -o root -g root -m 755 init/iivari \
		$(DESTDIR)/etc/init.d/iivari
	install -D -o root -g root -m 755 etc/default/nodm \
		$(DESTDIR)$(INSTALLDIR)/iivarirc

	if [ $(INCLUDE_NODE_MODULES) = true ]; then \
#  ***\
#  *** Downloading dependencies from node.js repositories        ***\
#  *** If this fails, please check that you have 'npm' in $$PATH ***\
#  ***\
		npm install --production && \
		mv node_modules $(DESTDIR)$(INSTALLDIR)/ ;\
	fi

clean:

deb:
	-rm -rf debian/$(NAME) deb_dist
	mkdir -p deb_dist/$(NAME)
	cp -r bin client debian init server Makefile etc package.json README.md site.js vendor deb_dist/$(NAME) && \
	cd deb_dist/$(NAME) && \
	dpkg-buildpackage -rfakeroot -uc -us || exit 1;

	@echo "\n *** PACKAGE CONTENTS\n"
	@dpkg-deb -c deb_dist/*.deb
	@echo "\n *** DEBIAN FILES\n"
	@ls -1 deb_dist/$(NAME)_*

