FROM python:3.9-slim-buster

RUN python -m pip install ansible paramiko

RUN useradd -ms /bin/bash ansible

USER ansible

WORKDIR /ansible

CMD ["/usr/local/bin/ansible"]
