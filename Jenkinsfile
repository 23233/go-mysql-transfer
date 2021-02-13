// 获取git仓库的名称 groovy语法
def String determineRepoName() {
        return scm.getUserRemoteConfigs()[0].getUrl().tokenize('/').last().split("\\.")[0]
    }

pipeline {
    agent any
    parameters {
        string(name: 'prefix',defaultValue: '',description: '构建的镜像前缀',trim: true)
        string(name: 'dockerRegistryAttr',defaultValue: '', description: 'docker仓库地址',trim: true)
        string(name: 'registryCredential',defaultValue: '', description: 'docker连接的jenkins密钥ID',trim: true)
        string(name: 'tagName',defaultValue: ':latest', description: '标签名(:号开头)',trim: true)
    }
    environment {
        // 仓库名称
        repName = determineRepoName()
        dockerImage = ''
    }
    stages{
       stage("Building") {
            steps{
                script {
                    echo "构建的镜像名称:${params.prefix}${repName}${params.tagName}"
                    dockerImage = docker.build "${params.prefix}${repName}${params.tagName}"
                }
            }
        }
        stage("Uploading") {
            steps {
                script {
                    docker.withRegistry("${params.dockerRegistryAttr}/v2/",  "${params.registryCredential}") {
                            dockerImage.push()
                      }
                }
            }
        }
    }
    post {
        always {
            echo "running"
        }
        failure {
            echo "task fail"
        }
    }

}

