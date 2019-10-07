AWS:=$(HOME)/.virtualenvs/aws/bin/aws
PRODUCTION_BUCKET:=thuytrang144.github.io
BUILD_REVISION:=$(shell git rev-parse --abbrev-ref HEAD)-$(shell git log --pretty=format:'%h' -n 1)
CF_DISTRO_ID=E3RLYZY6HQ8CQZ
IVPATH=/*
BUILD_DIR=_build/html
BRANCH_NAME=$(shell git branch | grep \* | cut -d ' ' -f2)

s3-sync:
	@echo "Sending updates to s3://${PRODUCTION_BUCKET} ..."
	@${AWS} s3 sync --sse AES256 $(BUILD_DIR)/ s3://${PRODUCTION_BUCKET}/ --acl public-read --delete

s3-sync-quick:
	${AWS} s3 sync --size-only $(BUILD_DIR)/ s3://${PRODUCTION_BUCKET}/ --acl public-read

s3-sync-quick-branch:
	${AWS} s3 sync --size-only $(BUILD_DIR)/ s3://${PRODUCTION_BUCKET}/${BRANCH_NAME} --acl public-read

s3-sync-force:
	${AWS} s3 cp --recursive $(BUILD_DIR)/ s3://${PRODUCTION_BUCKET}/ --acl public-read

invalidate:
	@echo "Sending invalidation requests [$(CF_DISTRO_ID)] ... "
	@${AWS} cloudfront create-invalidation --distribution-id $(CF_DISTRO_ID) --paths "$(IVPATH)"

deploy: s3-sync invalidate
quick-deploy: s3-sync-quick invalidate
force-deploy: s3-sync-force invalidate

commit:
	git add .
	git commit -m "#quick-save $(shell date)"
	git push

# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = source
BUILDDIR      = build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile build deploy quick-deploy force-deploy

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	