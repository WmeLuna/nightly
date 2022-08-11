#!/bin/bash
API_JSON=$(curl -sL "https://api.github.com/repos/$REPO/commits/$COMMIT")
REPO_API=$(curl -sL "https://api.github.com/repos/$REPO")

echo "$REPO_API" | jq -r '.name, .organization.avatar_url, .stargazers_count' > /tmp/hookdata
echo "$API_JSON" | jq -r '.commit.committer.name, .committer.html_url, .committer.avatar_url, .commit.message' >> /tmp/hookdata
echo "$API_JSON" | jq -r '.files | length' >> /tmp/hookdata
echo "$API_JSON" | jq -r '.files | map(.filename) | join(", ")' >> /tmp/hookdata

cat /tmp/hookdata
RepoName=$(tail -n+1 /tmp/hookdata | head -n1)
RepoPfp=$(tail -n+2 /tmp/hookdata | head -n1)
RepoStars=$(tail -n+3 /tmp/hookdata | head -n1)
CommitName=$(tail -n+4 /tmp/hookdata | head -n1)
CommitUrl=$(tail -n+5 /tmp/hookdata | head -n1)
CommitPfp=$(tail -n+6 /tmp/hookdata | head -n1)
CommitMsg=$(tail -n+7 /tmp/hookdata | head -n1)
FileCount=$(tail -n+8 /tmp/hookdata | head -n1)
Files=$(tail -n+9 /tmp/hookdata | head -n1 | sed 's/, /\\n/g')

# Commit user
# Commit user GH Link
# Commit user PFP

# Commit message


# Discord pfp and user is the Project 
# Embed author name and pfp is committer's (hyperlinked)
# Embed Footer is repo stats
WEBHOOK_DATA="{
    \"username\": \"$RepoName\",
    \"avatar_url\": \"$RepoPfp\",
    \"embeds\": [ {
        \"author\": {
            \"name\": \"$CommitName\",
            \"url\": \"$CommitUrl\",
            \"icon_url\": \"$CommitPfp\"
        },
        \"title\": \"Updated File\",
        \"description\": \"$CommitMsg\",
        \"fields\": [ {
            \"name\": \"$FileCount changed files\",
            \"value\": \"$Files\"
        } ],
        \"footer\": {\"text\":\"⭐ $RepoStars\"}
    } ] 
    }"

echo $WEBHOOK_DATA | jq 

curl -H "Content-Type: application/json" \
 -d "$WEBHOOK_DATA" \
 $WEBHOOK_URL
