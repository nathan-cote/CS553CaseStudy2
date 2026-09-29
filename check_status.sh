#!/bin/bash

# Script adapted from the given red_team_v1.sh script.

PORT=22003
MACHINE=paffenroth-23.dyn.wpi.edu
KEY=$HOME/CS553/CS553-CaseStudy-01/tmp/student-admin_key
chmod 600 ${KEY}
WEBHOOK_URL="https://discord.com/api/webhooks/1554256448081502314/muodhTKDVj4Lp8Rv4pSy36bwV0OItbReH9fdiO8303oVbIqBtIO8fBbIicmAH9niZZJ0"

if ssh -i $KEY -p $((${i} + ${PORT})) -o StrictHostKeyChecking=no student-admin@${MACHINE} hostname; then
    echo "Our machine is vulnerable!"
    curl -H "Content-Type: application/json" -X POST -d '{"content":"Our machine is vulnerable! Now locking down machine and running red team script."}' ${WEBHOOK_URL}
    chmod 700 ./deploy_first_part.sh
    chmod 700 ./red_team_v1.sh
    bash ./deploy_first_part.sh
    bash ./red_team_v1.sh
    echo "Patching (hopefully) complete and red team script ran."
else
    echo "Our machine is protected!"
    # curl -H "Content-Type: application/json" -X POST -d '{"content":"Our machine is protected! this is for a test for the chron job, I will delete this shortly so we do not get spammed like crazy"}' ${WEBHOOK_URL}
fi