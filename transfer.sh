#!/bin/bash

CONTRIB_REPO=https://github.com/StackStorm/st2contrib
EXCHANGE_ORG=https://github.com/StackStorm-Exchange

echo "Starting pack transfer from st2contrib to StackStorm Exchange."
echo "=============================================================="
echo

read -p "GitHub username: " USERNAME
read -sp "Password/token: " PASSWORD

echo -n "Cloning st2contrib... "
# mkdir /tmp/st2contrib
# git clone $CONTRIB_REPO /tmp/st2contrib
# rm -rf /tmp/st2contrib/.git
# # Not ideal. Can we preserve history somehow?
echo "done."
echo

for PACK in `ls`; do
  echo -n "Moving $pack... "
  cd /tmp/st2contrib/$PACK
  chmod -R 775 .
  if []; # check if the pack exists
  	echo "already there."
  	continue
  fi
  # create a new repo
  git clone $EXCHANGE_ORG/$PACK .
  git add -A
  git commit -am 'Transfer from st2contrib'
  git push
  echo "done."
done
echo

# rm -rf /tmp/st2contrib
echo "All done."