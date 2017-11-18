#!/usr/bin/env bash
cd /job

echo -e "start:\t"$(date) >> /job/out/run.log
cat ${LIBSHEET} | while read LINE
do
    SID=$(echo $LINE | cut -d " " -f 1)
    CFG=$(echo $LINE | cut -d " " -f 2)
    RUN=/repo/$SID
    mkdir -p out/$SID
    Rscript -e 'library(methods);codac::detect()' ${SETTINGS} $CFG $RUN out/$SID
    Rscript -e 'library(methods);codac::report()' $CFG out/$SID/$SID-codac-spl.rds out/$SID/$SID-codac-cts.rds out/$SID/$SID-codac-sv.rds out/$SID
    Rscript -e 'library(methods);codac::report()' $CFG out/$SID/$SID-codac-spl.rds out/$SID/$SID-codac-cts.rds out/$SID/$SID-codac-ts.rds out/$SID
    Rscript -e 'library(methods);codac::report()' $CFG out/$SID/$SID-codac-spl.rds out/$SID/$SID-codac-cts.rds out/$SID/$SID-codac-bs.rds out/$SID
    Rscript -e 'library(methods);codac::report()' $CFG out/$SID/$SID-codac-spl.rds out/$SID/$SID-codac-cts.rds out/$SID/$SID-codac-sl.rds out/$SID
    Rscript -e 'library(methods);codac::qc.report()' $CFG out/$SID/$SID-codac-stat.rds out/$SID
done
echo -e "end:\t"$(date) >> /job/out/run.log
