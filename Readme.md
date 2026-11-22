# 🔄 Nextcloud Automated Backup & Retention Pipeline

An automated, Git-driven CI/CD backup and retention solution for Nextcloud using **Bash**, **SFTP**, and **Jenkins**.  
Every script update pushed to this repository automatically triggers the Jenkins pipeline via webhook, keeping backup routines version-controlled and self-updating across agents.

---

## 📋 Overview

This repository manages the full lifecycle of Nextcloud backups across two dedicated Jenkins agents (`nextcloud-home` and `SFTP`):

1. **Database Backup (`db_backups.sh`)** — Dumps the Nextcloud database on `nextcloud-home`.
2. **Files & Config Backup (`files_backup.sh`)** — Archives Nextcloud data and configuration files.
3. **Off-Site Transfer (`send_sftp.sh`)** — Uploads generated backup archives to the remote SFTP server.
4. **Container & Local VM Cleanup (`cleanup.sh`)** — Cleans temporary artifacts and clears `/mnt/data/backups/*` after successful transfer.
5. **SFTP Retention Policy (`sftp_cleanup.sh`)** — Keeps only the **latest** backup for each prefix (`nextcloud-config_`, `nextcloud-data_`, `nextcloud-db_`) and safely removes older backups.

---

## 🗂️ Repository Structure

```text
.
├── Jenkinsfile          # Declarative Jenkins pipeline with Git checkout & webhook trigger
├── db_backups.sh        # Dumps Nextcloud database
├── files_backup.sh      # Archives Nextcloud data & config directories
├── send_sftp.sh         # Transfers archives to the SFTP server
├── cleanup.sh           # Cleans container/temporary backup files on Nextcloud host
├── sftp_cleanup.sh      # Prunes old backups on SFTP while keeping the latest snapshot
├── .env.example         # Template for required environment variables
└── README.md            # Project documentation