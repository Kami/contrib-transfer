#!/bin/bash

CONTRIB_REPO=https://github.com/StackStorm/st2contrib
EXCHANGE_ORG=StackStorm-Exchange

echo "Starting pack transfer from st2contrib to StackStorm Exchange."
echo "=============================================================="
echo

read -p "GitHub username: " USERNAME
read -sp "Password/token: " PASSWORD

mkdir /tmp/stackstorm-exchange

for PACK in `ls`; do
  echo -n "Moving $pack... "
  git ls-remote https://a:a@github.com/$EXCHANGE_ORG/$PACK > /dev/null 2>&1
  if [ "$?" -ne 0 ]; then
  	echo "already there."
  	continue
  fi

  mkdir /tmp/stackstorm-exchange/$PACK
  cd /tmp/stackstorm-exchange/$PACK
  git clone $CONTRIB_REPO .
  git remote set-url origin https://github.com/$EXCHANGE_ORG/$PACK.git

  git filter-branch --prune-empty --subdirectory-filter packs/$PACK master

  chmod -R 775 .
  git add -A
  git commit -am 'Transfer from st2contrib'
  git push -u origin master

  echo "done."
done
echo

rm -rf /tmp/stackstorm-exchange
echo "All done."