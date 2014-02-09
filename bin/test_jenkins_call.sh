USER=digital_natives
REPO=jeeves
GIT_COMMIT="123456"
BUILD_STATUS="success"
BUILD_NUMBER="master#23"
JOB_NAME=jeeves-daily

URL="http://localhost:9393/jenkins/post_build\
?user=$USER\
&repo=$REPO\
&sha=$GIT_COMMIT\
&status=$BUILD_STATUS\
&job_name=$JOB_NAME\
&job_number=$BUILD_NUMBER"

echo $URL
curl $URL
