FROM ruby:2.4.2-slim

RUN apt-get update && apt-get install -qq -y --no-install-recommends \
      build-essential nodejs libpq-dev imagemagick

ENV INSTALL_PATH /formsconstructor

RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY Gemfile ./

ENV BUNDLE_PATH /box

COPY . .
