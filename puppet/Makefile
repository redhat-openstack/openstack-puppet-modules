# Puppet templating module by James
# Copyright (C) 2012-2013+ James Shubin
# Written by James Shubin <james@shubin.ca>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

.PHONY: all docs rpm srpm spec tar upload upload-sources upload-srpms upload-rpms
.SILENT:

# version of the program
VERSION := $(shell cat VERSION)
RELEASE = 1
SPEC = rpmbuild/SPECS/puppet-puppet.spec
SOURCE = rpmbuild/SOURCES/puppet-puppet-$(VERSION).tar.bz2
SRPM = rpmbuild/SRPMS/puppet-puppet-$(VERSION)-$(RELEASE).src.rpm
RPM = rpmbuild/RPMS/puppet-puppet-$(VERSION)-$(RELEASE).rpm
SERVER = 'dl.fedoraproject.org'
REMOTE_PATH = 'purpleidea/puppet-puppet'

all: docs rpm

docs: puppet-puppet-documentation.pdf

puppet-puppet-documentation.pdf: DOCUMENTATION.md
	pandoc DOCUMENTATION.md -o 'puppet-puppet-documentation.pdf'

#
#	aliases
#
# TODO: does making an rpm depend on making a .srpm first ?
rpm: $(SRPM) $(RPM)
	# do nothing

srpm: $(SRPM)
	# do nothing

spec: $(SPEC)
	# do nothing

tar: $(SOURCE)
	# do nothing

upload: upload-sources upload-srpms upload-rpms
	# do nothing

#
#	rpmbuild
#
$(RPM): $(SPEC) $(SOURCE)
	@echo Running rpmbuild -bb...
	rpmbuild --define '_topdir $(shell pwd)/rpmbuild' -bb $(SPEC) && \
	mv rpmbuild/RPMS/noarch/puppet-puppet-$(VERSION)-$(RELEASE).*.rpm $(RPM)

$(SRPM): $(SPEC) $(SOURCE)
	@echo Running rpmbuild -bs...
	rpmbuild --define '_topdir $(shell pwd)/rpmbuild' -bs $(SPEC)
	# renaming is not needed because we aren't using the dist variable
	#mv rpmbuild/SRPMS/puppet-puppet-$(VERSION)-$(RELEASE).*.src.rpm $(SRPM)

#
#	spec
#
$(SPEC): rpmbuild/ puppet-puppet.spec.in
	@echo Running templater...
	#cat puppet-puppet.spec.in > $(SPEC)
	sed -e s/__VERSION__/$(VERSION)/ -e s/__RELEASE__/$(RELEASE)/ < puppet-puppet.spec.in > $(SPEC)
	# append a changelog to the .spec file
	git log --format="* %cd %aN <%aE>%n- (%h) %s%d%n" --date=local | sed -r 's/[0-9]+:[0-9]+:[0-9]+ //' >> $(SPEC)

#
#	archive
#
$(SOURCE): rpmbuild/
	@echo Running git archive...
	# use HEAD if tag doesn't exist yet, so that development is easier...
	git archive --prefix=puppet-puppet-$(VERSION)/ -o $(SOURCE) $(VERSION) 2> /dev/null || (echo 'Warning: $(VERSION) does not exist.' && git archive --prefix=puppet-puppet-$(VERSION)/ -o $(SOURCE) HEAD)

# TODO: ensure that each sub directory exists
rpmbuild/:
	mkdir -p rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

#
#	sha256sum
#
rpmbuild/SOURCES/SHA256SUMS: rpmbuild/SOURCES/ $(SOURCE)
	@echo Running SOURCES sha256sum...
	cd rpmbuild/SOURCES/ && sha256sum *.tar.bz2 > SHA256SUMS; cd -

rpmbuild/SRPMS/SHA256SUMS: rpmbuild/SRPMS/ $(SRPM)
	@echo Running SRPMS sha256sum...
	cd rpmbuild/SRPMS/ && sha256sum *src.rpm > SHA256SUMS; cd -

rpmbuild/RPMS/SHA256SUMS: rpmbuild/RPMS/ $(RPM)
	@echo Running RPMS sha256sum...
	cd rpmbuild/RPMS/ && sha256sum *.rpm > SHA256SUMS; cd -

#
#	gpg
#
rpmbuild/SOURCES/SHA256SUMS.asc: rpmbuild/SOURCES/SHA256SUMS
	@echo Running SOURCES gpg...
	# the --yes forces an overwrite of the SHA256SUMS.asc if necessary
	gpg2 --yes --clearsign rpmbuild/SOURCES/SHA256SUMS

rpmbuild/SRPMS/SHA256SUMS.asc: rpmbuild/SRPMS/SHA256SUMS
	@echo Running SRPMS gpg...
	gpg2 --yes --clearsign rpmbuild/SRPMS/SHA256SUMS

rpmbuild/RPMS/SHA256SUMS.asc: rpmbuild/RPMS/SHA256SUMS
	@echo Running RPMS gpg...
	gpg2 --yes --clearsign rpmbuild/RPMS/SHA256SUMS

#
#	upload
#
# upload to public server
upload-sources: rpmbuild/SOURCES/ rpmbuild/SOURCES/SHA256SUMS rpmbuild/SOURCES/SHA256SUMS.asc
	if [ "`cat rpmbuild/SOURCES/SHA256SUMS`" != "`ssh $(SERVER) 'cd $(REMOTE_PATH)/SOURCES/ && cat SHA256SUMS'`" ]; then \
		echo Running SOURCES upload...; \
		rsync -avz rpmbuild/SOURCES/ $(SERVER):$(REMOTE_PATH)/SOURCES/; \
	fi

upload-srpms: rpmbuild/SRPMS/ rpmbuild/SRPMS/SHA256SUMS rpmbuild/SRPMS/SHA256SUMS.asc
	if [ "`cat rpmbuild/SRPMS/SHA256SUMS`" != "`ssh $(SERVER) 'cd $(REMOTE_PATH)/SRPMS/ && cat SHA256SUMS'`" ]; then \
		echo Running SRPMS upload...; \
		rsync -avz rpmbuild/SRPMS/ $(SERVER):$(REMOTE_PATH)/SRPMS/; \
	fi

upload-rpms: rpmbuild/RPMS/ rpmbuild/RPMS/SHA256SUMS rpmbuild/RPMS/SHA256SUMS.asc
	if [ "`cat rpmbuild/RPMS/SHA256SUMS`" != "`ssh $(SERVER) 'cd $(REMOTE_PATH)/RPMS/ && cat SHA256SUMS'`" ]; then \
		echo Running RPMS upload...; \
		rsync -avz --prune-empty-dirs rpmbuild/RPMS/ $(SERVER):$(REMOTE_PATH)/RPMS/; \
	fi

# vim: ts=8
