#!/bin/bash

set -e

CONTRIB_REPO=https://github.com/StackStorm/st2contrib
EXCHANGE_ORG=StackStorm-Exchange
EXCHANGE_PREFIX=stackstorm

echo "Starting pack transfer from st2contrib to StackStorm Exchange"
echo "============================================================="
echo

#read -p "GitHub username: " USERNAME
#read -sp "Password/token: " PASSWORD
#read -sp "CircleCI token: " CIRCLECI_TOKEN
#echo
#echo

USERNAME=$USERNAME
PASSWORD=$PASSWORD
CIRCLECI_TOKEN=$CIRCLECI_TOKEN

rm -rf /tmp/st2contrib
rm -rf /tmp/stackstorm-exchange

mkdir /tmp/stackstorm-exchange
curl -sS --fail "https://raw.githubusercontent.com/StackStorm-Exchange/ci/master/utils/exchange-bootstrap.sh" > /tmp/stackstorm-exchange/bootstrap.sh
chmod +x /tmp/stackstorm-exchange/bootstrap.sh

git clone $CONTRIB_REPO /tmp/st2contrib
cd /tmp/st2contrib/packs

echo

for PACK in `ls`; do
  echo -n "Moving $PACK... "
  if git ls-remote https://$USERNAME:$PASSWORD@github.com/$EXCHANGE_ORG/$EXCHANGE_PREFIX-$PACK > /dev/null 2>&1
  then
  	echo "already there."
  	echo
  	continue
  fi

  echo

  USERNAME=$USERNAME PASSWORD=$PASSWORD CIRCLECI_TOKEN=$CIRCLECI_TOKEN /tmp/stackstorm-exchange/bootstrap.sh $PACK >/dev/null
  echo "Bootstrapped an empty repo for $PACK."

  mkdir /tmp/stackstorm-exchange/$PACK
  cd /tmp/stackstorm-exchange/$PACK
  cp -R /tmp/st2contrib/. .

  git filter-branch --prune-empty --subdirectory-filter packs/$PACK -f -- master
  git remote set-url origin https://$USERNAME:$PASSWORD@github.com/$EXCHANGE_ORG/$EXCHANGE_PREFIX-$PACK.git
  git fetch --all -q

  chmod -R 775 .
  git commit -q -am 'Transfer from st2contrib.' > /dev/null
  git merge -q origin/master -Xtheirs --allow-unrelated-histories --no-edit

  git reset --soft HEAD~3 &&
  git commit -q -m 'Transfer from st2contrib.'

  git push -u origin master --force > /dev/null

  echo "The $PACK pack has been transferred."
  echo
done
echo

rm -rf /tmp/st2contrib
rm -rf /tmp/stackstorm-exchange
echo "All done."
