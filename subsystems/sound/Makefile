RPM_TOPDIR ?= $(PWD)/rpmbuild
VERSION ?= $(shell cat VERSION)
ROOTDIR ?= $(PWD)
SPECFILE_SUBPACKAGE_SOUND ?= ${ROOTDIR}/rpm/sound/sound.spec
PACKAGE_NAME = qm-sound

.PHONY: dist
dist: ##             - Creates the QM sound package
	cd $(ROOTDIR) && tar cvz \
		--dereference \
		--transform 's|subsystems/kvm/Makefile|Makefile|' \
		--transform 's|rpm/sound/sound.spec|qm-sound.spec|' \
		--transform 's|qm|qm-sound-${VERSION}|' \
		-f /tmp/qm-sound-${VERSION}.tar.gz \
		../qm/rpm/sound/sound.spec \
		../qm/subsystems/sound/Makefile \
		../qm/tools/version-update \
		../qm/README.md \
		../qm/SECURITY.md \
		../qm/LICENSE \
		../qm/etc/containers/systemd/qm.container.d/qm_dropin_mount_bind_snd.conf \
		../qm/subsystems/sound/etc/containers/systemd/audio.container

	cd $(ROOTDIR) && mv /tmp/qm-sound-${VERSION}.tar.gz ./rpm

.PHONY: sound
sound: dist ##             - Creates a local RPM package, useful for development
	cd $(ROOTDIR) && mkdir -p ${RPM_TOPDIR}/{RPMS,SRPMS,BUILD,SOURCES}
	cd $(ROOTDIR) && tools/version-update -v ${VERSION}
	cd $(ROOTDIR) && cp ./rpm/qm-sound-${VERSION}.tar.gz ${RPM_TOPDIR}/SOURCES
	rpmbuild -ba \
		--define="_topdir ${RPM_TOPDIR}" \
		--define="version ${VERSION}" \
		${SPECFILE_SUBPACKAGE_SOUND}
	if [ ! -f ${RPM_TOPDIR}/RPMS/noarch/${PACKAGE_NAME}-${VERSION}*.noarch.rpm ]; then \
		echo "rpmbuild failed to build: ${PACKAGE_NAME}"; \
		exit 1; \
	fi