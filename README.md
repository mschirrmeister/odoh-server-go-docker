# odoh-server-go Docker

This project provides a **Dockerfile** for **Cloudflares** [odoh-server-go](https://github.com/cloudflare/odoh-server-go) project.

The **odoh-server-go** can be used as an ODoH **target** or **relay**.

**ODoH** stands for **Oblivious DNS over HTTPS**.

Below are a few examples on how to run it. The recommended way is to run it behind a proxy who handles the TLS termination.

## Examples

Run the container with a local certificate, where odoh-server-go handles TLS itself.

    docker run -it -d \
      --name odoh-server-relay \
      -p 4567:4567/tcp \
      -v /Users/marco/MyData/Secure/Certificates/CertFolder>:/certs \
      -e TARGET_INSTANCE_NAME=<FQDN> \
      -e SEED_SECRET_KEY=(openssl rand -hex 16) \
      -e EXPERIMENT_ID=EXP_1 \
      -e CERT=/certs/<CertFullChain>.cer \
      -e KEY=/certs/<CertKey>.key \
      -e PORT=4567 \
      odoh-server-go:latest

Run the container with **Traefik** as a frontend and HTTP (plain) to the backend.

    docker run -it -d \
      --name odoh-server-relay \
      -p 4567:4567/tcp \
      -v /Users/marco/MyData/Secure/Certificates/<CertFolder>:/certs \
      -e TARGET_INSTANCE_NAME=<FQDN> \
      -e SEED_SECRET_KEY=(openssl rand -hex 16) \
      -e EXPERIMENT_ID=EXP_1 \
      -e PORT=4567 \
      -l 'traefik.http.routers.odohproxy.rule=Host(`<FQDN>`)' \
      -l 'traefik.http.routers.odohproxy.tls=true' \
      odoh-server-go:latest

Run the container with **Traefik** as a frontend and **TLS** to the backend.

    docker run -it -d \
      --name odoh-server-relay \
      -p 4567:4567/tcp \
      -v /Users/marco/MyData/Secure/Certificates/<CertFolder>:/certs \
      -e TARGET_INSTANCE_NAME=<FQDN> \
      -e SEED_SECRET_KEY=(openssl rand -hex 16) \
      -e EXPERIMENT_ID=EXP_1 \
      -e CERT=/certs/<CertFullChain>.cer \
      -e KEY=/certs/<CertKey>.key \
      -e PORT=4567 \
      -l "traefik.http.routers.odohproxy.rule=Host(`<FQDN>`)" \
      -l "traefik.http.routers.odohproxy.tls=true" \
      -l "traefik.http.services.odohproxy.loadbalancer.server.scheme=https" \
      -l "traefik.http.services.odohproxy.loadbalancer.serversTransport=odohproxy@file" \
      odoh-server-go:latest
