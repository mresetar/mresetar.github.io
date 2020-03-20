---
title: Squashing Docker Images
layout: post
subtitle: Using docker --squash to shrink image size
bigimg: /uploads/copenhagen-bike-500-2019.jpg
tags: [docker, squash, cli]
---

# Docker Image Layers

When building Docker image it is build in layers. Each line in the `Dockerfile` is potentially a new read only layer
containing the difference from the last one. There are a lot of rules and [best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) how to write efficient Dockerfiles. 
[Multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/) is for sure effective technique 
to keep Docker image size down.
When looking how to keep image size down, using multi-stage build is probably first thing to try. 
But sometimes it is not enough. There is another thing to do. 

## Building Image Without Squash

Let's say that we have simple Dockerfile as follows: 

```
FROM registry.access.redhat.com/ubi7/ubi-minimal

WORKDIR /tmp

# Download archive
RUN curl -OL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
# Do some work in image such as install
RUN for i in {1..10}; do cp jq-linux64 "jq-linux64-${i}"; done
# Move & clean up mess
RUN chmod +x jq-linux64 && mv jq-linux64 /usr/local/bin/jq && rm -f jq-linux64-*
```

Basically, we will have 5 layers here:

 1. FROM layer with `ubi-minimal` image
 1. Setting the Workdir. This will be empty layer.
 1. Download of `curl` from Github
 1. Simulating some _install_ work by copying image 10 times. This is to show some significant increase in size. 
 1. Adding execute permission and moving one copy to `bin` directory. Removing all the copies from step before.

If we build and tag the image using `docker build -t ubi-minimal-jq-large`.
Command output will be as follows.

```
Sending build context to Docker daemon  3.957MB
Step 1/5 : FROM registry.access.redhat.com/ubi7/ubi-minimal
 ---> 082938f7edb4
Step 2/5 : WORKDIR /tmp
 ---> Using cache
 ---> 16817fdcdc65
Step 3/5 : RUN curl -OL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
 ---> Using cache
 ---> 64e1f4a0c60e
Step 4/5 : RUN for i in {1..10}; do cp jq-linux64 "jq-linux64-${i}"; done
 ---> Using cache
 ---> 5fc84ca5c133
Step 5/5 : RUN chmod +x jq-linux64 && mv jq-linux64 /usr/local/bin/jq && rm -f jq-linux64-*
 ---> Using cache
 ---> 51ba9d9e5712
Successfully built 51ba9d9e5712
Successfully tagged ubi-minimal-jq-large:latest
```

We can see all the layers with the command `docker history --no-trunc ubi-minimal-jq-large`.

```
IMAGE                          CREATED      CREATED BY                                                                                SIZE     COMMENT
sha256:51ba9d9e57128c08762feb5 28 hours ago /bin/sh -c chmod +x jq-linux64 && mv jq-linux64 /usr/local/bin/jq && rm -f jq-linux64-*   3.95MB
sha256:5fc84ca5c133b6dd8a2f0e5 28 hours ago /bin/sh -c for i in {1..10}; do cp jq-linux64 "jq-linux64-${i}"; done                     39.5MB
sha256:64e1f4a0c60ec1ea26c317b 28 hours ago /bin/sh -c curl -OL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64    3.97MB
sha256:16817fdcdc65ac2f7ea5905 28 hours ago /bin/sh -c #(nop) WORKDIR /tmp                                                            0B
sha256:082938f7edb4059fdbc633c 7 weeks ago                                                                                            6.94kB
<missing>                      7 weeks ago                                                                                            81.3MB   Imported from -
```

To recapitulate, we go from bottom to top. 

 - Layer 0: Imported image with 81.3MB.
 - Layer 1: FROM instruction layer is 6.94kB.
 - Layer 2: setting workdir is 0B. 
 - Layer 3: downloading curl is 3.97MB. Almost exact the size of `jq`. 
 - Layer 4: Copying `jq` 10 times is about 39.5MB. 
 - Layer 5: Moving `jq` to bin is 3.95MB. 

Inspecting image gives us the total size of the image. 129 megabytes.

```
ubi-minimal-jq-large                          latest                                    51ba9d9e5712        29 hours ago        129MB
```

## Squashing a Image

Lets try to build the same image using `--squash` experimental feature. How to turn it on is [here](https://mresetar.github.io/2020-03-18-how-to-enable-docker-experimental-mode-on-windows/).

Build command looks like: `docker build --squash -t ubi-minimal-jq-squashed .`.

To inspect the layers of the squashed image we run the following: `docker history --no-trunc ubi-minimal-jq-squashed`.

```
IMAGE                                                                     CREATED             CREATED BY                                                                                SIZE                COMMENT
sha256:fc22c63ae312bd0df637d24fae5d440f9141d14c2638781f27183aaf37cd920a   11 hours ago                                                                                                  3.97MB              merge sha256:51ba9d9e57128c08762feb57527f1e357b598f04718d045e3ad285910dc4dc19 to sha256:082938f7edb4059fdbc633cca93085b09a27774908d0a35327deadeee174cde0
<missing>                                                                 31 hours ago        /bin/sh -c chmod +x jq-linux64 && mv jq-linux64 /usr/local/bin/jq && rm -f jq-linux64-*   0B
<missing>                                                                 31 hours ago        /bin/sh -c for i in {1..10}; do cp jq-linux64 "jq-linux64-${i}"; done                     0B
<missing>                                                                 31 hours ago        /bin/sh -c curl -OL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64    0B
<missing>                                                                 31 hours ago        /bin/sh -c #(nop) WORKDIR /tmp                                                            0B
<missing>                                                                 7 weeks ago                                                                                                   6.94kB
<missing>                                                                 7 weeks ago                                                                                                   81.3MB              Imported from -
```

In squashed image we see that all the layers in between the FROM and last layers are with size of 0B. If we look
at the resulting image size (`docker images | grep ubi-minimal-jq-squashed`) it is 85.3MB.

```
ubi-minimal-jq-squashed                       latest                                    ee5948b88859        14 hours ago        85.3MB
```

So we decreased image size from 129 to 85.3 megabytes. Save of almost 44 megabytes or 33 percent.

But it comes with price, right? Right. All of the Dockerfile in-between layers are lost and can't be reused 
between images. But if we wan't as small image, treadoff is worth it. 

### How To Tell That Image Was Squashed?

There is one indicator that will tell you that image was squashed when built. 
We can take a look into the comment of the top layer. If it has keywords like `merge` and `to`, 
e.g. `merge sha256:51ba9d9e57128c08762feb57527f1e357b598f04718d045e3ad285910dc4dc19 to sha256:082938f7edb4059fdbc633cca93085b09a27774908d0a35327deadeee174cde0` and layers below are size of 0 bytes, image 
was squashed. 
