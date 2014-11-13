FROM ubuntu

RUN apt-get update -y && apt-get install --no-install-recommends -y -q curl build-essential ca-certificates git mercurial bzr
RUN mkdir /goroot && curl https://storage.googleapis.com/golang/go1.3.1.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1
RUN mkdir /gopath

ENV GOROOT /goroot
ENV GOPATH /gopath:/registry
ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin

ADD . /registry
ADD bin/confd /usr/local/bin/confd
RUN chmod +x /usr/local/bin/confd
ADD confd /etc/confd
RUN mkdir /etc/registry
RUN go get github.com/cespare/go-apachelog && go get github.com/crowdmob/goamz/aws && go get github.com/crowdmob/goamz/s3 && go get github.com/gorilla/mux
RUN cd /registry && go build -o bin/registry registry.go

EXPOSE 5000
CMD confd -onetime -backend env && /registry/bin/registry -config /etc/registry/conf.json
