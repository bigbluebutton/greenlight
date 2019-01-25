
properties([
  pipelineTriggers([
    githubPush()
  ])
])

volumes: [
  hostPathVolume(mountPath: '/usr/bin/docker', hostPath: '/usr/bin/docker'),
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]){
  node('docker') {
    try {
      stage('Test') {
        container('ruby') {
          sh 'ruby --version'
          sh "bundle install && bundle exec rubocop && bundle exec rspec "
        }
      }
    } catch(e) {
    }
  }
}
