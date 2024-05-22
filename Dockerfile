FROM docker.io/alpine:3.20

ADD entrypoint.sh /entrypoint.sh
ADD https://github.com/smallstep/certificates/releases/download/v0.24.1/step-ca_0.24.1.tar.gz /
RUN mkdir -p src ca/bin \
  && cd src \
  && tar xfvz ../step-ca_0.24.1.tar.gz \
  && apk --no-cache add --virtual build-dependencies build-base pkgconfig go bash curl pcsc-lite-dev \
  && apk --no-cache add libcap pcsc-lite pcsc-lite-libs ccid yubikey-manager \
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
  && setcap CAP_NET_BIND_SERVICE=+eip /ca/bin/step-ca \
  && adduser -S step \
  && chown step: /ca

USER step
ENV STEPPATH="/data"
STOPSIGNAL SIGTERM
ENTRYPOINT ["/entrypoint.sh"]
# pcscd -f -T -d
