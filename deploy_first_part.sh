#! /bin/bash

PORT=22003
MACHINE=paffenroth-23.dyn.wpi.edu
STUDENT_ADMIN_KEY_PATH=$HOME/CS553/CS553-CaseStudy-01

# Clean up from previous runs
ssh-keygen -f "/home/nacote1/.ssh/known_hosts" -R "[paffenroth-23.dyn.wpi.edu]:22003"
rm -rf tmp

# Create a temporary directory
mkdir tmp

# copy the key to the temporary directory
cp ${STUDENT_ADMIN_KEY_PATH}/student-admin_key tmp

# Change the premissions of the directory
chmod 700 tmp

# Change to the temporary directory
cd tmp

# Set the permissions of the key
chmod 600 student-admin_key

# Create a unique key
rm -f mykey
ssh-keygen -f mykey -t ed25519 -N "careful"

# Insert the key into the authorized_keys file on the server
# One > creates
cat mykey.pub >authorized_keys
# two >> appends
# Remove to lock down machine
#cat student-admin_key.pub >> authorized_keys

chmod 600 authorized_keys

echo "checking that the authorized_keys file is correct"
ls -l authorized_keys
cat authorized_keys

# Copy the authorized_keys file to the server
scp -i student-admin_key -P ${PORT} -o StrictHostKeyChecking=no authorized_keys student-admin@${MACHINE}:~/.ssh/

# Add the key to the ssh-agent
# Reworked with the help from the built-in Google search AI. Initial search included "What does eval "$(ssh-agent -s)" ssh-add mykey do and why do I need it", followed by "I am trying to use this for automation but it prompts me to enter my passphrase when I try to use it, which I need automated", "My ssh config file is as you instructed, by when I ran my script to keygen a new key with a specified passphrase on the new server, it still prompted me to type it in myself", "I already have -N for the keygen line, but I am still receiving a prompt for me to type what I specified it as, likely from the keyadd line", and finally "It still made me enter the passphrase and I received this error:{error pasted showing permission denied by tmp folder}".
PASSPHRASE="careful"
KEY_PATH="$HOME/CS553/CS553-CaseStudy-01/tmp/mykey"

eval "$(ssh-agent -s)"

export DISPLAY=:0
export SSH_ASKPASS_REQUIRE=force
export SSH_ASKPASS=$(mktemp --tmpdir=$HOME)

echo -e "#!/bin/bash\necho '$PASSPHRASE'" > "$SSH_ASKPASS"
chmod 700 "$SSH_ASKPASS"

ssh-add "$KEY_PATH" < /dev/null

rm -f "$SSH_ASKPASS"
unset SSH_ASKPASS SSH_ASKPASS_REQUIRE

# Check the key file on the server
echo "checking that the authorized_keys file is correct"
ssh -p ${PORT} -o StrictHostKeyChecking=no student-admin@${MACHINE} "cat ~/.ssh/authorized_keys"

# clone the Case_Study_2 branch on the repo
git clone --branch Case_Study_2 --single-branch https://github.com/VivekChoudhary77/CS553-CaseStudy-01/ Case-Study-2
# Copy the files to the server
scp -P ${PORT} -o StrictHostKeyChecking=no -r Case-Study-2 student-admin@${MACHINE}:~/


# check that the code in installed and start up the product
COMMAND="ssh -p ${PORT} -o StrictHostKeyChecking=no student-admin@${MACHINE}"

#chatgpt TODO
${COMMAND} "cd ~/Case-Study-2 && chmod +x setup.sh && ./setup.sh"

# ${COMMAND} "ls CS553_example"
# ${COMMAND} "sudo apt install -qq -y python3-venv"
# ${COMMAND} "cd CS553_example && python3 -m venv venv"
# ${COMMAND} "cd CS553_example && source venv/bin/activate && pip install -r requirements.txt"
# ${COMMAND} "nohup CS553_example/venv/bin/python3 CS553_example/app.py > log.txt 2>&1 &"

# nohup ./whatever > /dev/null 2>&1

# debugging ideas
# sudo apt-get install gh
# gh auth login
# requests.exceptions.HTTPError: 429 Client Error: Too Many Requests for url: https://api-inference.huggingface.co/models/HuggingFaceH4/zephyr-7b-beta/v1/chat/completions
# log.txt
