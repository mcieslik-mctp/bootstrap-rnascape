#!/usr/bin/env bash
mkdir -p $BOOT/$BUILD_NAME
cd $BOOT/$BUILD_NAME

## BUILD GXUSER
if [ "$BUILD_GXUSER" = true ]; then
    wget $GXCORE_URL
    docker load --input gxcore_docker_${GXCORE_VER}.tar.gz
    docker tag gxcore:$GXCORE_VER gxcore:latest
    docker build -t gx${USER}:$GXCORE_VER --build-arg user=$USER --build-arg userid=$USERID $BOOT/context/gxuser
    docker tag gx${USER}:$GXCORE_VER gx${USER}:latest
fi


## BUILD REFS
if [ "$BUILD_REFS" = true ]; then
    # wget $REFS_URL
    # tar xf refs_${REFS_VER}.tar.gz
    docker run --user=$USER \
           -e NCORES=$NCORES \
           -e ALIGN_FA=$ALIGN_FA \
           -e ALIGN_GTF=$ALIGN_GTF \
           -e ALIGN_NAME=$ALIGN_NAME \
           -v $BOOT/$BUILD_NAME/refs:/refs \
           -v $BOOT/context/:/context \
           gx${USER}:latest /context/build_refs.sh
fi

## BUILD CRISP
if [ "$BUILD_CRISP" = true ]; then
    wget $CRISP_URL
    tar xf crisp_${CRISP_VER}.tar.gz
    mv crisp $BOOT/$BUILD_NAME/refs
fi

## build CODAC
if [ "$BUILD_CODAC" = true ]; then
    wget $CODAC_URL
    tar xf codac_${CODAC_VER}.tar.gz
    docker run --user=$USER \
           -e NCORES=$NCORES \
           -e CODAC_GTF=$CODAC_GTF \
           -e CODAC_VER=$CODAC_VER \
           -v $BOOT/$BUILD_NAME/refs:/refs \
           -v $BOOT/context/:/context \
           -v $BOOT/$BUILD_NAME/codac:/codac \
           gx${USER}:latest /context/build_codac.sh
fi

## release
if [ "$BUILD_RELEASE" = true ]; then
    tar -cf - --exclude-vcs --directory $(pwd) refs | pigz -p $NCORES > $(pwd)/bootstrap_$BUILD_TAG.tar.gz
    gsutil -m cp $(pwd)/bootstrap_$BUILD_TAG.tar.gz gs://crisp-mctp/release/bootstrap_$BUILD_TAG.tar.gz
    docker save -o $(pwd)/gx${USER}_docker_$GXCORE_VER.tar gx${USER}:$GXCORE_VER
    pigz -p $NCORES $(pwd)/gx${USER}_docker_$GXCORE_VER.tar
    gsutil cp $(pwd)/gx${USER}_docker_$GXCORE_VER.tar.gz gs://crisp-mctp/release/gx${USER}_docker_$GXCORE_VER.tar.gz
fi

## update google
if [ "$BUILD_GOOGLE" = true ]; then
    export GXUSER_VER=$GXCORE_VER
    export GXUSER_TAG=$(echo $GXUSER_VER | sed 's/\.//g')
    export GXUSER_URL="https://storage.googleapis.com/crisp-mctp/release/gx${USER}_docker_${GXUSER_VER}.tar.gz"
    gcloud compute --project "mctp00001" instances create "gx${USER}-update" --zone "us-central1-f" --machine-type "n1-highcpu-8" \
           --network "default" --maintenance-policy "MIGRATE" \
           --scopes "https://www.googleapis.com/auth/devstorage.read_write,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/compute" \
           --image-family "container-vm" --image-project "google-containers" \
           --boot-disk-type "pd-standard" --boot-disk-device-name "gx${USER}-update" --boot-disk-size "25" \
           --metadata startup-script="
         #!/usr/bin/env bash
         ## update docker
         wget $GXUSER_URL
         docker load --input gx${USER}_docker_${GXUSER_VER}.tar.gz
         docker tag gx${USER}:$GXUSER_VER gx${USER}:latest
         rm gx${USER}_docker_${GXUSER_VER}.tar.gz
         ## paranoid sync
         sync
         sleep 30
         sync
         ## new snapshot
         gcloud compute --project mctp00001 disks snapshot https://www.googleapis.com/compute/v1/projects/mctp00001/zones/us-central1-f/disks/gx${USER}-update --zone us-central1-f --snapshot-names gx${USER}-update-snap
         gcloud compute --project mctp00001 disks create gx${USER}-update-snap --size 25 --zone us-central1-f --source-snapshot gx${USER}-update-snap --type pd-standard
         gcloud compute --project mctp00001 images create gx${USER}-$GXUSER_TAG --source-disk https://www.googleapis.com/compute/v1/projects/mctp00001/zones/us-central1-f/disks/gx${USER}-update-snap
         gcloud compute disks delete -q --project mctp00001 --zone us-central1-f gx${USER}-update-snap
         gcloud compute snapshots delete -q --project mctp00001  gx${USER}-update-snap
         gsutil cp /var/log/startupscript.log gs://logs-mctp-${USER}/gx${USER}_update.log
         gcloud compute instances delete --project mctp00001 --zone us-central1-f -q gx${USER}-update
         "
    export BOOTSTRAP_URL="https://storage.googleapis.com/crisp-mctp/release/bootstrap_$BUILD_TAG.tar.gz"
    gcloud compute disks delete -q --zone us-central1-f bootstrap-$BUILD_TAG
    gcloud compute disks create -q --size 500GB --type pd-ssd --zone us-central1-f bootstrap-$BUILD_TAG
    gcloud compute --project "mctp00001" instances create "boot-update-${BUILD_TAG}" --zone "us-central1-f" --machine-type "n1-highcpu-16" \
           --network "default" --maintenance-policy "MIGRATE" \
           --scopes "https://www.googleapis.com/auth/devstorage.read_write,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/compute" \
           --image-family "container-vm" --image-project "google-containers" \
           --boot-disk-type "pd-standard" --boot-disk-device-name "pull" --boot-disk-size "200" \
           --disk "name=bootstrap-$BUILD_TAG,device-name=refs,mode=rw,boot=no" \
           --metadata startup-script="
       mkdir -p /mnt/refs
       /usr/share/google/safe_format_and_mount -m 'mkfs.ext4 -F' /dev/disk/by-id/google-refs /mnt/refs
       cd /mnt
       wget $BOOTSTRAP_URL
       tar xf bootstrap_$BUILD_TAG.tar.gz
       chmod -R 777 /mnt/refs
       gsutil cp /var/log/startupscript.log gs://logs-mctp-mcieslik/bootstrap_update_${BUILD_TAG}.log
       gcloud compute instances delete --zone us-central1-f -q boot-update
       "
fi
