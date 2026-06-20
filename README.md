# Integrative-Project-Build-Boot-and-Attack
Repo for the final integrative project: Your own distro (Cubic) · A 64-bit kernel from scratch · Offensive lab (Black Hat Bash) Members: Mateo Charro, Danna Simaluisa y Camila Villagran

PART 3 — Stand up and attack the Black Hat Bash lab
The following table details the network layout and infrastructure of the offensive lab deployed via Docker Compose:

| Machine | Hostname | Public IP (`172.16.10.0/24`) | Corporate IP (`10.1.0.0/24`) | Mapped Port |
| :--- | :--- | :---: | :---: | :---: |
| **p-web-02** | `p-web-02` | `172.16.10.12` | `10.1.0.11` | `80/tcp` |
| **p-jumpbox-01** | `p-jumpbox-01` | `172.16.10.13` | `10.1.0.12` | — |
| **p-web-01** | `p-web-01` | `172.16.10.10` | — | — |
| **p-ftp-01** | `p-ftp-01` | `172.16.10.11` | — | — |
| **c-backup-01** | `c-backup-01` | — | `10.1.0.13` | — |
| **c-redis-01** | `c-redis-01` | — | `10.1.0.14` | `6379/tcp` |
| **c-db-02** | `c-db-02` | — | `10.1.0.16` | `3306/tcp` |
| **c-db-01** | `c-db-01` | — | `10.1.0.15` | — |

```text
+-------------------------------------------------------------+
|          PUBLIC NETWORK - br_public (172.16.10.0/24)        |
+-------------------------------------------------------------+
     |              |              |              |
  p-web-01       p-ftp-01       p-web-02     p-jumpbox-01
172.16.10.10   172.16.10.11   172.16.10.12   172.16.10.13
     |              |              |              |
                                   +-------+------+
                                           |
                                      (Pivoting)
                                           |
                                   +-------+------+
     |              |              |              |
  c-db-01        c-db-02        p-web-02     p-jumpbox-01
 10.1.0.15      10.1.0.16      10.1.0.11      10.1.0.12
     |              |              |              |
  c-backup-01    c-redis-01        |              |
 10.1.0.13      10.1.0.14          |              |
     |              |              |              |
+-------------------------------------------------------------+
|        CORPORATE NETWORK - br_corporate (10.1.0.0/24)       |
+-------------------------------------------------------------+


