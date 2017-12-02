#!/usr/bin/env bash
export BOOT="$(readlink -f $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))"

## build parameters
export USER=$USER
export USERID=`id -u`
## valid combinations for NCORES/MEMORY are:
## 8/12, 8/16, 16/6, 16/8, 32/4, 32/8, 64/4, 64/8
## i.e. at least 96GB are needed
export NCORES=64
export MEMORY=4
export BUILD_TAG=rel3
export BUILD_NAME=build_$BUILD_TAG

## build stages
export BUILD_GXUSER=true
export BUILD_REFS=true
export BUILD_TOOLS=true
export BUILD_INDICES=true
export BUILD_BIOC=true
export BUILD_CRISP=true
export BUILD_CODAC=true
export BUILD_RELEASE=true
export BUILD_TEST=true

## settings
export GXCORE_VER=1.6.6
export REFS_VER=1.0.6
export CODAC_VER=3.4.3
export CRISP_VER=2.5.0
export BIOC_VER=161117
export CODAC_GTF='$REFS/gtf/motr.v2/motr.v2-full.gtf'
export CODAC_GMAP='$REFS/indices/gmap/hg38.rna'
export CODAC_MM2='$REFS/indices/minimap2/hg38.rna.mmi'
export ALIGN_GTF='$REFS/gtf/motr.v2/motr.v2-alig.gtf'
export ALIGN_FA='$REFS/genomes/hg38.rna.fa'
export ALIGN_NAME='hg38.rna-motr.v2'
export REFS_URL="https://storage.googleapis.com/crisp-mctp/release/refs_${REFS_VER}.tar.gz"
export BIOC_URL="https://storage.googleapis.com/crisp-mctp/release/bioc_${BIOC_VER}.tar.gz"
export CODAC_URL="https://storage.googleapis.com/crisp-mctp/release/codac_${CODAC_VER}.tar.gz"
export CRISP_URL="https://storage.googleapis.com/crisp-mctp/release/crisp_${CRISP_VER}.tar.gz"
export GXCORE_URL="https://storage.googleapis.com/crisp-mctp/release/gxcore_docker_${GXCORE_VER}.tar.gz"

chmod 755 $BOOT/context/*.sh

bash context/build_all.sh
