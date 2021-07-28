FROM golang:alpine as builder

# Install git and make
RUN apk update && apk add --no-cache git make

ENV APP_USER app
ENV APP_HOME /app
RUN mkdir -p $APP_HOME/build
WORKDIR $APP_HOME/build

RUN git clone https://github.com/cloudflare/odoh-server-go.git . \
    && git checkout 7986d2f1d986205922cf7add0dfa2116d5ef6fae \
    && git reset --hard

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 make all \
    && cp -p odoh-server $APP_HOME/

WORKDIR $APP_HOME

RUN rm -rf build


FROM alpine

ENV APP_USER app
ENV APP_HOME /app
WORKDIR $APP_HOME

ENV LOCAL_PORT 4576

COPY --chown=0:0 --from=builder $APP_HOME/odoh-server $APP_HOME/
COPY --chown=0:0 --from=builder $APP_HOME/odoh-server /usr/local/bin/odoh-server

EXPOSE $LOCAL_PORT/tcp $LOCAL_PORT/udp

ENTRYPOINT ["/app/odoh-server"]
CMD [""]

