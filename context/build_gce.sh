## update google
if [ "$BUILD_GOOGLE" = true ]; then
    export GXUSER_VER=$GXCORE_VER
    export GXUSER_TAG=$(echo $GXUSER_VER | sed 's/\.//g')
    export GXUSER_URL="https://storage.googleapis.com/crisp-mctp/release/gx${USER}_docker_${GXUSER_VER}.tar.gz"
    gsutil -m cp $(pwd)/rnascape_$BUILD_TAG.tar.gz gs://crisp-mctp/release/rnascape_$BUILD_TAG.tar.gz
    gsutil cp $(pwd)/gx${USER}_docker_$GXCORE_VER.tar.gz gs://crisp-mctp/release/gx${USER}_docker_$GXCORE_VER.tar.gz
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

