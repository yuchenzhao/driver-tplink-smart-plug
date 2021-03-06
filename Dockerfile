FROM golang:1.10.3-alpine3.8 as gobuild
WORKDIR /
ENV GOPATH="/"
RUN apk update && apk add pkgconfig build-base bash autoconf git libzmq zeromq-dev
COPY . .
RUN go get -d github.com/gorilla/mux
RUN go get -d github.com/me-box/lib-go-databox
RUN go get -d github.com/sausheong/hs1xxplug
RUN addgroup -S databox && adduser -S -g databox databox
RUN GGO_ENABLED=0 GOOS=linux go build -a -tags netgo -installsuffix netgo -ldflags '-s -w' -o app /src/app.go

FROM amd64/alpine:3.8
COPY --from=gobuild /etc/passwd /etc/passwd
RUN apk update && apk add libzmq
USER databox
WORKDIR /
COPY --from=gobuild /app .
COPY --from=gobuild /www/ /www/
COPY --from=gobuild /tmpl/ /tmpl/
LABEL databox.type="driver"
EXPOSE 8080

CMD ["./app"]
#CMD ["sleep","2147483647"]
