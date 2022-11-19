FROM docker.io/alpine:3.17

ADD https://github.com/smallstep/certificates/releases/download/v0.23.0/step-ca_0.23.0.tar.gz /
RUN mkdir ca \
  && cd ca \
  && tar xfvz ../step-ca_0.23.0.tar.gz \
  && rm ../step-ca_0.23.0.tar.gz \
  && apk --no-cache add --virtual build-dependencies build-base pcsc-lite-dev pkgconfig go bash curl \
  && make bootstrap \
  && go mod tidy \
  && go mod download \
  && make build GOFLAGS="" \
  && apk del build-dependencies \

