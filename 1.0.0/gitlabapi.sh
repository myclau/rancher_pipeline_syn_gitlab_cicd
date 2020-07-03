#!/usr/bin/env bash
status="pending"
token=${GITLAB_TOKEN-"9koXpg98eAheJpvBs5tK"}
pipelineurl=${GITLAB_PIPELINE_URL-"https://gitlab.example.com/api/v4/projects/1/pipelines"}
branch=${BRANCH-"new-pipeline"}
sleeptime=${SLEEPTIME-"5"}
echo "---------------------------------------------------"
echo "pipelineurl: $pipelineurl"
echo "branch: $branch"
echo "sleeptime: $sleeptime"
echo "Wait util it finish"
echo ""
retrycount=1
while [ "$status" == "pending" ] || [ "$status" == "running" ];
do
status=$(curl -s --header "PRIVATE-TOKEN: $token" "$pipelineurl" | jq -r --arg ref "$branch" 'map(select(.ref==$ref))| .[0].status')
if [ "$status" == "canceled" ] || [ "$status" == "failed" ] || [ "$status" == "$null" ]; then
    echo -ne "[$retrycount] Current status: $status "
    exit 1
else
    echo -ne "[$retrycount] Current status: $status \r"
    if [ "$status" == "success" ]; then
        echo -ne "[$retrycount] Current status: $status"
        echo ""
        echo "Deployment was completed successfully"
        sleeptime=0
    fi
fi
((retrycount++))
sleep $sleeptime
done
echo ""
echo "---------------------------------------------------"
exit 0
