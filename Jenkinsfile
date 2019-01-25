def label = "jenkins-execution-worker-${UUID.randomUUID().toString()}"

node('master') {
  stage('Test') {
    container('ruby') {
      sh 'ruby --version'
      sh 'bundle install && bundle exec rubocop && bundle exec rspec'
    }
  }
}
