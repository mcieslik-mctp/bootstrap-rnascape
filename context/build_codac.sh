#!/usr/bin/env bash
HERE="$(readlink -f $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))"
REFS=/refs
export R_LIBS_USER=$REFS/libs/r

CODAC_GTF=$(eval echo $CODAC_GTF)
CODAC_GMAP=$(eval echo $CODAC_GMAP)
CODAC_MM2=$(eval echo $CODAC_MM2)

cd /tmp
R CMD build /codac
R CMD INSTALL codac_$CODAC_VER.tar.gz
mkdir -p $REFS/conf
CFG_BASE=$REFS/conf/$(basename "${CODAC_GTF%.*}")
parallel --colsep ' ' -j $NCORES "Rscript -e 'library(methods);codac::config()'" {} ::: \
         "-p longread.balanced                $CODAC_GTF $CODAC_GMAP $CODAC_MM2 $CFG_BASE-lbs.rds" \
         "-u -p longread.balanced             $CODAC_GTF $CODAC_GMAP $CODAC_MM2 $CFG_BASE-lbu.rds" \
         "-p shortread.balanced               $CODAC_GTF $CODAC_GMAP $CODAC_MM2 $CFG_BASE-sbs.rds" \
         "-u -p shortread.balanced            $CODAC_GTF $CODAC_GMAP $CODAC_MM2 $CFG_BASE-sbu.rds"
