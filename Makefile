test-deploy-script:
	bash -c "COMMIT_SHA=617db9598c8dd607e43fdd1172b8037c1d86abde SHORT_SHA=617db95 REPO_NAME=lookit-api BRANCH_NAME=master TAG_NAME=latest deploy.sh"
	bash -c "COMMIT_SHA=617db9598c8dd607e43fdd1172b8037c1d86abde SHORT_SHA=617db95 REPO_NAME=lookit-api BRANCH_NAME=develop TAG_NAME=latest deploy.sh"

test-cloud-build:
	cloud-build-local --dryrun=false --substitutions COMMIT_SHA=d34db33fdabbad00babe,SHORT_SHA=d34dbee,REPO_NAME=lookit-api,BRANCH_NAME=master,TAG_NAME=0.0.1 .

encrypt-prod:
	gcloud kms encrypt \
		--plaintext-file=kubernetes/lookit/environments/production/lookit-secrets.env \
		--ciphertext-file=kubernetes/lookit/environments/production/lookit-secrets.env.enc \
		--location=us-east1 \
		--keyring=lookit-keyring \
		--key=kubernetes-secrets \
		--project=mit-lookit-keys
	gcloud kms encrypt \
		--plaintext-file=kubernetes/lookit/environments/production/googleAppCreds.json \
		--ciphertext-file=kubernetes/lookit/environments/production/googleAppCreds.json.enc \
		--location=us-east1 \
		--keyring=lookit-keyring \
		--key=kubernetes-secrets \
		--project=mit-lookit-keys
	gcloud kms encrypt \
		--plaintext-file=kubernetes/lookit/environments/production/cloudsql-client-creds.json \
		--ciphertext-file=kubernetes/lookit/environments/production/cloudsql-client-creds.json.enc \
		--location=us-east1 \
		--keyring=lookit-keyring \
		--key=kubernetes-secrets \
		--project=mit-lookit-keys

encrypt-staging:
	gcloud kms encrypt \
		--plaintext-file=kubernetes/lookit/environments/staging/lookit-secrets.env \
		--ciphertext-file=kubernetes/lookit/environments/staging/lookit-secrets.env.enc \
		--location=us-east1 \
		--keyring=lookit-keyring \
		--key=kubernetes-secrets \
		--project=mit-lookit-keys
	gcloud kms encrypt \
		--plaintext-file=kubernetes/lookit/environments/staging/googleAppCreds.json \
		--ciphertext-file=kubernetes/lookit/environments/staging/googleAppCreds.json.enc \
		--location=us-east1 \
		--keyring=lookit-keyring \
		--key=kubernetes-secrets \
		--project=mit-lookit-keys
	gcloud kms encrypt \
		--plaintext-file=kubernetes/lookit/environments/staging/cloudsql-client-creds.json \
		--ciphertext-file=kubernetes/lookit/environments/staging/cloudsql-client-creds.json.enc \
		--location=us-east1 \
		--keyring=lookit-keyring \
		--key=kubernetes-secrets \
		--project=mit-lookit-keys

decrypt-prod:
	gcloud kms decrypt \
		--ciphertext-file=kubernetes/lookit/environments/production/lookit-secrets.env.enc \
		--plaintext-file=kubernetes/lookit/environments/production/lookit-secrets.env \
		--location=us-east1 \
		--keyring=lookit-keyring \
		--key=kubernetes-secrets \
		--project=mit-lookit-keys
	gcloud kms decrypt \
		--ciphertext-file=kubernetes/lookit/environments/production/googleAppCreds.json.enc \
		--plaintext-file=kubernetes/lookit/environments/production/googleAppCreds.json \
		--location=us-east1 \
		--keyring=lookit-keyring \
		--key=kubernetes-secrets \
		--project=mit-lookit-keys
	gcloud kms decrypt \
		--ciphertext-file=kubernetes/lookit/environments/production/cloudsql-client-creds.json.enc \
		--plaintext-file=kubernetes/lookit/environments/production/cloudsql-client-creds.json \
		--location=us-east1 \
		--keyring=lookit-keyring \
		--key=kubernetes-secrets \
		--project=mit-lookit-keys

decrypt-staging:
	gcloud kms decrypt \
		--ciphertext-file=kubernetes/lookit/environments/staging/lookit-secrets.env.enc \
		--plaintext-file=kubernetes/lookit/environments/staging/lookit-secrets.env \
		--location=us-east1 \
		--keyring=lookit-keyring \
		--key=kubernetes-secrets \
		--project=mit-lookit-keys
	gcloud kms decrypt \
		--ciphertext-file=kubernetes/lookit/environments/staging/googleAppCreds.json.enc \
		--plaintext-file=kubernetes/lookit/environments/staging/googleAppCreds.json \
		--location=us-east1 \
		--keyring=lookit-keyring \
		--key=kubernetes-secrets \
		--project=mit-lookit-keys
	gcloud kms decrypt \
		--ciphertext-file=kubernetes/lookit/environments/staging/cloudsql-client-creds.json.enc \
		--plaintext-file=kubernetes/lookit/environments/staging/cloudsql-client-creds.json \
		--location=us-east1 \
		--keyring=lookit-keyring \
		--key=kubernetes-secrets \
		--project=mit-lookit-keys

clean:
	rm kubernetes/manifests/*/*.yaml

.PHONY: test-deploy-script test-cloud-build encrypt-staging encrypt-prod decrypt-prod decrypt-staging clean

