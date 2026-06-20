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


3.B — Hacking Technique in the Lab: Lateral Movement & Attack Chain**

Phase 1: Network Reconnaissance and Service Discovery (nmap)**

What the technique does:** It performs an active service and version detection scan (`-sV`) targeted **specifically at the internal hosts of the Corporate Network**. It utilizes aggressive timing (`-T4`) to accelerate probe response speeds and filters the output using `--open` to immediately isolate potential attack vectors within the private segment by discarding closed or filtered ports.

Why it works: Network services open sockets (ports) to accept incoming traffic. By sending crafted TCP packets toward these ports from a position with internal network visibility and meticulously analyzing the structural responses or application banners returned, `nmap` can accurately deduce the specific software and exact version running within the corporate environment.

Evidence (Command + Output):**
    bash
    $ nmap -sV --open -T4 10.1.0.13 10.1.0.14 10.1.0.15 10.1.0.16
    
    Starting Nmap 7.94SVN ( [https://nmap.org](https://nmap.org) ) at 2026-06-19 22:54 UTC
    Nmap scan report for 10.1.0.13
    Host is up (0.00034s latency).
    Not shown: 999 closed tcp ports (conn-refused)
    PORT     STATE SERVICE VERSION
    8080/tcp open  http    SimpleHTTPServer 0.6 (Python 3.12.3)

    Nmap scan report for 10.1.0.14
    Host is up (0.00082s latency).
    Not shown: 999 closed tcp ports (conn-refused)
    PORT   STATE SERVICE VERSION
    22/tcp open  ssh     OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
    Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
    

What information/access was obtained & Technical Interpretation:**
    While no direct system access or credentials were acquired during this phase, it achieved a **tactical mapping and complete reconnaissance of the Corporate Network (`10.1.0.0/24`)**, gathering critical strategic intelligence about the internal infrastructure that remains hidden from the outside:
    
    1. Host 10.1.0.13 (Internal Corporate Network Web Server):** It was determined to expose port `8080/tcp` running `SimpleHTTPServer 0.6` under `Python 3.12.3`. As an internal development service, it represents a high-interest exploitation vector due to the common lack of strict security hardening policies in this zone.
    2. Host 10.1.0.14 (Corporate Network Administration Server):** The scan detected an active `OpenSSH 7.9p1` service on port `22/tcp` hosted on a `Linux` system (specifically `Debian 10+deb10u2`). Identifying this service inside the corporate network segment provides a key target for auditing weak credentials or known software flaws to consolidate lateral movement.
The scan mapped out active infrastructure components within the target subnet, identifying two highly relevant attack vectors:
Host 10.1.0.13: Exposes port 8080/tcp running a SimpleHTTPServer 0.6 (Python 3.12.3).
Host 10.1.0.14: Exposes port 22/tcp running an older instance of OpenSSH 7.9p1 on Debian 10.
This initial footprint defined the target surface. Further active routing enumeration exposed an internal file transfer node at IP 172.16.10.11, which was selected as the next tactical target.
