# Lookit Orchestrator
CI/CD tooling for the Lookit project.

## Rationale and Design

We use Google Cloud Platform heavily for Lookit - storing Ember apps as web archives in GCS, 
keeping user data in a Google-managed Postgres DB with Cloud SQL, deploying the application
components in Google-managed Kubernetes clusters using GKE, GCR as a Docker image repository, etc.
We want to automate the management of all these cloud properties, and provide developers of the 
Lookit platform a "One Stop Shop" for deployment needs.

### Overall Architecture

We are using a Kustomize-based workflow and adhering to the suggested file hierarchy. The
execution pathway is standard containerized GitOps - the "orchestrator" image/container is built 
and loaded into GCR, where it can be fetched by a Cloud Builder at a later time.

**When commits are published to the master branch for this repo:**
Google Cloud Build will create a Cloud SDK-based image that copies all the deployment manifests 
from kubernetes/lookit, as well as the `deploy.sh` script located at the root of this project. 
This image is loaded into Google Container Registry with the tag `latest`.

**When commits are published to the develop or master branch for lookit-api:**
Google Cloud build will run tests before pushing a valid lookit-api image to Google Container Registry.
It will then pull the orchestrator image from GCR and run it, leveraging 
[build variable substitution](https://cloud.google.com/cloud-build/docs/configuring-builds/substitute-variable-values#using_default_substitutions)
to parameterize the build with Github-supplied metadata (namely, commit SHA, tag, and branch name) in the
form of environment variables.

The deploy script will use these environment variables to template the kustomize manifests (using `envsubst`)
and choose the target cluster.

#### Secret Management
In true GitOps spirit, we check our secrets into source control. How is this done securely? By checking in
encrypted keys that are managed separately from the rest of the cloud resources.
 
Our deploy script invokes gcloud's GKMS module to decrypt secrets that are encoded *beforehand* and checked
in by one person only - the key project owner. The cryptographic keys for lookit-orchestrator are stored 
in a separate project that is locked down to everyone except the key project owner; ensuring that high-level
access to cloud resources in the mit-lookit project do not accidentally grant permissions to developers 
to manipulate crypto keys.

### Gotchas

- The variable replacement system in Kustomize is somewhat convoluted, but the important thing to know is that
ConfigMap values *must* be defined in the base `kustomizeconfig.yaml` as a `varReference` before they are
referenced in `kustomization.yaml`.

- `add-lookit-env-vars.yaml` has a fragile patching system right now - because we can't target container elements
by name, we have to have injections like such:
```.yaml
- op: add
  path: /spec/template/spec/containers/0/env/-
  value:
    name: ENVIRONMENT
    valueFrom:
      configMapKeyRef:
        key: ENVIRONMENT
        name: lookit-configmap
```
where the path has a hardcoded zero to indicate the first array. This is obviously
not optimal; I'm open to better solutions.

### Design Considerations FAQ

#### Why Kustomize (and not Helm, Kapitan, custom tooling, etc.)?

In short: long term support and underlying philosophy.

Regarding the first point, Kustomize is built into [kubectl as of 1.14](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/) 
and is officially supported by the Cloud Native Computing Foundation as such.

Even though Helm is also supported by the CNCF, its goals as a project remain straddled over templating
system, configuration management, and pseudo-package manager for Kubernetes. It's an extremely powerful tool
in that regard, but sometimes too much power is a bad thing. With Lookit, deployments to a given cluster 
should be entirely stable in terms of configuration; the only thing that should change is lookit-api's 
image version and the associated labels. Helm's templating system seems to encourage the conflation of 
static *per-environment* configuration with dynamic *per-deployment* build variables. Kustomize, on the
other hand, lends itself neatly to the configuration-as-code discipline of DevOps with per-environment
overrides. All that remains is to substitute build variables, which is a simple task accomplished with
`envsubst` and simple file templating.

## Managing Deployments with Lookit-Orchestrator

### Prerequisites

1) Make sure you have git installed (instructions [here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git))
    - If you're on a Mac and have `brew`, you can install with `brew install git`.
 
2) Make sure you have the gcloud SDK installed (instructions [here](https://cloud.google.com/sdk/install)).
This will allow you to authenticate with Lookit's Google Cloud Platform project.
    - If you're on a Mac and have `brew`, you can install with `brew install gcloud`.

3) Make sure you have kubectl.
    - Run `gcloud components install kubectl` if you don't have it already.

4) Ask Rico Rodriguez (rrodrigu@mit.edu) for access to the MIT Lookit project.

## Getting Started

### Manual deployments
1) Clone this project.
2) Run `gcloud init` or `gcloud config` per the instructions 
[in the gcloud kubectl setup documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl).
3) Run the `deploy.sh` script with a bash version greater than 4.0 (the script uses associative arrays,
which are a relatively recent feature of bash).
    - make sure to set the `COMMIT_SHA`, `SHORT_SHA`, `REPO_NAME`, `BRANCH_NAME`, and `TAG_NAME`
    variables prior to executing the script - `COMMIT_SHA` and `SHORT_SHA` referring to the commit
    you wish to deploy.

```.sh
bash -c "COMMIT_SHA=f5c855f8e64fa878e62f63a6297a24f6dfc07033 \
         SHORT_SHA=f5c855f \
         REPO_NAME=lookit-api \
         BRANCH_NAME=develop \
         TAG_NAME=latest \
         . deploy.sh" 
```

### Automated deployments
Through the Google Cloud Build/Github integration, any commits to the lookit-api codebase on the master
or develop branches will automatically trigger a build with the correct tag, commit SHA, and branch.

## Endnotes

### Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

### Authors

* **Rico Rodriguez** ([Datamance](https://github.com/Datamance))

See also the list of [contributors](https://github.com/lookit/lookit-orchestrator/contributors) who participated in this project.

### License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
