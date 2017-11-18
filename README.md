# RNAScape bootstrap procedure

The following procedure will result in the creation of a working RNAScape installation.

In that process these steps will be executed:
- download all required reference files, images, and code
- build a docker image capable of executing RNAScape
- build indices/caches for samtools, STAR, Minimap2, and GMAP
- install CRISP and CODAC
- test CRISP and CODAC

The process will take approx. 8h to finish. The final output is a large "refs" folder which contains all the references, software, libraries etc. and a docker image `gx${USER}`. The recommended hardware has at least 8 cores and 96GB of RAM, although very rarely (<<1%) more than 64GB is needed.

1. Make sure the following dependencies are installed:
```
- bash
- git
- wget
- pigz (important not always installed!)
- docker
- tar
```

2. The user shoud have also full permissions to use docker tested on version 1.13.1 and 17.05.0-ce

RNAScape bundles great software by other people:
```
- STAR
- featureCounts
- samtools
- Bioconductor core
- data.table
- stringr
- Inchworm
- Minimap2
- GMAP
- sambamba
- MiXCR
- Jellyfish
- bbmap
- FastQC
- bedtools
- seqtk
```

## Installation instructions

1. Clone this repository:
```
git clone https://github.com/mcieslik-mctp/bootstrap-rnascape
cd bootstrap-rnascape
```

2. Configure/edit settings `bootstra_rnascape.sh`:
```
## build parameters
## by default the current user name and id is embedded into the image change if necessary
export USER=$USER
export USERID=`id -u`
## number of cpu-cores
export NCORES=64
## release tag
export BUILD_TAG=relx
export BUILD_NAME=build_$BUILD_TAG
## select which steps to execute (all are needed for 
export BUILD_GXUSER=true
export BUILD_REFS=true
export BUILD_TOOLS=true
export BUILD_INDICES=true
export BUILD_BIOC=true
export BUILD_CRISP=true
export BUILD_CODAC=true
export BUILD_RELEASE=true
export BUILD_TESTCRISP=true
```

3. Build (6-8h)
```
bash bootstrap_rnascape.sh
```

4. Inspect the output of the `build_$BUILD_TAG` directory:
```
#### final output needed to run RNAscape
## the customized docker image
gx${USER}_docker_1.6.5.tar.gz
## the complete "refs" folder
rnascape_relx.tar.gz # tared 
refs # un-tared
## example CRISP/CODAC test-runs 
test.codac
test.crisp
```

The following files can be deleted:
```
## downloaded FASTQ files for test
repo
## downloaded files (can be removed)
refs_$VER.tar.gz
bioc_$VER.tar.gz
codac_$VER.tar.gz
crisp_$VER.tar.gz
```
