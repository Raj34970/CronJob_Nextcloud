def runBackupScript(String scriptName, boolean bindEnv = true) {
    return {
        checkout scm
        wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'gnome-terminal']) {
            if (bindEnv) {
                withCredentials([file(credentialsId: "${env.NEXTCLOUD_ENV_ID}", variable: 'ENV_FILE')]) {
                    try {
                        sh """
                            set -euo pipefail
                            TARGET_ENV="${env.SCRIPTS_DIR}/.env"
                            cp "\$ENV_FILE" "\$TARGET_ENV"
                            chmod 600 "\$TARGET_ENV"
                            chmod +x "${env.SCRIPTS_DIR}/${scriptName}"
                            "${env.SCRIPTS_DIR}/${scriptName}"
                        """
                    } finally {
                        sh """
                            set -euo pipefail
                            rm -f "${env.SCRIPTS_DIR}/.env"
                        """
                    }
                }
            } else {
                sh """
                    set -euo pipefail
                    chmod +x "${env.SCRIPTS_DIR}/${scriptName}"
                    "${env.SCRIPTS_DIR}/${scriptName}"
                """
            }
        }
    }
}

pipeline {
    agent none

    environment {
        GIT_CREDS_ID     = 'backup-job-token'
        SCRIPTS_DIR      = '.'
        NEXTCLOUD_ENV_ID = 'nextcloud-env-file'
        BACKUP_DIR       = '/mnt/data/backups'
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
                    runBackupScript('db_backups.sh', true)()
                }
            }
        }

        stage('Files_backup') {
            when { expression { return params.backup_files } }
            agent { label 'nextcloud-home' }
            steps {
                script {
                    runBackupScript('files_backup.sh', true)()
                }
            }
        }

        stage('Sending_to_SFTP') {
            when { expression { return params.send_sftp } }
            agent { label 'nextcloud-home' }
            steps {
                script {
                    runBackupScript('send_sftp.sh', true)()
                }
            }
        }

        stage('Container_VM_cleanup') {
            when { expression { return params.cleanup } }
            agent { label 'nextcloud-home' }
            steps {
                script {
                    runBackupScript('cleanup.sh', true)()
                }
            }
        }

        stage('VM_cleanup') {
            when { expression { return params.cleanup } }
            agent { label 'nextcloud-home' }
            steps {
                wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'gnome-terminal']) {
                    sh '''
                        set -euo pipefail

                        : "${BACKUP_DIR:?ERROR: BACKUP_DIR is unset or empty}"

                        RESOLVED_DIR="$(realpath -m "${BACKUP_DIR}")"
                        case "${RESOLVED_DIR}" in
                            ""|"/"|"/root"|"/root/script"|"/mnt"|"/mnt/data")
                                echo "ERROR: Refusing to delete from unsafe path: ${RESOLVED_DIR}" >&2
                                exit 1
                                ;;
                        esac

                        if [ ! -d "${RESOLVED_DIR}" ]; then
                            echo "Backup directory ${RESOLVED_DIR} does not exist; skipping cleanup."
                            exit 0
                        fi

                        echo "Cleaning backup files in ${RESOLVED_DIR}"
                        sudo find "${RESOLVED_DIR}" -maxdepth 1 -type f \
                            \( -name 'nextcloud-config_*.tar.gz' -o -name 'nextcloud-db_*.sql' \) \
                            -delete
                    '''
                }
            }
        }

        stage('SFTP_cleanup') {
            when { expression { return params.remove_nextcloud_backups } }
            agent { label 'SFTP' }
            steps {
                script {
                    runBackupScript('sftp_cleanup.sh', false)()
                }
            }
        }
    }
}