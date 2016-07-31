#!/bin/bash

CONTRIB_REPO=https://github.com/StackStorm/st2contrib
EXCHANGE_ORG=StackStorm-Exchange

echo "Starting pack transfer from st2contrib to StackStorm Exchange"
echo "============================================================="
echo

read -p "GitHub username: " USERNAME
read -sp "Password/token: " PASSWORD

echo
echo

rm -rf /tmp/st2contrib
rm -rf /tmp/stackstorm-exchange

mkdir /tmp/stackstorm-exchange

git clone $CONTRIB_REPO /tmp/st2contrib
cd /tmp/st2contrib/packs

echo

for PACK in `ls`; do
  echo -n "Moving $PACK... "
  git ls-remote https://$USERNAME:$PASSWORD@github.com/$EXCHANGE_ORG/$PACK > /dev/null 2>&1
  if [ "$?" == 0 ]; then
  	echo "already there."
  	echo
  	continue
  fi

  echo
  mkdir /tmp/stackstorm-exchange/$PACK
  cd /tmp/stackstorm-exchange/$PACK
  cp -R /tmp/st2contrib/. .

  git filter-branch --prune-empty --subdirectory-filter packs/$PACK master
  git remote set-url origin https://$USERNAME:$PASSWORD@github.com/$EXCHANGE_ORG/$PACK.git

  chmod -R 775 .
  git add -A
  git commit -am 'Transfer from st2contrib' > /dev/null
  git push -u origin master

  echo "The $PACK pack has been transferred."
  echo
done
echo

rm -rf /tmp/st2contrib
rm -rf /tmp/stackstorm-exchange
echo "All done."