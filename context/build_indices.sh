#!/usr/bin/env bash
HERE="$(readlink -f $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))"
REFS=/refs

mkdir -p $REFS/{cache,indices}

#### indices

## make cache
mkdir -p $REFS/cache/hts-ref
$REFS/tools/seq_cache_populate.pl -root $REFS/cache/hts-ref $(eval echo $ALIGN_FA)

## build minimap2
mkdir -p $REFS/indices/minimap2
$REFS/bin/minimap2 -G500k -x splice -d $REFS/indices/minimap2/hg38.rna.mmi $(eval echo $ALIGN_FA)

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
$REFS/bin/gmap-install/bin/gmap_build -d hg38.rna $(eval echo $ALIGN_FA)
