ARG DOCKER_CE_CLI_VERSION=24.0.4-1~debian.11~bullseye_amd64.deb
ARG DOCKER_CE_CLI=docker-ce-cli_$DOCKER_CE_CLI_VERSION
ARG TERRAFORM_VERSION=1.5.2
ARG TERRAFORM_ZIP=terraform_$TERRAFORM_VERSION_linux_amd64.zip
ARG TERAAFORM_URL=https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_$TERRAFORM_VERSION_linux_amd64.zip
ARG JENKINS_VERSION=lts-slim

FROM jenkins/jenkins:$JENKINS_VERSION

LABEL maintainer="Reza Shahraminia"

##### Install jenkins plugins
USER root

# RUN apt update 
# RUN DEBIAN_FRONTEND=noninteractive apt install -y wget

# RUN wget https://updates.jenkins.io/update-center.json?version=2.401.2

RUN jenkins-plugin-cli --plugins \
    configuration-as-code \
    workflow-aggregator \
    job-dsl \
    pipeline-model-definition \
    antisamy-markup-formatter \
    terraform \
    kubernetes \
    kubernetes-cli \
    openshift-client \
    docker-plugin \
    docker-commons \
    docker-workflow \
    git \
    git-parameter \
    github \
    junit \
    cobertura \
    htmlpublisher \
    generic-webhook-trigger \
    ansible \
    credentials \
    credentials-binding \
    rebuild \
    run-condition \
    ssh \
    publish-over-ssh \
    copyartifact \
    metrics \
    prometheus \
    http_request \
    s3 \
    slack \
    mattermost \
    config-file-provider \
    ansicolor \
    keycloak \
    join \
    ws-cleanup \
    ssh-steps \
    ec2 \
    codedeploy \
    permissive-script-security \
    influxdb \
    ssh-credentials \
    matrix-auth \
    durable-task \
    script-security \
    multibranch-scan-webhook-trigger \
    remote-file

USER root

##### Install docker client

COPY $DOCKER_CE_CLI $DOCKER_CE_CLI

RUN dpkg --install *.deb

RUN rm *.deb
##### Install ansible

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip

RUN pip install wheel && pip install ansible

##### Install kubernetes client when download kubectl
# Download from https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl

COPY kubectl kubectl

RUN chmod +x kubectl && mv kubectl /usr/local/bin/kubectl


##### Install helm with 

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

RUN chmod 700 get_helm.sh

RUN ./get_helm.sh

##### Install terraform
RUN apt-get update -y && apt-get install -y unzip wget

# RUN wget $TERAAFORM_URL
COPY $TERRAFORM_ZIP $TERRAFORM_ZIP

RUN unzip $TERRAFORM_ZIP

RUN mv terraform /usr/local/bin && rm -rf $TERRAFORM_ZIP


##### Install pulumi

RUN curl -LO "https://get.pulumi.com/releases/sdk/pulumi-v$(curl -sL https://www.pulumi.com/latest-version)-linux-x64.tar.gz" && \
    tar -zxf pulumi-v*-linux-x64.tar.gz && \
    mv pulumi/pulumi* /usr/local/bin && \
    rm -rf pulumi-v*-linux-x64.tar.gz pulumi

##### Install maasta

RUN pip install maasta

##### Install tf2

RUN pip install tf2project

USER jenkins

COPY ansible.yaml /tmp/ansible.yaml

# RUN ansible-galaxy collection install -r /tmp/ansible.yaml
