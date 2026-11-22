pipeline {

    agent none

    environment {
        GIT_CREDS_ID     = 'backup-job-token'
        SCRIPTS_DIR      = '.'
        NEXTCLOUD_ENV_ID = 'nextcloud-env-file'
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
                checkout scm
                withCredentials([file(credentialsId: "${env.NEXTCLOUD_ENV_ID}", variable: 'ENV_FILE')]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'gnome-terminal']) {
                        sh """
                            rm -f "${env.SCRIPTS_DIR}/.env"
                            cp "\$ENV_FILE" "${env.SCRIPTS_DIR}/.env"
                            chmod 600 "${env.SCRIPTS_DIR}/.env"
                            chmod +x "${env.SCRIPTS_DIR}/db_backups.sh"
                            "${env.SCRIPTS_DIR}/db_backups.sh"
                        """
                    }
                }
            }
            post {
                always {
                    sh "rm -f '${env.SCRIPTS_DIR}/.env'"
                }
            }
        }

        stage('Files_backup') {
            when { expression { return params.backup_files } }
            agent { label 'nextcloud-home' }
            steps {
                checkout scm
                withCredentials([file(credentialsId: "${env.NEXTCLOUD_ENV_ID}", variable: 'ENV_FILE')]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'gnome-terminal']) {
                        sh """
                            rm -f "${env.SCRIPTS_DIR}/.env"
                            cp "\$ENV_FILE" "${env.SCRIPTS_DIR}/.env"
                            chmod 600 "${env.SCRIPTS_DIR}/.env"
                            chmod +x "${env.SCRIPTS_DIR}/files_backup.sh"
                            "${env.SCRIPTS_DIR}/files_backup.sh"
                        """
                    }
                }
            }
            post {
                always {
                    sh "rm -f '${env.SCRIPTS_DIR}/.env'"
                }
            }
        }

        stage('Sending_to_SFTP') {
            when { expression { return params.send_sftp } }
            agent { label 'nextcloud-home' }
            steps {
                checkout scm
                withCredentials([file(credentialsId: "${env.NEXTCLOUD_ENV_ID}", variable: 'ENV_FILE')]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'gnome-terminal']) {
                        sh """
                            rm -f "${env.SCRIPTS_DIR}/.env"
                            cp "\$ENV_FILE" "${env.SCRIPTS_DIR}/.env"
                            chmod 600 "${env.SCRIPTS_DIR}/.env"
                            chmod +x "${env.SCRIPTS_DIR}/send_sftp.sh"
                            "${env.SCRIPTS_DIR}/send_sftp.sh"
                        """
                    }
                }
            }
            post {
                always {
                    sh "rm -f '${env.SCRIPTS_DIR}/.env'"
                }
            }
        }

        stage('Container_VM_cleanup') {
            when { expression { return params.cleanup } }
            agent { label 'nextcloud-home' }
            steps {
                checkout scm
                withCredentials([file(credentialsId: "${env.NEXTCLOUD_ENV_ID}", variable: 'ENV_FILE')]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'gnome-terminal']) {
                        sh """
                            rm -f "${env.SCRIPTS_DIR}/.env"
                            cp "\$ENV_FILE" "${env.SCRIPTS_DIR}/.env"
                            chmod 600 "${env.SCRIPTS_DIR}/.env"
                            chmod +x "${env.SCRIPTS_DIR}/cleanup.sh"
                            "${env.SCRIPTS_DIR}/cleanup.sh"
                        """
                    }
                }
            }
            post {
                always {
                    sh "rm -f '${env.SCRIPTS_DIR}/.env'"
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
                checkout scm
                withCredentials([file(credentialsId: "${env.NEXTCLOUD_ENV_ID}", variable: 'ENV_FILE')]) {
                    wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'gnome-terminal']) {
                        sh """
                            rm -f "${env.SCRIPTS_DIR}/.env"
                            cp "\$ENV_FILE" "${env.SCRIPTS_DIR}/.env"
                            chmod 600 "${env.SCRIPTS_DIR}/.env"
                            chmod +x "${env.SCRIPTS_DIR}/sftp_cleanup.sh"
                            "${env.SCRIPTS_DIR}/sftp_cleanup.sh"
                        """
                    }
                }
            }
            post {
                always {
                    sh "rm -f '${env.SCRIPTS_DIR}/.env'"
                }
            }
        }
    }
}