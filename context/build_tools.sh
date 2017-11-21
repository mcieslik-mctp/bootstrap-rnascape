#!/usr/bin/env bash
HERE="$(readlink -f $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))"
REFS=/refs

mkdir -p $REFS/{bin,tmp}

#### BIN

## Build bamUtils
cd $REFS/tmp
cp $REFS/tools/bamUtil-181117.tar.gz .
tar xf bamUtil-181117.tar.gz
cd bamUtil/bamUtil
make -j $NCORES
cp bin/bam $REFS/bin

## Build bbmap
cd $REFS/tmp
cp $REFS/tools/BBMap_37.36.tar.gz .
tar xf BBMap_37.36.tar.gz
cd bbmap/jni
JAVA_HOME=/usr/lib/jvm/java-8-oracle/ make -f makefile.linux 
cd ../..
mv bbmap $REFS/bin
ln -sfn $REFS/bin/bbmap/bbduk2.sh $REFS/bin
ln -sfn $REFS/bin/bbmap/bbmerge.sh $REFS/bin

## Build bedtools
cd $REFS/tmp
cp $REFS/tools/bedtools-2.26.0.tar.gz .
tar xf bedtools-2.26.0.tar.gz
cd bedtools2
make -j $NCORES
mv bin/bedtools $REFS/bin

## Build FastQC
cd $REFS/tmp
cp $REFS/tools/fastqc_v0.11.5.zip .
unzip fastqc_v0.11.5.zip
mv FastQC $REFS/bin
echo '#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$DIR/FastQC/fastqc "$@"
' > $REFS/bin/fastqc
chmod +x $REFS/bin/fastqc

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

## Build Inchworm
cd $REFS/tmp
cp $REFS/tools/inchworm_19032017.tar.gz .
tar xf inchworm_19032017.tar.gz
cd Inchworm
./configure
make -j $NCORES
cd $REFS/tmp
mv Inchworm/src/inchworm $REFS/bin

## Build Jellyfish
cd $REFS/tmp
cp $REFS/tools/jellyfish-2.2.7.tar.gz .
tar xf jellyfish-2.2.7.tar.gz 
cd jellyfish-2.2.7
./configure --prefix=$REFS/bin/Jellyfish
make -j $NCORES
make install
ln -sfn $REFS/bin/Jellyfish/bin/jellyfish $REFS/bin

## Build minimap2
cd $REFS/tmp
cp $REFS/tools/minimap2-05112017.tar.gz .
tar xf minimap2-05112017.tar.gz
cd minimap2
make -j $NCORES
mv minimap2 $REFS/bin

## Build MiXCR
cd $REFS/tmp
cp $REFS/tools/mixcr-2.1.6-SNAPSHOT.zip .
unzip mixcr-2.1.6-SNAPSHOT.zip
mv mixcr-2.1.6-SNAPSHOT/mixcr mixcr-2.1.6-SNAPSHOT/mixcr.jar $REFS/bin

## Build Sambamba
cd $REFS/tmp/
cp $REFS/tools/sambamba_v0.6.6_linux.tar.bz2 .
tar xf sambamba_v0.6.6_linux.tar.bz2
mv sambamba_v0.6.6 $REFS/bin/sambamba

## Build Samtools
cd $REFS/tmp
cp $REFS/tools/samtools-1.4.1.tar.bz2 .
tar xf samtools-1.4.1.tar.bz2
cd samtools-1.4.1
./configure
make -j $NCORES
cd $REFS/tmp
mv samtools-1.4.1/samtools $REFS/bin
cp $REFS/tools/seq_cache_populate.pl $REFS/bin

## Build seqtk
cd $REFS/tmp/
cp $REFS/tools/seqtk-181117.tar.gz .
tar xf seqtk-181117.tar.gz
cd seqtk
make
mv seqtk $REFS/bin

## build STAR
cd $REFS/tmp
cp $REFS/tools/STAR_2.4.0g1.tgz .
tar xf STAR_2.4.0g1.tgz
cd STAR-STAR_2.4.0g1/source
make -j $NCORES STAR
mv STAR $REFS/bin

## Build subread
cd $REFS/tmp/
cp $REFS/tools/subread-1.6.0-source.tar.gz .
tar xf subread-1.6.0-source.tar.gz
cd subread-1.6.0-source/src
make -j $NCORES -f Makefile.Linux 
mv ../bin/featureCounts $REFS/bin

## Build bedGraphToBigWig
cp $REFS/tools/bedGraphToBigWig $REFS/bin

## clean
rm -rf $REFS/tmp
