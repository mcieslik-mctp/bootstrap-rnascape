#!/usr/bin/env bash
mkdir -p $BOOT/$BUILD_NAME
cd $BOOT/$BUILD_NAME

## BUILD GXUSER
if [ "$BUILD_GXUSER" = true ]; then
    wget -N $GXCORE_URL
    docker load --input gxcore_docker_${GXCORE_VER}.tar.gz
    docker tag gxcore:${GXCORE_VER} gxcore:temp 
    docker build -t gx${USER}:$GXCORE_VER --build-arg user=$USER --build-arg userid=$USERID $BOOT/context/gxuser
    docker rmi gxcore:temp
fi

## BUILD REFS
if [ "$BUILD_REFS" = true ]; then
    wget -N $REFS_URL
    tar xf refs_${REFS_VER}.tar.gz
fi

## BUILD TOOLS
if [ "$BUILD_TOOLS" = true ]; then
    docker run --user=$USER \
           -e NCORES=$NCORES \
           -e ALIGN_FA=$ALIGN_FA \
           -e ALIGN_GTF=$ALIGN_GTF \
           -e ALIGN_NAME=$ALIGN_NAME \
           -v $BOOT/$BUILD_NAME/refs:/refs \
           -v $BOOT/context/:/context \
           gx${USER}:$GXCORE_VER /context/build_tools.sh
fi

## BUILD REFS
if [ "$BUILD_INDICES" = true ]; then
    docker run --user=$USER \
           -e NCORES=$NCORES \
           -e ALIGN_FA=$ALIGN_FA \
           -e ALIGN_GTF=$ALIGN_GTF \
           -e ALIGN_NAME=$ALIGN_NAME \
           -v $BOOT/$BUILD_NAME/refs:/refs \
           -v $BOOT/context/:/context \
           gx${USER}:$GXCORE_VER /context/build_indices.sh
fi

## BUILD BIOC
if [ "$BUILD_BIOC" = true ]; then
    wget -N $BIOC_URL
    tar xf bioc_${BIOC_VER}.tar.gz
    mkdir -p $BOOT/$BUILD_NAME/refs/libs
    mv $BOOT/$BUILD_NAME/bioc_${BIOC_VER} $BOOT/$BUILD_NAME/refs/libs/r
fi

## BUILD CRISP
if [ "$BUILD_CRISP" = true ]; then
    wget -N $CRISP_URL
    tar xf crisp_${CRISP_VER}.tar.gz
    mv crisp $BOOT/$BUILD_NAME/refs
fi

## build CODAC
if [ "$BUILD_CODAC" = true ]; then
    wget -N $CODAC_URL
    tar xf codac_${CODAC_VER}.tar.gz
    docker run --user=$USER \
           -e NCORES=$NCORES \
           -e CODAC_GTF=$CODAC_GTF \
           -e CODAC_VER=$CODAC_VER \
           -e CODAC_GMAP=$CODAC_GMAP \
           -e CODAC_MM2=$CODAC_MM2 \
           -v $BOOT/$BUILD_NAME/refs:/refs \
           -v $BOOT/context/:/context \
           -v $BOOT/$BUILD_NAME/codac:/codac \
           gx${USER}:$GXCORE_VER /context/build_codac.sh
fi

## release
if [ "$BUILD_RELEASE" = true ]; then
    tar -cf - --exclude-vcs --directory $(pwd) refs | pigz -p $NCORES > $(pwd)/rnascape_$BUILD_TAG.tar.gz
    docker save -o $(pwd)/gx${USER}_docker_$GXCORE_VER.tar gx${USER}:$GXCORE_VER
    pigz -p $NCORES $(pwd)/gx${USER}_docker_$GXCORE_VER.tar
fi

## test crisp
if [ "$BUILD_TESTCRISP" = true ]; then
    export REFDIR=$BOOT/$BUILD_NAME/refs
    export REPDIR=$BOOT/$BUILD_NAME/repo
    mkdir -p $BOOT/$BUILD_NAME/repo
    cd $BOOT/$BUILD_NAME/repo
    wget -N https://storage.googleapis.com/crisp-mctp/repo/mctp_SI_18670_HTW2NBCXY_0_1.fq.gz
    wget -N https://storage.googleapis.com/crisp-mctp/repo/mctp_SI_18670_HTW2NBCXY_0_2.fq.gz
    wget -N https://storage.googleapis.com/crisp-mctp/repo/mctp_SI_18676_HTW2NBCXY_0_1.fq.gz
    wget -N https://storage.googleapis.com/crisp-mctp/repo/mctp_SI_18676_HTW2NBCXY_0_2.fq.gz
    cp -r $BOOT/context/test.crisp $BOOT/$BUILD_NAME
    bash $BOOT/$BUILD_NAME/test.crisp/job.sh
    export REPDIR=$BOOT/$BUILD_NAME/test.crisp/out
    cp -r $BOOT/context/test.codac $BOOT/$BUILD_NAME
    bash $BOOT/$BUILD_NAME/test.codac/job.sh
fi
