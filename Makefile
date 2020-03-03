test-cloud-build:
	cloud-build-local --dryrun=false --substitutions COMMIT_SHA=d34db33fdabbad00babe,SHORT_SHA=d34dbee,REPO_NAME=lookit-api,BRANCH_NAME=master,TAG_NAME=0.0.1 .

.PHONY: test-cloud-build

