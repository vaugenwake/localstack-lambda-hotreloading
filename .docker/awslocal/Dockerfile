FROM sykescottages/node:18

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

RUN apt-get update && \
    apt-get install -y  \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    jq \
    python3 \
    python3-pip \
    python-is-python3

RUN pip install awscli-local