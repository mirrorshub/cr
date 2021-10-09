FROM alpine
RUN apk add --update --no-cache ca-certificates bash skopeo jq python3 py3-pip && pip3 install yq
