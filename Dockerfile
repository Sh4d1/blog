# syntax=docker/dockerfile:1
FROM alpine:3.13 AS build
# thanks to https://blog.callr.tech/static-blog-hugo-docker-gitlab/

RUN apk add --no-cache git curl

ARG HUGO_VERSION=0.83.0

RUN curl -fsSL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz | tar -xzvf -

COPY . /site
WORKDIR /site
RUN /hugo --minify --enableGitInfo

FROM nginx:1.20-alpine
WORKDIR /usr/share/nginx/html/
RUN rm -fr * .??*
COPY expires.inc /etc/nginx/conf.d/expires.inc
COPY default.conf /etc/nginx/conf.d/default.conf
RUN chmod 0644 /etc/nginx/conf.d/expires.inc
COPY --from=build /site/public .
