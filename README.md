*This activity has been created as part of the 42 curriculum by yafranco.*

# Inception: Multi-Container Web Infrastructure

## Description
A fully containerized, production-oriented web infrastructure deployed using **Docker Compose**. The stack orchestrates an **Nginx** reverse proxy enforcing strict TLS standards, a **WordPress** engine running on **PHP-FPM**, and an isolated **MariaDB** database backend, bound via custom bridge networks and persistent host volumes.

---

## Infrastructure Architecture

```text
                    Internet / Client
                            │
                            │ HTTPS (Port 443) [TLSv1.2 / TLSv1.3]
                            ▼
                 ┌─────────────────────┐
                 │   Nginx Container   │
                 │  (TLS Termination)  │
                 └──────────┬──────────┘
                            │
                            │ FastCGI Protocol (Port 9000 - Internal)
                            ▼
                 ┌─────────────────────┐      ┌─────────────────────┐
                 │  WordPress PHP-FPM  │◄────►│  MariaDB Database   │
                 │      Container      │      │      Container      │
                 └──────────┬──────────┘      └──────────┬──────────┘
                            │                            │
             ┌──────────────┴──────────────┐      ┌──────┴──────────────┐
             ▼                             ▼      ▼                     ▼
      wp-data volume                 Custom Docker Network         db-data volume
```

## Key Engineering Constraints
- **Zero Pre-Built Images**: All container images are compiled from custom base images via explicit Dockerfiles (no ready-made Docker Hub application images).
- **Process Isolation**: Adheres strictly to the single-responsibility principle (one primary process per container)
- **Perimeter Defense**: Only the Nginx reverse proxy exposes port 443 externally. WordPress and MariaDB communicate exclusively within an isolated internal bridge network.

## Directory Structure

```Plaintext
.
├── Makefile                     # Infrastructure automation lifecycle
├── README.md                    # System architecture documentation
├── DEV_DOC.md                   # Internal engineering guidelines
├── USER_DOC.md                  # Deployment & administration guide
└── srcs/
    ├── docker-compose.yml       # Stack service definitions & network topology
    ├── .env.example             # Template for required environment variables
    └── requirements/
        ├── mariadb/             # Dockerfile, custom scripts & configs
        ├── nginx/               # Dockerfile, TLS certificates & nginx.conf
        └── wordpress/           # Dockerfile, PHP-FPM configuration & WP-CLI setup
```

## Quickstart
1. **Prerequisites & Host Configuration**
Map the local domain in your host's /etc/hosts file:
   ```bash
   sudo echo "127.0.0.1 yafranco.42.fr" >> /etc/hosts
   ```
2. **Environment Configuration**
Create the .env configuration file from the template:
   ```bash
   cp srcs/.env.example srcs/.env
   # Edit srcs/.env with your secure database and admin credentials
   ```
3. **Lifecycle Automation via Makefile**
   ```bash
   make         # Builds custom images and starts all services in detached mode
   make stop    # Halts active containers without dropping persistent volume data
   make clean   # Stops containers and removes associated networks and runtime images
   make fclean  # Complete purge: clears containers, networks, images, and host-bound volumes
   make re      # Performs a clean rebuild from scratch
   ```
4. **Access Endpoints**
   - Public Web Application: https://yafranco.42.fr
   - WordPress Admin Panel: https://yafranco.42.fr/wp-admin

## Architectural Trade-offs & Security Principles
1. **Bare-Metal Virtual Machines vs. Containers**
- **Virtual Machines (VMs)**: Abstract physical hardware via a hypervisor, requiring an entire guest OS kernel, emulated drivers, and high memory footprints.
- **Containers**: Abstract the host kernel via cgroups and namespaces. Boot times drop from minutes to sub-seconds, with minimal resource overhead and reproducible configuration.

2. **Secrets Management vs. Environment Variables**
- **Environment Variables**: Readable via process inspection (ps aux, /proc/$PID/environ) or docker inspect. Suitable only for non-sensitive system toggles.
- **Docker Secrets**: Stored encrypted in memory, mounted temporarily into /run/secrets/, preventing disk persistence and log leaks.

3. **Network Isolation (Isolated Bridge vs. Host Network)**
- **Host Mode**: Eliminates network boundaries; all ports bind directly to host interfaces, escalating blast radius if a web service is breached.
- **Custom Bridge Network**: Provides internal software-defined subnetting with automatic service discovery (DNS). Databases remain unreachable from outside interfaces.

4. **Storage Persistence (Named Volumes vs. Host Bind Mounts)**
- **Bind Mounts**: Tightly coupled to host file system structures, risking privilege escalation and container portability issues.
- **Docker Volumes**: Fully abstracted by the container runtime, isolated from host direct access, enabling automated lifecycle management and atomic backups.

### Validation & Verification Protocol

## **TLS & Certificate Inspection**
Validate that external traffic is encrypted exclusively via modern cryptographic standards:
```bash
openssl s_client -connect yafranco.42.fr:443 -tls1_3 < /dev/null | openssl x509 -text -noout
```
*Expected audit results*:
- **Subject / CN**: Must resolve strictly to yafranco.42.fr.
- **TLS Protocol**: Only TLSv1.2 or TLSv1.3 handshakes are accepted.

## **Database Integrity & Principle of Least Privilege**
1. **Connect to MariaDB container**:
```bash
docker exec -it mariadb mariadb -u root -p
```
2. **Verify target application database**:
```bash
SHOW DATABASES;
USE inception_db;
SHOW TABLES;
```
3. **Audit user grant privileges**:
```bash
SELECT User, Host FROM mysql.user;
SHOW GRANTS FOR 'wp_user'@'%';
```
*Verification criteria*: Confirms that the application user (wp_user) is strictly granted permissions on inception_db.* and has zero administrative privileges over system databases.

## References
- Docker Engine & Compose Architecture Specifications
- Nginx Official Administration & TLS Hardening Guide
- MariaDB Knowledge Base & Security Hardening
- WP-CLI Command Reference
