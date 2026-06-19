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

#### 🌐 Two-Network Diagram


  ┌────────────────────────────────────────────────────────┐
  │ PUBLIC NETWORK - br_public (172.16.10.0/24)            │
  ├───────────────┬───────────────┬───────────────┬────────┤
  │ p-web-01      │ p-ftp-01      │ p-web-02      │ p-jumpbox-01
  │(172.16.10.10) │(172.16.10.11) │(172.16.10.12) │(172.16.10.13)
  └───────────────┴───────────────┴───────┬───────┴───────┬─┘
                                          │               │
                                          │               │
  ┌───────────────────────────────────────┴───────────────┴─┐
  │ CORPORATE NETWORK - br_corporate (10.1.0.0/24)          │
  ├───────────────┬───────────────┬───────────────┬────────┤
  │ p-web-02      │ p-jumpbox-01  │ c-backup-01   │ c-redis-01
  │ (10.1.0.11)   │ (10.1.0.12)   │ (10.1.0.13)   │ (10.1.0.14)
  ├───────────────┼───────────────┤               └────────┤
  │ c-db-01       │ c-db-02       │                        │
  │ (10.1.0.15)   │ (10.1.0.16)   │                        │
  └───────────────┴───────────────┴────────────────────────


  
3.B — Hacking Technique in the Lab: Lateral Movement & Attack Chain
Phase 1: Network Reconnaissance and Service Discovery (nmap)
What the technique does: It performs a targeted service version scan (-sV) on specific hosts using aggressive timing (-T4) to optimize speed, filtering the output to display only active, accessible ports (--open).
Why it works: Networked hosts expose communication endpoints (ports) to listen for legitimate incoming traffic. By sending crafted TCP packets and analyzing the responses and banners, nmap can determine the exact service type and version running behind an open port.
Evidence:
Bash
$ nmap -sV --open -T4 10.1.0.13 10.1.0.14 10.1.0.15 10.1.0.16
Technical Interpretation:
The scan mapped out active infrastructure components within the target subnet, identifying two highly relevant attack vectors:
Host 10.1.0.13: Exposes port 8080/tcp running a SimpleHTTPServer 0.6 (Python 3.12.3).
Host 10.1.0.14: Exposes port 22/tcp running an older instance of OpenSSH 7.9p1 on Debian 10.
This initial footprint defined the target surface. Further active routing enumeration exposed an internal file transfer node at IP 172.16.10.11, which was selected as the next tactical target.

