# Inception - Developer Documentation

This documentation provides technical insights into the architecture, configuration, and advanced management of the Inception infrastructure.

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

* **Internal Traffic:** Nginx communicates with WordPress via port 9000 (FastCGI). WordPress connects to MariaDB via port 3306. This internal routing happens seamlessly over a private, custom network.

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

* **Query the NariaDB Database Directly:**
```bash
docker exec -it mariadb mariadb -u root -p
```

### Advances Rebuilds
If you modify a Dockerfile or a configuration file within srcs/requirements/, a simple restart won't apply the changes.
You must force a complete rebuild without using cached layers:
```bash
docker compose -f srcs/docker-compose.yml up -d --build --no-cache
```

## 5. Data Persistence & Volume Mechanics
Data persistence is critical to prevent state loss when containers recycle. Docker Volumes are mounted onto specific host paths to isolate runtime engines from static application data.
Host Path Mapping

As required by the administration deployment guidelines, the persistent storage maps to explicit partitions on the host system:

* **WordPress Files:** Bound locally to /home/yafranco/data/wordpress

* **Database Files:** Bound locally to /home/yafranco/data/mariadb

### Volume Inspection

To inspect how Docker sees and structures these components within its subsystem, use:
```bash
docker volume ls
docker volume inspect srcs_wordpress
docker volume inspect srcs_mariadb
```

