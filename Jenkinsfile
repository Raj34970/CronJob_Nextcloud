
def checkoutRepo() {
    if (env.GIT_CREDS_ID?.trim()) {
        git branch: "${env.GIT_BRANCH}", credentialsId: "${env.GIT_CREDS_ID.trim()}", url: "${env.GIT_REPO_URL}"
    } else {
        git branch: "${env.GIT_BRANCH}", url: "${env.GIT_REPO_URL}"
    }
}

pipeline {

    agent none

    environment {
        GIT_REPO_URL = 'https://github.com/Raj34970/CronJob_Nextcloud.git'
        GIT_BRANCH   = 'main'
        // Leave empty '' for a public repo, or set to a valid Jenkins credential ID (e.g. 'backup-job-token') for a private repo
        GIT_CREDS_ID = ''
        SCRIPTS_DIR  = '.'
    }

    triggers {
        githubPush()
    }

    parameters {
        booleanParam(name: 'backup_db', defaultValue: true, description: 'Run backup_db')
        booleanParam(name: 'backup_files', defaultValue: true, description: 'Run backup_files')
        booleanParam(name: 'send_sftp', defaultValue: true, description: 'Run send_sftp')
        booleanParam(name: 'cleanup', defaultValue: true, description: 'Run cleanup')
        booleanParam(name: 'remove_nextcloud_backups', defaultValue: true, description: 'Run remove_nextcloud_backups')
    }

    stages {
        stage('DB_backup') {
            when { expression { return params.backup_db } }
            agent { label 'nextcloud-home' }
            steps {
                script {
                    checkoutRepo()
                }
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'gnome-terminal']) {
                    sh """
                        chmod +x "${env.SCRIPTS_DIR}/db_backups.sh"
                        "${env.SCRIPTS_DIR}/db_backups.sh"
                    """
                }
            }
        }

        stage('Files_backup') {
            when { expression { return params.backup_files } }
            agent { label 'nextcloud-home' }
            steps {
                script {
                    checkoutRepo()
                }
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'gnome-terminal']) {
                    sh """
                        chmod +x "${env.SCRIPTS_DIR}/files_backup.sh"
                        "${env.SCRIPTS_DIR}/files_backup.sh"
                    """
                }
            }
        }

        stage('Sending_to_SFTP') {
            when { expression { return params.send_sftp } }
            agent { label 'nextcloud-home' }
            steps {
                script {
                    checkoutRepo()
                }
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'gnome-terminal']) {
                    sh """
                        chmod +x "${env.SCRIPTS_DIR}/send_sftp.sh"
                        "${env.SCRIPTS_DIR}/send_sftp.sh"
                    """
                }
            }
        }

        stage('Container_VM_cleanup') {
            when { expression { return params.cleanup } }
            agent { label 'nextcloud-home' }
            steps {
                script {
                    checkoutRepo()
                }
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'gnome-terminal']) {
                    sh """
                        chmod +x "${env.SCRIPTS_DIR}/cleanup.sh"
                        "${env.SCRIPTS_DIR}/cleanup.sh"
                    """
                }
            }
        }

        stage('VM_cleanup') {
            when { expression { return params.cleanup } }
            agent { label 'nextcloud-home' }
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'gnome-terminal']) {
                    sh '''
                        echo "Cleaning the VM backups"
                        sudo rm -rf /mnt/data/backups/*
                    '''
                }
            }
        }

        stage('SFTP_cleanup') {
            when { expression { return params.remove_nextcloud_backups } }
            agent { label 'SFTP' }
            steps {
                script {
                    checkoutRepo()
                }
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'gnome-terminal']) {
                    sh """
                        chmod +x "${env.SCRIPTS_DIR}/sftp_cleanup.sh"
                        "${env.SCRIPTS_DIR}/sftp_cleanup.sh"
                    """
                }
            }
        }
    }
}