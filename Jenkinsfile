def project = 'ci-cd-for-bn'
def appName = 'greenlight'
def greenlightVersion = 'v2'
def label = "jenkins-execution-worker-${UUID.randomUUID().toString()}"

if (env.TAG_NAME && env.TAG_NAME.contains("release")) {
  kubeCloud = "production"
  kubecSecretsId = 'gl-launcher-prod-secrets'
} else {
  kubeCloud = "staging"
  kubecSecretsId = 'gl-launcher-staging-secrets'
}

podTemplate(label: label, cloud: "${kubeCloud}", containers: [
  containerTemplate(name: 'gcloud', image: "gcr.io/ci-cd-for-bn/gcloud-docker", command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'kubectl', image: 'gcr.io/cloud-builders/kubectl', command: 'cat', ttyEnabled: true)
],
volumes: [
  hostPathVolume(mountPath: '/usr/bin/docker', hostPath: '/usr/bin/docker'),
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]){
  node(label) {
    def myRepo = checkout scm
    def gitCommit = myRepo.GIT_COMMIT
    def gitBranch = myRepo.GIT_BRANCH
    def gitTag = env.TAG_NAME
    def shortGitCommit = "${gitCommit[0..10]}"
    def previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)
    def imageTag = "gcr.io/${project}/${appName}:${gitBranch}.${env.BUILD_NUMBER}.${gitCommit}"
   
    stage('Build and Publish') {
      container('gcloud') {
        withCredentials([file(credentialsId: 'cloud-datastore-user-account-creds', variable: 'FILE')]) {
          sh "gcloud auth activate-service-account --key-file=$FILE"
          if (kubeCloud == "staging") {
            sh "gcloud docker -- build -t ${imageTag} . && gcloud docker -- push ${imageTag}"
          } else {
           imageTag = "gcr.io/${project}/${appName}:${gitTag}"
           withCredentials([string(credentialsId: 'DOCKER_USER', variable: 'DOCKER_USER'), string(credentialsId: 'DOCKER_PASSWORD', variable: 'DOCKER_PASSWORD')]) {
             sh "gcloud docker -- build -t ${imageTag} -t '$DOCKER_USER/${appName}:${greenlightVersion}' -t '$DOCKER_USER/${appName}:${gitTag}' . && gcloud docker -- push ${imageTag}"
             sh "docker login -u $DOCKER_USER -p $DOCKER_PASSWORD"
             sh "docker push '$DOCKER_USER/${appName}:${greenlightVersion}' && docker push '$DOCKER_USER/${appName}:${gitTag}'"
           }
          }
        }
      }
    }

    stage('Deploy') {
      container('kubectl') {
         withCredentials([file(credentialsId: kubecSecretsId, variable: 'FILE')]) {
            sh '''
              kubectl get pods && kubectl apply -f $FILE
            '''
         }
        sh "kubectl set image deployments/gl-deployment gl=${imageTag}"
      }
    }
  }
}
