#!/usr/bin/env bash
HERE="$(readlink -f $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ))" && cd $HERE

## SETTINGS
export NCORES=$NCORES
export MEMORY=$MEMORY
export SETTINGS=""
export LIBSHEET=lib_sheet.tsv

## DO NOT CHANGE
export DOCKER_IMAGE="gx${USER}:$GXCORE_VER"
export USRID=$(id -u)
export JOB=$(basename $HERE)
export JOBDIR=$HERE
export JOBLOG=$JOBDIR/out/job.log
export ERRLOG=$JOBDIR/out/err.log
mkdir -p $JOBDIR/out


#!/usr/bin/env bash
cd ${JOBDIR}

echo -e "start:\t"$(date) > $JOBLOG
echo -e "job:\t"$JOB >> $JOBLOG
echo -e "hostname:\t"$HOSTNAME >> $JOBLOG
echo -e "hostname:\t"$HOSTNAME >> $JOBLOG
echo -e "ncores:\t"$NCORES >> $JOBLOG
echo -e "memory:\t"$MEMORY >> $JOBLOG
echo -e "docker_image:\t"$DOCKER_IMAGE >> $JOBLOG

CONTID=$(docker run -d --privileged \
     -e NCORES="${NCORES}" -e MEMORY="${MEMORY}" \
     -e SETTINGS="${SETTINGS}" -e LIBSHEET="${LIBSHEET}" \
     -v $JOBDIR:/job \
     -v $REFDIR:/refs \
     -v $REPDIR:/repo \
     -v $JOBDIR:/tmp \
     --user "${USRID}" \
     "${DOCKER_IMAGE}" /job/run.sh 2>> $ERRLOG)

echo -e "container_id:\t"$CONTID >> $JOBLOG
if [ -n "$CONTID" ]; then
    docker attach $CONTID &>> $ERRLOG
    REMOVED=$(docker rm -f $CONTID)
fi

##
echo -e "docker removed:\t"$REMOVED >> $JOBLOG
echo -e "docker end:\t"$(date) >> $JOBLOG
echo -e "end:\t"$(date) >> $JOBLOG
