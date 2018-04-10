#!/bin/bash

TOKEN=$1
PAGE=1
URL="https://slack.com/api/files.list?token=$TOKEN&page=$PAGE"

TOTAL_PAGES=`curl -s $URL | jq -r '.paging.pages'`

echo $TOTAL_PAGES
echo "id, title, size, created, is_public, user" > files.csv

for i in $(seq 1 $TOTAL_PAGES)
do
  echo Getting page $i
  URL="https://slack.com/api/files.list?token=$TOKEN&page=$i"
  CONTENT=`curl -s $URL`
  echo `echo $CONTENT | jq ".files | length"` files in this page
  curl -s $URL | jq -r ".files[] | [.id, .title, .size, .created, .is_public, .user] | @csv" >> files.csv
done

echo "id, name, real_name" > users.csv
curl -s "https://slack.com/api/users.list?token=$TOKEN" | jq  -r ".members[] | [.id, .name, .real_name] | @csv" >> users.csv
