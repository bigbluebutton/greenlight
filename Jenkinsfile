def label = "jenkins-execution-worker-${UUID.randomUUID().toString()}"

node(label) {
  stage('Test') {
    container('ruby') {
      sh 'ruby --version'
      sh 'bundle install && bundle exec rubocop && bundle exec rspec'
    }
  }
}
