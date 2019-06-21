def project = 'ci-cd-for-bn'
def appName = 'greenlight'
def greenlightVersion = 'v2'
def label = "jenkins-execution-worker-${UUID.randomUUID().toString()}"
def releaseBuild = env.TAG_NAME && env.TAG_NAME.contains("release")

String convert(long millsToConvert){
   long seconds, minutes, hours;
   seconds = millsToConvert / 1000;
   minutes = seconds / 60;
   seconds = seconds % 60;
   hours = minutes / 60;
   minutes = minutes % 60;
   return String.format("%02d:%02d:%02d", hours, minutes, seconds);
}


if (releaseBuild) {
  kubeCloud = "production"
  kubecSecretsId = 'greenlight-prod-secrets'
} else {
  kubeCloud = "staging"
  kubecSecretsId = 'greenlight-staging-secrets'
}

properties([
  pipelineTriggers([
    githubPush()
  ])
])

podTemplate(label: label, cloud: "${kubeCloud}", containers: [
  containerTemplate(name: 'ruby', image: "ruby:2.5.1", command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'gcloud', image: "gcr.io/ci-cd-for-bn/gcloud-docker", command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'kubectl', image: 'gcr.io/cloud-builders/kubectl', command: 'cat', ttyEnabled: true)
],
volumes: [
  hostPathVolume(mountPath: '/usr/bin/docker', hostPath: '/usr/bin/docker'),
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]){
  node(label) {
    try {
      slackSend (color: '#FFFF00', message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
      def myRepo = checkout scm
      def gitCommit = myRepo.GIT_COMMIT
      def gitBranch = myRepo.GIT_BRANCH
      def gitTag = env.TAG_NAME
      def shortGitCommit = "${gitCommit[0..10]}"
      def previousGitCommit = myRepo.GIT_PREVIOUS_COMMIT
      def imageTag = "gcr.io/${project}/${appName}:${gitBranch}.${env.BUILD_NUMBER}.${gitCommit}"
      def stageBuild = (kubeCloud == "staging" && gitBranch == "master")

      stage('Test') {
        container('ruby') {
          sh "bundle install && bundle exec rubocop && bundle exec rspec "
        }
      }

      stage('Build and Publish') {
        container('gcloud') {
          withCredentials([file(credentialsId: 'cloud-datastore-user-account-creds', variable: 'FILE'), string(credentialsId: 'DOCKER_USER', variable: 'DOCKER_USER'), string(credentialsId: 'DOCKER_PASSWORD', variable: 'DOCKER_PASSWORD')]) {
            sh "gcloud auth activate-service-account --key-file=$FILE"
            if (stageBuild) {
              sh "sed -i 's/VERSION =.*/VERSION = \"${gitBranch} (${gitCommit.substring(0, 7)})\"/g' config/initializers/version.rb"
              sh "gcloud docker -- build -t ${imageTag} -t 'bigbluebutton/${appName}:master' . && gcloud docker -- push ${imageTag}"
            } else if (releaseBuild) {
              sh "sed -i 's/VERSION =.*/VERSION = \"${gitTag.substring(8)}\"/g' config/initializers/version.rb"
              imageTag = "gcr.io/${project}/${appName}:${gitTag}"
              sh "gcloud docker -- build -t ${imageTag} -t 'bigbluebutton/${appName}:${greenlightVersion}' -t 'bigbluebutton/${appName}:${gitTag}' . && gcloud docker -- push ${imageTag}"
            }
          }
        }
      }

      stage('Deploy') {
        container('kubectl') {
           if (stageBuild || releaseBuild) {
              withCredentials([file(credentialsId: kubecSecretsId, variable: 'FILE')]) {
                 sh '''
                   kubectl apply -f $FILE
                 '''
              }
              sh "kubectl set image deployments/gl-deployment gl=${imageTag}"
           }
        }
      }
      slackSend (color: '#00FF00', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' in ${convert(currentBuild.duration)} (${env.BUILD_URL})")
    } catch(e) {
       slackSend (color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' message: ${e} (${env.BUILD_URL})")
    }
  }
}
