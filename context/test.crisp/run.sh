#!/usr/bin/env bash
# workaround (silent if fails)
sudo su -c 'echo "kernel.shmmax = 31000000000" >> /etc/sysctl.conf; echo "kernel.shmall = 31000000000" >> /etc/sysctl.conf; /sbin/sysctl -p' > /dev/null 2>&1
export PATH=/code/bin:$PATH

cd /job
/usr/bin/time -v /code/pipeline.py \
    -inp /repo \
    -out out/ \
    -ls  out/pipe.log \
    -ncores $NCORES -memory $MEMORY \
    ${SETTINGS} \
    ${LIBSHEET} &> out/run.log
