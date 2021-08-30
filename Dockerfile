FROM golang:alpine as builder

# Install git and make
RUN apk update && apk add --no-cache git make

ENV APP_USER app
ENV APP_HOME /app
RUN mkdir -p $APP_HOME/build
WORKDIR $APP_HOME/build

ARG TARGETOS
ARG TARGETARCH

ARG CGO_ENABLED=0

RUN git clone https://github.com/cloudflare/odoh-server-go.git . \
    && git checkout 5a9bf1f5b7b3f676558e8a4e50f94abd032ceb4a \
    && git reset --hard

RUN CGO_ENABLED=${CGO_ENABLED} GOOS=${TARGETOS} GOARCH=${TARGETARCH} make all \
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

