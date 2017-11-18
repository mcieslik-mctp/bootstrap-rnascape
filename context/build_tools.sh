#!/usr/bin/env bash
HERE="$(readlink -f $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))"
REFS=/refs

mkdir -p $REFS/{bin,tmp}

#### BIN

## build STAR
cd $REFS/tmp
cp $REFS/tools/STAR_2.4.0g1.tgz .
tar xf STAR_2.4.0g1.tgz
cd STAR-STAR_2.4.0g1/source
make STAR
mv STAR $REFS/bin

## Build Samtools
cd $REFS/tmp
cp $REFS/tools/samtools-1.4.1.tar.bz2 .
tar xf samtools-1.4.1.tar.bz2
cd samtools-1.4.1
./configure
make -j $NCORES
cd $REFS/tmp
mv samtools-1.4.1/samtools $REFS/bin

## Build Inchworm
cd $REFS/tmp
cp $REFS/tools/inchworm_19032017.tar.gz .
tar xf inchworm_19032017.tar.gz
cd Inchworm
./configure
make
cd $REFS/tmp
mv Inchworm/src/inchworm $REFS/bin

## Build gmap
cd $REFS/tmp
cp $REFS/tools/gmap-gsnap-2017-10-30p.tar.gz .
tar xf gmap-gsnap-2017-10-30p.tar.gz
cd gmap-2017-10-30
mkdir -p $REFS/bin/gmap-install $REFS/indices/gmap
./configure --prefix=$REFS/bin/gmap-install --with-gmapdb=$REFS/indices/gmap
make -j $NCORES
make install
ln -sfn $REFS/bin/gmap-install/bin/gmap $REFS/bin/gmap
ln -sfn $REFS/bin/gmap-install/bin/gmap.sse42 $REFS/bin/gmap.sse42
ln -sfn $REFS/bin/gmap-install/bin/gmap.nosimd $REFS/bin/gmap.nosimd

## Build minimap2
cd $REFS/tmp
cp $REFS/tools/minimap2-05112017.tar.gz .
tar xf minimap2-05112017.tar.gz
cd minimap2
make -j $NCORES
mv minimap2 $REFS/bin

## clean
rm -rf $REFS/tmp
