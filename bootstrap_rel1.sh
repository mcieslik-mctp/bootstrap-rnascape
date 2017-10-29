#!/usr/bin/env bash
export BOOT="$(readlink -f $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))"
export USER=$USER
export USERID=`id -u`
export GXCORE_VER=1.6.0
export REFS_VER=1.0.0
export CODAC_VER=3.2.2
export CRISP_VER=2.0.0
export NCORES=64
export CODAC_GTF='$REFS/gtf/motr.v1/motr.v1-pipe.gtf'
export ALIGN_GTF='$REFS/gtf/motr.v1/motr.v1-alig.gtf'
export ALIGN_FA='$REFS/genomes/GRCh38.analysis_set.fa'
export ALIGN_NAME='GRCh38.analysis_set-motr.v1'

export REFS_URL="https://storage.googleapis.com/crisp-mctp/release/refs_${REFS_VER}.tar.gz"
export CODAC_URL="https://storage.googleapis.com/crisp-mctp/release/codac_${CODAC_VER}.tar.gz"
export CRISP_URL="https://storage.googleapis.com/crisp-mctp/release/crisp_${CRISP_VER}.tar.gz"
export GXCORE_URL="https://storage.googleapis.com/crisp-mctp/release/gxcore_docker_${GXCORE_VER}.tar.gz"
export BUILD_NAME=build_rel1

bash context/build_all.sh
