FROM gxcore:temp

# USERS
ARG user
ARG userid
RUN mkdir /wdir
RUN useradd --no-log-init -d /wdir -u $userid -g users -G sudo $user

ENV PATH=/refs/bin:$PATH
ENV R_LIBS_USER=/refs/libs/r
ENV REF_PATH="/refs/cache/hts-ref/%2s/%2s/%s" REF_CACHE="/refs/cache/hts-ref/%2s/%2s/%s"
