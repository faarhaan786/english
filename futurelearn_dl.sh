#!/bin/bash
 
#
# Usage:
#    > futurelearn_dl.sh login@email.com password course-name week-id
# Where *login@email.com* and *password* - your credentials
# ,*course-name* is the name from URL
# and *week-id* is the ID from the URL
#
# E.g. To download all videos from the page: https://www.futurelearn.com/courses/corpus-linguistics/todo/238
# Execute following command:
#    > futurelearn_dl.sh login@email.com password corpus-linguistics 238
#
 
email=$1
password=$2
course=$3
weekid=$4
HD=/hd
 
# Pulls the login page and strips out the auth token
authToken=`curl -s -L -c cookies.txt 'https://www.futurelearn.com/sign-in' | \
           grep -Po "(?<=authenticity_token\" value=\")([^\"]+)"`
 
 
function dlvid {
    vzid=`curl -s -b cookies.txt $1 | grep -Po '(?<=video-)[0-9]+'`
    vzurl=https://view.vzaar.com/${vzid}/download${HD}
    curl -O -J -L $vzurl
 
}
 
# Posts all the pre-URI-encoded stuff and appends the URI-encoded auth token
curl -X POST -s -L -e 'https://www.futurelearn.com/sign-in' -c cookies.txt -b cookies.txt \
    --data-urlencode email=$email \
    --data-urlencode password=$password \
    --data-urlencode authenticity_token=$authToken 'https://www.futurelearn.com/sign-in' > /dev/null
 
# Download Course page
curl -s -L -b cookies.txt https://www.futurelearn.com/courses/${course}/todo/${weekid} | \
    grep -B8 'headline.*video' | grep -o '/courses[^"]*' | \
    while read -r line; do
        url=https://www.futurelearn.com${line}/progress
        dlvid $url
    done