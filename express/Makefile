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

	install -D -o root -g root -m 755 bin/production \
		$(DESTDIR)/usr/bin/$(NAME)

	install -D -o root -g root -m 755 init/$(NAME) \
		$(DESTDIR)/etc/init.d/$(NAME)

	# config.json.example -> config.json
	install -D -o root -g root -m 755 config.json.example \
		$(DESTDIR)$(INSTALLDIR)/config.json
	# also to /etc/iivari-express.conf
	install -D -o root -g root -m 755 config.json.example \
		$(DESTDIR)/etc/iivari-express.conf

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
	cp -r bin client debian init server log Makefile config.json.example package.json README.md site.js vendor deb_dist/$(NAME) && \
	cd deb_dist/$(NAME) && \
	dpkg-buildpackage -rfakeroot -uc -us || exit 1;

	@echo "\n *** PACKAGE CONTENTS\n"
	@dpkg-deb -c deb_dist/*.deb
	@echo "\n *** DEBIAN FILES\n"
	@ls -1 deb_dist/$(NAME)_*

