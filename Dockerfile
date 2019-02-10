FROM golang AS builder
WORKDIR /
ADD . .
RUN curl https://glide.sh/get | sh
RUN apt-get update && apt-get install -y git
RUN go get github.com/flashmob/go-guerrilla
RUN cd /go/src/github.com/flashmob/go-guerrilla && glide install && make guerrillad
RUN mkdir /app && cp /go/src/github.com/flashmob/go-guerrilla/guerrillad /app/ && cp /go/src/github.com/flashmob/go-guerrilla/goguerrilla.conf.sample /app/goguerrilla.conf.json

FROM alpine

RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

WORKDIR /app

COPY --from=builder "/app" .

RUN mkdir /config

VOLUME /config

CMD ["/app/guerrillad", "serve", "-c", "/config/goguerrilla.conf.json"]
