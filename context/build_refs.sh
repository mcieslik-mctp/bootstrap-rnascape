#!/usr/bin/env bash
HERE="$(readlink -f $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))"
REFS=/refs

mkdir -p $REFS/{bin,cache,indices,tmp,libs}

#### BIN
cd $REFS/tmp
## build STAR
cp $REFS/tools/STAR_2.4.0g1.tgz .
tar xf STAR_2.4.0g1.tgz
cd STAR-STAR_2.4.0g1/source
make STAR
mv STAR $REFS/bin
cd $REFS/tmp

## Build Samtools
cp $REFS/tools/samtools-1.4.1.tar.bz2 .
tar xf samtools-1.4.1.tar.bz2
cd samtools-1.4.1
./configure
make
cd $REFS/tmp
mv samtools-1.4.1/samtools $REFS/bin

## Build Inchworm:
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
make
make install
ln -sfn $REFS/bin/gmap-install/bin/gmap_build $REFS/bin
ln -sfn $REFS/bin/gmap-install/bin/gmap $REFS/bin
cd $REFS/tmp

## Build minimap2
cd $REFS/tmp
cp $REFS/tools/minimap2-05112017.tar.gz .
tar xf minimap2-05112017.tar.gz
cd minimap2
make
mv minimap2 $REFS/bin

## clean
rm -rf $REFS/tmp


#### indices

## build genomes
STAR=$REFS/bin/STAR
mkdir -p $REFS/indices/star/Hsapiens_rRNA
cd $REFS/indices/star/Hsapiens_rRNA
$STAR --runMode genomeGenerate --genomeDir $REFS/indices/star/Hsapiens_rRNA \
      --genomeFastaFiles $REFS/genomes/Hsapiens_rRNA.fa --runThreadN 1 --genomeSAindexNbases 4
mkdir -p $REFS/indices/star/$ALIGN_NAME
cd $REFS/indices/star/$ALIGN_NAME
$STAR --runMode genomeGenerate --genomeDir $REFS/indices/star/$ALIGN_NAME \
      --genomeFastaFiles $(eval echo $ALIGN_FA) --runThreadN $NCORES \
      --sjdbOverhang 125 --sjdbScore 2 --sjdbGTFfile $(eval echo $ALIGN_GTF)

## build gmap
$REFS/bin/gmap_build -d hg38.rna $(eval echo $ALIGN_FA)

## build minimap2
mkdir -p $REFS/indices/minimap2
$REFS/bin/minimap2 -G500k -x splice -d $REFS/indices/minimap2/hg38.rna.mmi $(eval echo $ALIGN_FA)

## make cache
mkdir -p $REFS/cache/hts-ref
$REFS/tools/seq_cache_populate.pl -root $REFS/cache/hts-ref $(eval echo $ALIGN_FA)

## update R
mkdir -p $REFS/libs/r
export R_LIBS_USER=$REFS/libs/r
Rscript -e 'source("http://bioconductor.org/biocLite.R");biocLite(c("optparse", "igraph", "stringr", "data.table", "S4Vectors", "IRanges", "GenomeInfoDb","GenomicRanges", "GenomicFeatures", "GenomicAlignments", "Biostrings", "ShortRead", "rtracklayer","BSgenome", "BSgenome.Hsapiens.UCSC.hg38","circlize"))'
