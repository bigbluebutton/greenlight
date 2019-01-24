node('docker') {
    checkout scm
    stage('Build') {
        docker.image('ruby').inside {
            sh 'ruby --version'
        }
    }
}
