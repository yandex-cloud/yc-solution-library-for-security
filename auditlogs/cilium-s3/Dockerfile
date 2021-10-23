FROM golang:1.16-alpine AS build
##
## Build
##
WORKDIR /cilium-splunk

COPY go.mod ./
COPY go.sum ./

RUN go mod download

COPY ./cmd/cilium-exporter ./cmd/cilium-exporter
COPY ./internal ./internal
COPY ./config.yaml.example ./

RUN go build -o /cilium-exporter ./cmd/cilium-exporter/main.go 

##
## Deploy
##
#FROM golang:1.16-alpine
FROM alpine:3.14
WORKDIR /
COPY --from=build /cilium-exporter /cilium-exporter
ENTRYPOINT ["/cilium-exporter"]


