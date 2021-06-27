FROM golang AS builder
COPY . /go/src/github.com/rclone/rclone/
WORKDIR /go/src/github.com/rclone/rclone/
RUN make quicktest
#Feel free to change to build ARG
ENV CGO_ENABLED 0
ENV GOOS linux
ENV GOARCH amd64
RUN make
RUN ./rclone version
FROM centos/systemd
#Below writes the /config/rclone/rclone.conf
ENV RCLONE_CONFIG_NAME box-new
ENV RCLONE_CONFIG_TYPE box
ENV RCLONE_CONFIG_TOKEN {"access_token"}
RUN yum install -y ca-certificates fuse  && \
yum clean all
#ENV XDG_CONFIG_HOME=/config
#RUN rclone config dump
RUN  printf "[$RCLONE_CONFIG_NAME]\ntype = $RCLONE_CONFIG_TYPE\ntoken = $RCLONE_CONFIG_TOKEN\n" > ~/rclone.conf
COPY --from=builder /go/src/github.com/rclone/rclone/rclone /usr/local/bin/
#CMD for adding layers later
CMD [ "rclone" ]
WORKDIR /data
#ENV XDG_CONFIG_HOME=/config
RUN rclone config dump
RUN  printf "[$RCLONE_CONFIG_NAME]\ntype = $RCLONE_CONFIG_TYPE\ntoken = $RCLONE_CONFIG_TOKEN\n" > ~/.config/rclone/rclone.conf
