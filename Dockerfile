FROM gcr.io/google.com/cloudsdktool/cloud-sdk

RUN apt-get update && \
    apt-get install -y \
      # System dependencies.
      build-essential \
      gettext \
      make \
      gcc \
      curl \
      && \
    # kustomize
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash && \
    mv kustomize /usr/local/bin/ && \
    # Istio
    # export ISTIO_VERSION=1.4.2 && \
    # export URL="https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-linux.tar.gz" && \
    # curl -L "${URL}" | tar xz && \
    # ln -s /istio-${ISTIO_VERSION}/bin/istioctl /usr/local/bin/istioctl && \
    ls -al /usr/local/bin/ && \
    # istioctl verify-install && \  # Need gcloud/kubectl set up for this
    # Kill off apt cache.
    rm -rf /var/lib/apt/lists/*

COPY ./kubernetes kubernetes
COPY ./deploy.sh deploy.sh

# All args for cloud build come after this.
#ENTRYPOINT ["./deploy.sh"]

# CMD should essentially behave as the default test
# CMD ["args", "for", "deploy"]