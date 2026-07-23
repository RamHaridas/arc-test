USERNAME="your email"
GITHUB_PAT="pattoken"
AUTH_BASE64=$(echo -n "${USERNAME}:${GITHUB_PAT}" | base64)
echo "@bsd:registry=https://artifactory.fis.dev/artifactory/api/npm/bsd-npm-dev/" >> .npmrc
echo "//artifactory.fis.dev/artifactory/api/npm/bsd-npm-dev/:_auth=${AUTH_BASE64}" >> .npmrc
