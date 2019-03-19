node() {

    stage('setup') {
        deleteDir()
    }

    stage('scm') {
        checkout([$class: 'GitSCM',
        branches: [[name: '*/master']],
        doGenerateSubmoduleConfigurations: false,
        extensions: [[$class: 'CleanBeforeCheckout']],
        submoduleCfg: [],
        userRemoteConfigs: [[credentialsId: 'dev_deploy_ssh', url: 'git@git.eogresources.com:ldavis2/chat_test.git']]])
    }

    stage('build') {
        sh './util.sh -b'
    }

    stage('push') {
        sh './util.sh -p'
    }

    stage('deploy') {
        sshagent(credentials: ['dev_deploy_ssh']) {
            sh './util.sh -d'
        }
    }
}
