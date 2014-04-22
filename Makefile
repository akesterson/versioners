VERSION:=$(shell if [ -d .git ]; then bash -c 'gitversion.sh | grep "^MAJOR=" | cut -d = -f 2'; else source version.sh && echo $$MAJOR ; fi)
RELEASE:=$(shell if [ -d .git ]; then bash -c 'gitversion.sh | grep "^BUILD=" | cut -d = -f 2'; else source version.sh && echo $$BUILD ; fi)
DISTFILE=./dist/versioners-$(VERSION)-$(RELEASE).tar.gz
SPECFILE=versioners.spec

ifndef RHEL_VERSION
	RHEL_VERSION=5
endif
ifeq ($(RHEL_VERSION),5)
	MOCKFLAGS=--define "_source_filedigest_algorithm md5" --define "_binary_filedigest_algorithm md5"
endif
ifndef PREFIX
	PREFIX=''
endif

RHEL_RELEASE:=$(RELEASE).el$(RHEL_VERSION)
SRPM=versioners-$(VERSION)-$(RHEL_RELEASE).src.rpm
RPM=versioners-$(VERSION)-$(RHEL_RELEASE).noarch.rpm
RHEL_DISTFILE=./dist/cmdarg-$(VERSION)-$(RHEL_RELEASE).tar.gz

DISTFILE_DEPS=$(shell find . -type f | grep -Ev '\.git|\./dist/|$(DISTFILE)')

all: ./dist/$(RPM)

# --- PHONY targets

.PHONY: clean srpm rpm gitclean dist
clean:
	rm -f $(DISTFILE) $(RHEL_DISTFILE)
	rm -fr dist/versioners-$(VERSION)-$(RELEASE)*

version.sh:
	gitversion.sh > version.sh

dist: $(DISTFILE)

srpm: ./dist/$(SRPM)

rpm: ./dist/$(RPM) ./dist/$(SRPM)

gitclean:
	git clean -df

# --- End phony targets

version.sh:
	if [ ! -d .git ] && [ -f version.sh ]; then echo "No git, keeping old version.sh" ; fi ; \
	if [ ! -d .git ] && [ ! -f version.sh ]; then echo "No git and no version.sh, you're boned"; exit 1; fi ; \
	if [ -d .git ] ; then \
		bash ./gitversion.sh > tmpversion.sh && \
		VERSIONSHA=$$(openssl sha1 version.sh | cut -d = -f 2) ; \
		TMPVERSIONSHA=$$(openssl sha1 tmpversion.sh | cut -d = -f 2) ; \
		if [ ! -e version.sh ] || [ "$$VERSIONSHA" != "$$TMPVERSIONSHA" ]; then \
			mv tmpversion.sh version.sh; \
		fi; \
	fi

$(DISTFILE): version.sh
	mkdir -p dist/
	mkdir dist/versioners-$(VERSION)-$(RELEASE) || rm -fr dist/versioners-$(VERSION)-$(RELEASE)
	rsync -aWH . --exclude=.git --exclude=dist ./dist/versioners-$(VERSION)-$(RELEASE)/
	cd dist && tar -czvf ../$@ versioners-$(VERSION)-$(RELEASE)

$(RHEL_DISTFILE): $(DISTFILE)
	cd dist && \
		cp -R versioners-$(VERSION)-$(RELEASE) versioners-$(VERSION)-$(RHEL_RELEASE) && \
		tar -czvf ../$@ versioners-$(VERSION)-$(RHEL_RELEASE)

./dist/$(SRPM): $(RHEL_DISTFILE)
	rm -fr ./dist/$(SRPM)
	/usr/bin/mock --verbose -r epel-$(RHEL_VERSION)-noarch --buildsrpm --spec $(SPECFILE) $(MOCKFLAGS) --sources ./dist/ --resultdir ./dist/ --define "version $(VERSION)" --define "release $(RHEL_RELEASE)"

./dist/$(RPM): ./dist/$(SRPM)
	rm -fr ./dist/$(RPM)
	/usr/bin/mock --verbose -r epel-$(RHEL_VERSION)-noarch ./dist/$(SRPM) --resultdir ./dist/ --define "version $(VERSION)" --define "release $(RHEL_RELEASE)"

uninstall:
	rm -f $(PREFIX)/usr/bin/taggit.sh
	rm -f $(PREFIX)/usr/bin/taghg.sh
	rm -f $(PREFIX)/usr/bin/gitversion.sh
	rm -f $(PREFIX)/usr/bin/hgversion.sh


install:
	mkdir -p $(PREFIX)/usr/bin
	install ./gitversion.sh $(PREFIX)/usr/bin/gitversion.sh
	install ./hgversion.sh $(PREFIX)/usr/bin/hgversion.sh
	install ./taggit.sh $(PREFIX)/usr/bin/taggit.sh
	install ./taghg.sh $(PREFIX)/usr/bin/taghg.sh

MANIFEST:
	echo /usr/bin/gitversion.sh > MANIFEST
	echo /usr/bin/hgversion.sh >> MANIFEST
	echo /usr/bin/taggit.sh >> MANIFEST
	echo /usr/bin/taghg.sh >> MANIFEST
