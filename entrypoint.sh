#!/bin/bash

# Check if needed env vars are available
if [[ -z $OVH_HOSTING_USER || -z $OVH_HOSTING_PASSWORD || -z $OVH_HOSTING_URL || -z $OVH_HOSTING_DOMAIN || -z $DOCUMENT_ROOT || -z $REPOSITORY_NAME || -z $REPOSITORY_URL ]]; then
  echo 'One or more needed env vars are undefined! Take a look at the example usage declaration.'
  exit 1
fi

curl -L --insecure $OVH_HOSTING_URL

sshpass -p "$OVH_HOSTING_PASSWORD" ssh -o StrictHostKeyChecking=no $OVH_HOSTING_USER@$OVH_HOSTING_DOMAIN "rm -rvf $DOCUMENT_ROOT && mkdir $DOCUMENT_ROOT && git clone $REPOSITORY_URL $DOCUMENT_ROOT && bash $DOCUMENT_ROOT/my_script.sh"

echo 'Done.'


# #########################


