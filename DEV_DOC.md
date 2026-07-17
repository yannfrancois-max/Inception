# Inception - Developer Documentation

This documentation provides technical insights into the architecture, configuration, and advanced management of the Inception
infrastructure.

---

## 1. Project Structure & Architecture

The project follows a strict service isolation policy ("one service, one container"). 

```text
~/Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   └── conf/50-server.cnf
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/nginx.conf
        └── wordpress/
            ├── Dockerfile
            └── conf/www.conf
```

### Communication Flow

* **External Traffic:** Port 443 is exposed on the host machine and mapped exclusively to the Nginx container.

* **Internal Traffic:** Nginx communicates with WordPress via port 9000 (FastCGI). WordPress connects to MariaDB via port 3306.
This internal routing happens seamlessly over a private, custom network.

## 2. Environment Prerequisites

Before compiling or developing on this project, ensure the following packages are installed on the host operating system:

* **Docker Engine (v20.10+)**
* **Docker Compose Plugin (v2.0+)**
* **GNU Make**

## 3. Configuration & Secrets Management

The infrastructure relies heavily on environment variables to maintain portability and security.
The Local .env File

All sensitive credentials (database roots, database users, WordPress administrative credentials) are defined in srcs/.env.
During build time and initialization scripts:

* **The MariaDB setup script** reads these variables to initialize databases and grant access permissions.

* **The WordPress setup script** utilizes wp-cli to provision the network, site settings, and core administrative accounts dynamically.

## 4. Useful Development & Debugging Commands

When modifying services or troubleshooting configuration errors, use these targeted commands from the root directory:

### Environment Reset (The "Nuke" Command)

Before running or evaluating the project, it is highly recommended to completely purge the host machine of any active or
residual Docker containers, images, volumes, and networks to prevent conflicts:

```bash
docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null 
```

### Code Compliance & Anti-Cheating Audit

To ensure the repository complies with all 42 rules and contains no forbidden commands or configurations
(which would result in an immediate fail), you can run the following automated checks:

*   **Check for prohibited background/blocking loops (`sleep infinity` or `tail -f`):**
    ```bash
    grep -ri "sleep" srcs/
    grep -ri "tail" srcs/
    ```

*   **Check for forbidden network shortcuts (`network: host` or legacy `links:`):**
    ```bash
    grep -ri "network: host" srcs/
    grep -ri "links:" srcs/
    ```

*   **Check for prohibited `--link` options in scripts or commands:**
    ```bash
    grep -ri "--link" srcs/
    ```

*Note: If these commands return no output (or only show expected configurations), your codebase is 100% compliant and safe.*

### Base Image Version Verification

To verify that all containers are built using the compliant penultimate stable version of Alpine or Debian without opening
each Dockerfile individually:

```bash
grep -ri "FROM" srcs/
```

*Note: This will output the FROM instruction for Nginx, WordPress, and MariaDB, allowing immediate validation of the base OS versions.*

### Container Inspection

* **Check real-time logs for all services:**
```bash
docker compose -f srcs/docker-compose.yml logs -f
```

* **Inspect a specific service configuration:**
```bash
docker compose -f srcs/docker-compose.yml config
```

### Accessing Shells Directly:
To jump inside a running container to verify configuration files or database tables:

* **Enter the Nginx Container:**
```bash
docker exec -it nginx sh
```

* **Enter the Wordpress Container:**
```bash
docker exec -it wordpress sh
```

* **Query the MariaDB Database Directly:**
```bash
docker exec -it mariadb mariadb -u root -p
```

### Advances Rebuilds
If you modify a Dockerfile or a configuration file within srcs/requirements/, a simple restart won't apply the changes.
You must force a complete rebuild without using cached layers:
```bash
docker compose -f srcs/docker-compose.yml up -d --build --no-cache
```

### Nginx SSL/TLS & Port Security Audit

To verify the strict security requirements of Nginx (Port isolation and TLS version restrictions):

*   **Verify that HTTP (Port 80) is completely blocked/unreachable:**
    ```bash
    curl -I [http://yafranco.42.fr](http://yafranco.42.fr)
    ```
    *Expected output: `Connection refused` (indicating no service is listening on port 80).*

*   **Verify that HTTPS (Port 443) is active and accessible:**
    ```bash
    curl -I -k [https://yafranco.42.fr](https://yafranco.42.fr)
    ```
    *Expected output: `HTTP/1.1 200 OK` (ignoring the self-signed certificate warning with `-k`).*

*   **Verify the active TLS Protocol Version (TLSv1.2 or TLSv1.3):**
    ```bash
    openssl s_client -connect yafranco.42.fr:443
    ```
    *Inspection: Look for the line `Protocol  : TLSv1.2` or `Protocol  : TLSv1.3` in the output summary.*

*   **Prove that outdated protocols (TLSv1.1 and below) are strictly rejected:**
    ```bash
    openssl s_client -connect yafranco.42.fr:443 -tls1_1
    ```
    *Expected output: Connection failure / Handshake error (proving Nginx enforces modern encryption standards).*

### Docker Network Audit

To verify that the containers communicate over an isolated, custom private network and are not using the default host network:

*   **List all active Docker networks:**
    ```bash
    docker network ls
    ```
    *What the evaluator will check:*
    *Look for your custom network (typically named `srcs_inception` or `srcs_inception_net`) with the driver set to `bridge`.*

*   **Inspect the custom network details:**
    ```bash
    docker network inspect srcs_inception
    ```
    *What this proves:*
    *This command outputs a JSON showing the exact subnets and, crucially, lists all three running containers*
    *(`nginx`, `wordpress`, `mariadb`) connected to this network with their internal IP addresses.*

## 5. Data Persistence & Volume Mechanics
Data persistence is critical to prevent state loss when containers recycle. Docker Volumes are mounted onto specific host paths
to isolate runtime engines from static application data.
Host Path Mapping

As required by the administration deployment guidelines, the persistent storage maps to explicit partitions on the host system:

* **WordPress Files:** Bound locally to /home/yafranco/data/wordpress

* **Database Files:** Bound locally to /home/yafranco/data/mariadb

### Volume Inspection

To inspect how Docker sees and structures these components within its subsystem, use:
*   **List all active volumes:**
    ```bash
    docker volume ls
    ```

*   **Inspect WordPress Volume configuration:**
    ```bash
    docker volume inspect srcs_wordpress_data
    ```
    *What the evaluator will check:* Verify that the `"Options"` block contains `"device": "/home/yafranco/data/wordpress"`.

*   **Inspect MariaDB Volume configuration:**
    ```bash
    docker volume inspect srcs_mariadb_data
    ```
    *What the evaluator will check:* Verify that the `"Options"` block contains `"device": "/home/yafranco/data/mariadb"`.

### Physical Path Verification (On the Host)

To prove to the evaluator that data is physically written and persistent on the host filesystem:

*   **Check WordPress files on the host:**
    ```bash
    ls -la /home/yafranco/data/wordpress
    ```

*   **Check MariaDB database files on the host:**
    ```bash
    ls -la /home/yafranco/data/mariadb
    ```
    *Expected output:* You should see actual MariaDB configuration and database files

## 🔒 Git & Security Audit Protocol

This section outlines the commands used to audit the repository before pushing, ensuring no sensitive credentials
(such as those in the `.env` file) are committed or tracked in the Git history.

### 1. Verification of Ignored Files

To ensure that sensitive configuration files (like `.env`) are properly ignored by Git and will not be tracked:

```bash
git check-ignore -v srcs/.env
```
*Note: the -v (verbose) flag is highly recommended as it displays the exact file and line number of the .gitignore rule responsible*
*for ignoring the file.*

### 2. Verification of Tracked Files

Even if a file is added to `.gitignore`, Git will continue to track it if it was committed beforehand.
To verify that no `.env` file is currently tracked in your index:

```bash
git ls-files | grep "\.env"
```

*Note: If this command returns no output, it means you .env file is safe and not tracked by Git.*

### 3. Git History Audit (The "Pickaxe" Search)

To ensure no sensitive variables or passwords (such as SQL_ROOT_PASSWORD) were accidentally committed in the past and
remain hidden in the Git history:

```bash
git log -S "SQL_ROOT_PASSWORD"
```

*Note: Replace "SQL_ROOT_PASSWORD" with any sensitive keyword or password to search the entire commit history for its*
*addition or removal. If no commits are listed, your history is clean.*
