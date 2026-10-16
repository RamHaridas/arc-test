

pipeline {
    agent any

    stages {
        echo "Image Registry path =${env.imageRegistryPath}"
stage('Create BuildConfig') {
    if (isMaster || isFeatureBranch) {
        runInEphemeralPod('oc') {
            container('oc') {
                script {
                    def bcExists = sh(
                        script: "oc get buildconfig ${buildConfigName} -o name 2>/dev/null",
                        returnStatus: true
                    )
                    if (bcExists != 0) {
                        echo "BuildConfig ${buildConfigName} not found. Creating..."
                        sh """
                            oc new-build \
                              --name=${buildConfigName} \
                              --binary \
                              --strategy=docker \
                              --to-docker \
                              --to=${env.imageRegistryPath}
                        """
                    } else {
                        echo "BuildConfig ${buildConfigName} already exists. Skipping creation."
                    }
                }
            }
        }
    }
}

stage ('Build Image') {
    runInEphemeralPod('oc') {
        container ('oc') {
            withCredentials([
                usernameColonPassword(
                    credentialsId: 'artifactory_Dev',
                    variable: 'art_creds'
                )
            ]) {
                echo "Image Registry path = ${env.imageRegistryPath}"

                sh """
                    # Patch BuildConfig source to Binary (Jenkins uploads build context, not git clone)
                    oc patch buildconfig ${buildConfigName} --type=merge \
                    -p '{
                        "spec": {
                            "source": {
                                "type": "Binary",
                                "binary": {},
                                "git": null,
                                "sourceSecret": null
                            }
                        }
                    }'

                    # Patch BuildConfig output to push to the target registry
                    oc patch buildconfig ${buildConfigName} --type=merge \
                    -p '{
                        "spec": {
                            "output": {
                                "to": {
                                    "kind": "DockerImage",
                                    "name": "${env.imageRegistryPath}"
                                },
                                "pushSecret": {
                                    "name": "artifactory-secret"
                                }
                            }
                        }
                    }'

                    # Patch BuildConfig strategy to dockerStrategy with build args
                    oc patch buildconfig ${buildConfigName} --type=merge \
                    -p '{
                        "spec": {
                            "strategy": {
                                "dockerStrategy": {
                                    "buildArgs": [
                                        {"name":"GIT_COMMIT","value":"${env.GIT_COMMIT}"}
                                    ]
                                }
                            }
                        }
                    }'

                    # Start the build, uploading current directory as binary input
                    oc start-build ${buildConfigName} --from-dir=. --follow --wait
                """
            }
        }
    }
}

        stage('Read Version') {
            steps {
                script {
                    // Read the build.gradle file content
                    def gradleContent = readFile('build.gradle')
                    
                    // Match version = '...' or version = "..."
                    def matcher = gradleContent =~ /version\s*=\s*['"]([^'"]+)['"]/
                    def baseversion = ''
                    baseversion = matcher[0][1]
                
                    echo "Successfully read version: ${baseversion}"
                }
            }
        }
        
        stage('Example Stage') {
            steps {
                // Showing how baseversion can be used in subsequent stages
                echo "Base version in next stage (as script variable): ${baseversion}"
                echo "Base version in next stage (as environment variable): ${env.baseversion}"
            }
        }
    }
}
