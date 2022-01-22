FROM python:3.9-slim-buster

RUN python -m pip install ansible==5.2.0 paramiko

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \    
        vim \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash ansible

USER ansible

WORKDIR /ansible

CMD ["/usr/local/bin/ansible"]
