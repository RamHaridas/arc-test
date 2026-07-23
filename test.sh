USERNAME="your email"
GITHUB_PAT="pattoken"

echo '@bsd:registry=https://artifactory.fis.dev/artifactory/api/npm/bsd-npm-dev/' >> .npmrc
echo '//artifactory.fis.dev/artifactory/api/npm/bsd-npm-dev/:_auth=${AUTH_BASE64}' >> .npmrc
