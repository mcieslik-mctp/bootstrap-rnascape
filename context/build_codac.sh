#!/usr/bin/env bash
HERE="$(readlink -f $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))"
REFS=/refs
export R_LIBS_USER=$REFS/libs/r

CODAC_GTF=$(eval echo $CODAC_GTF)

cd /tmp
R CMD build /codac
R CMD INSTALL codac_$CODAC_VER.tar.gz
mkdir -p $REFS/conf
CFG_BASE=$REFS/conf/$(basename "${CODAC_GTF%.*}")
parallel --colsep ' ' -j $NCORES "Rscript -e 'library(methods);codac::config()'" {} ::: \
         "-p longread.balanced                $CODAC_GTF $CFG_BASE-plbs.rds" \
         "-l capt -p longread.balanced        $CODAC_GTF $CFG_BASE-clbs.rds" \
         "-u -p longread.balanced             $CODAC_GTF $CFG_BASE-plbu.rds" \
         "-u -l capt -p longread.balanced     $CODAC_GTF $CFG_BASE-clbu.rds" \
         "-p shortread.balanced               $CODAC_GTF $CFG_BASE-psbs.rds" \
         "-l capt -p shortread.balanced       $CODAC_GTF $CFG_BASE-csbs.rds" \
         "-u -p shortread.balanced            $CODAC_GTF $CFG_BASE-psbu.rds" \
         "-u -l capt -p shortread.balanced    $CODAC_GTF $CFG_BASE-csbu.rds"
