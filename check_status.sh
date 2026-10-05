#!/bin/bash

# Script adapted from the given red_team_v1.sh script.

source $HOME/CS553/CS553-CaseStudy-01/.env.local
PORT=22003
MACHINE=paffenroth-23.dyn.wpi.edu
KEY=$HOME/CS553/CS553-CaseStudy-01/tmp/student-admin_key
chmod 600 ${KEY}

if ssh -i $KEY -o IdentitiesOnly=yes -o IdentityAgent=none -p $((${i} + ${PORT})) -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5 student-admin@${MACHINE} hostname; then  # This line was suggested by Claude Opus 4.8 on Medium thinking when asked to help debug why our cron job would always brick the machine on the run immediately after a successful patch and deploy
    echo "Our machine is vulnerable!"
    curl -H "Content-Type: application/json" -X POST -d '{"content":"Our machine is vulnerable! Now locking down machine and running red team script."}' ${WEBHOOK_URL}
    chmod 700 $HOME/CS553/CS553-CaseStudy-01/deploy_first_part.sh
    chmod 700 $HOME/CS553/CS553-CaseStudy-01/red_team_v1.sh
    bash $HOME/CS553/CS553-CaseStudy-01/deploy_first_part.sh
    #bash $HOME/CS553/CS553-CaseStudy-01/red_team_v1.sh
    echo "Patching (hopefully) complete and red team script ran."
else
    echo "Our machine is protected!"
    #curl -H "Content-Type: application/json" -X POST -d '{"content":"Our machine is protected! One last test."}' ${WEBHOOK_URL}
fi