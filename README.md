# README

![Maintenance](https://img.shields.io/maintenance/yes/2018.svg)
[![Build Status](https://quay.io/repository/littlemanco/snipe-it/status "Build Status")](https://quay.io/repository/littlemanco/snipe-it/)
[![Build Status](https://travis-ci.org/littlemanco/docker-snipe-it.svg?branch=master)](https://travis-ci.org/littlemanco/docker-snipe-it)

## Warranty

These images are released as a hobby, and without any kind of warranty (implied or otherwise).

## Justification

There is already an existing image available in the Snipe repository. However, I disagree with some of the technical
decisions that have been made. Specifically, I already have an image that builds an Apache container with some defaults
I quite like, including:

  - Status page configured for metrics
  - Logs exposed in JSON in a structured way
  - TLS configured and optimised

Additionally, I don't like how the image in the upstream repository is structured. It requires quite a bit of bootstrap
to get the application running, and I like the image to be as "dumb" as possible.

## Usage

It's documented in docker-compose. Alternatively, a helm chart will be created.
