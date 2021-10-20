FROM ubuntu:20.10
RUN apt-get update && apt-get install -y skopeo jq python3 python3-pip && pip3 install yq
