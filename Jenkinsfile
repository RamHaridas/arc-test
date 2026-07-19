

pipeline {
    agent any

    stages {
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
