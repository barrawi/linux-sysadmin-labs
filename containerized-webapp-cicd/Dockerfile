# --- Stage 1: Build ---

FROM registry.access.redhat.com/ubi9/python-311:latest AS builder
WORKDIR /opt/app-root/src
# copy requirements and install to folder (/install)
COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=./install -r requirements.txt

# --- Stage 2: Runtime ---

# minimal image to reduce attack surface and image size
FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

# install shadow utils for creation of service user
USER root

RUN microdnf update -y && \
    microdnf install -y python3.11 shadow-utils && \
    microdnf clean all
# create a non priviledged user to run the app
RUN useradd -u 1001 -m webuser

WORKDIR /app

# copy ONLY necessary libs from Stage 1 
COPY --from=builder /opt/app-root/src/install /usr/local   

# copy code
COPY app/ . 

# set ownership for webuser
RUN chown -R webuser:webuser /app

# switch to webuser for security
USER webuser

# env variables
ENV PYTHONUNBUFFERED=1
EXPOSE 5000

# run app (python version needs to be specified to avoid errors)
CMD ["/usr/bin/python3.11", "main.py"]
