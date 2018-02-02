#!/usr/bin/env bash

IMAGE_NAME=publysher/alpine-numpy

function build() {
    version=$1
    base_image=$2

    dir=dockerfiles/${version}/${base_image}/

    image_version=${version}-python${base_image}
    image=${IMAGE_NAME}:${image_version}

    mkdir -p ${dir}

    cat <<EOF > ${dir}/Dockerfile
FROM python:${base_image}

RUN apk --no-cache add --virtual .builddeps gcc gfortran musl-dev \
    && pip install numpy==${version} \
    && apk del .builddeps \
    && rm -rf /root/.cache
EOF

    echo "/${dir}\t${image}" >> build-settings.txt

    docker build -t ${image} ${dir}

    cp ${dir}/Dockerfile Dockerfile     # overwrite root Dockerfile, which is used for `latest`
}

build 1.14.0 3.6-alpine3.6
build 1.14.0 3.6-alpine3.7

docker build -t ${IMAGE_NAME}:latest .