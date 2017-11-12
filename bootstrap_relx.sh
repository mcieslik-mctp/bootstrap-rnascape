#!/usr/bin/env bash
export BOOT="$(readlink -f $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))"
export USER=$USER
export USERID=`id -u`
export GXCORE_VER=1.6.5
export REFS_VER=1.0.5
export CODAC_VER=3.3.2
export CRISP_VER=2.4.2
export NCORES=64
export CODAC_GTF='$REFS/gtf/motr.v2/motr.v2-full.gtf'
export ALIGN_GTF='$REFS/gtf/motr.v2/motr.v2-alig.gtf'
export ALIGN_FA='$REFS/genomes/hg38.rna.fa'
export ALIGN_NAME='hg38.rna-motr.v2'

export REFS_URL="https://storage.googleapis.com/crisp-mctp/release/refs_${REFS_VER}.tar.gz"
export CODAC_URL="https://storage.googleapis.com/crisp-mctp/release/codac_${CODAC_VER}.tar.gz"
export CRISP_URL="https://storage.googleapis.com/crisp-mctp/release/crisp_${CRISP_VER}.tar.gz"
export GXCORE_URL="https://storage.googleapis.com/crisp-mctp/release/gxcore_docker_${GXCORE_VER}.tar.gz"
export BUILD_TAG=relx
export BUILD_NAME=build_$BUILD_TAG

export BUILD_GXUSER=false
export BUILD_REFS=false
export BUILD_CRISP=false
export BUILD_CODAC=false
export BUILD_RELEASE=false
export BUILD_GOOGLE=false

bash context/build_all.sh
