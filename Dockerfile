FROM docker.io/alpine:3.16

ADD https://github.com/smallstep/certificates/releases/download/v0.23.0/step-ca_0.23.0.tar.gz /
RUN mkdir -p src ca/bin \
  && cd src \
  && tar xfvz ../step-ca_0.23.0.tar.gz \
  && apk --no-cache add --virtual build-dependencies build-base pcsc-lite-dev pkgconfig go bash curl \
  && apk --no-cache add libcap \
  && make bootstrap \
  && go mod tidy \
  && go mod download \
  && make build GOFLAGS="" \
  && apk del build-dependencies \
  && cp /src/bin/step-ca \
        /src/bin/step-awskms-init \
        /src/bin/step-cloudkms-init \
        /src/bin/step-pkcs11-init \
        /src/bin/step-yubikey-init \
        /ca/bin/ \
  && rm -rf /step-ca_0.23.0.tar.gz ~/go /src \
  && setcap CAP_NET_BIND_SERVICE=+eip /ca/bin/step-ca

ENV STEPPATH="/data"
STOPSIGNAL SIGTERM
ENTRYPOINT ["/ca/bin/step-ca"]
