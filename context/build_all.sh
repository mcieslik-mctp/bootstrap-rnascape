#!/usr/bin/env bash
mkdir -p $BOOT/$BUILD_NAME
cd $BOOT/$BUILD_NAME

## BUILD GXUSER
wget $GXCORE_URL
docker load --input gxcore_docker_${GXCORE_VER}.tar.gz
docker tag gxcore:$GXCORE_VER gxcore:latest
docker build -t gx${USER}:$GXCORE_VER --build-arg user=$USER --build-arg userid=$USERID $BOOT/context/gxuser
docker tag gx${USER}:$GXCORE_VER gx${USER}:latest

## BUILD REFS
wget $REFS_URL
tar xf refs_${REFS_VER}.tar.gz
docker run --user=$USER \
       -e NCORES=$NCORES \
       -e ALIGN_FA=$ALIGN_FA \
       -e ALIGN_GTF=$ALIGN_GTF \
       -e ALIGN_NAME=$ALIGN_NAME \
       -v $BOOT/$BUILD_NAME/refs:/refs \
       -v $BOOT/context/:/context \
       gx${USER}:latest /context/build_refs.sh

## BUILD CRISP
wget $CRISP_URL
tar xf crisp_${CRISP_VER}.tar.gz
mv crisp $BOOT/$BUILD_NAME/refs

## build CODAC
wget $CODAC_URL
tar xf codac_${CODAC_VER}.tar.gz
docker run --user=$USER \
       -e NCORES=$NCORES \
       -e CODAC_GTF=$CODAC_GTF \
       -e CODAC_VER=$CODAC_VER \
       -v $BOOT/$BUILD_NAME/refs:/refs \
       -v $BOOT/context/:/context \
       -v $BOOT/$BUILD_NAME/codac:/codac \
       gx${USER}:latest /context/build_codac.sh
