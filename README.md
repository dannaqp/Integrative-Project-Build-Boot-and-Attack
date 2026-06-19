# Integrative-Project-Build-Boot-and-Attack
Repo for the final integrative project: Your own distro (Cubic) · A 64-bit kernel from scratch · Offensive lab (Black Hat Bash) Members: Mateo Charro, Danna Simaluisa y Camila Villagran

PART 3 — Stand up and attack the Black Hat Bash lab
The following table details the network layout and infrastructure of the offensive lab deployed via Docker Compose:

| Container (Hostname) | Public IP (`172.16.10.0/24`) | Corporate IP (`10.1.0.0/24`) | Port | Service / Stack | Role & Function |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **p-web-01** | `172.16.10.10` | — | `5000` | Flask / Python | Public Web Server (Primary Target) |
| **p-ftp-01** | `172.16.10.11` | — | `21` | Pure-FTPd | Public File Transfer Server |
| **p-web-02** | `172.16.10.12` | `10.1.0.11` | `80` | Node.js / Express | Dual-Homed Web Server |
| **p-jumpbox-01** | `172.16.10.13` | `10.1.0.12` | `22` | OpenSSH | Pivot Bridge / Bastion Host |
| **c-backup-01** | — | `10.1.0.13` | — | Bash Backup Script | Internal Automated Backup Service |
| **c-redis-01** | — | `10.1.0.14` | `6379` | Redis In-Memory | Internal Key-Value Cache |
| **c-db-01** | — | `10.1.0.15` | `3306` | MySQL Server | Primary Production Database |
| **c-db-02** | — | `10.1.0.16` | `3306` | MySQL Replica | Secondary Replication Database |
