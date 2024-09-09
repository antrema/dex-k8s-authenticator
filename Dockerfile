##########################
# Step 1 Build binary
##########################
FROM --platform=$BUILDPLATFORM golang:1.23.1-alpine AS builder
RUN apk update && apk add --no-cache git bash
WORKDIR /app
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o  bin/dex-k8s-authenticator *.go
##########################
# Step 2 Build a small image
##########################
FROM alpine
# Dex connectors, such as GitHub and Google logins require root certificates.
# Proper installations should manage those certificates, but it's a bad user
# experience when this doesn't work out of the box.
#
# OpenSSL is required so wget can query HTTPS endpoints for health checking.
RUN apk update && apk add --no-cache ca-certificates openssl curl tini \
  && rm -rf /var/cache/apk/*
RUN mkdir -p /app/bin
COPY --from=builder /app/bin/dex-k8s-authenticator /app/bin/
COPY --from=builder /app/html /app/html
COPY --from=builder /app/templates /app/templates

# Add any required certs/key by mounting a volume on /certs
# The entrypoint will copy them and run update-ca-certificates at startup
RUN mkdir -p /certs

WORKDIR /app

COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]

CMD ["--help"]
