# Inception - User Documentation

This guide explains how to operate, access, and verify the services provided by the Inception infrastructure.

---

## 1. Services Overview
The infrastructure deploys three fully isolated services:
*   **Nginx:** The secure web server acting as the single entry point via HTTPS (TLSv1.2/TLSv1.3).
*   **WordPress:** The content management system powered by PHP-FPM.
*   **MariaDB:** The relational database storing all WordPress data.

---

## 2. Getting Started

### Starting the Infrastructure
To launch all services in the background, run the following command from the root directory:
```bash
make
```

### Stopping the Infrastructure
To stop the services without deleting your data (persistent volumes are preserved):
```bash
make stop
```

## 3. Accessing the Application

### Prerequisites
Before accessing the website, you should map the local domain name to your loopback IP address and
add the following line to your host machine's /etc/hosts file:
```bash
127.0.0.1 yafranco.42.fr
```
However, since modifying the host's /etc/hosts file requires administrator (sudo) privileges—which are unavailable on
the cluster's host machines—we must bypass this restriction using a volatile DNS resolution directly within the browser.
To do this, open the browser by running the following command in your terminal:
```bash
chromium-browser --user-data-dir=/tmp/chrome_temp --host-rules="MAP yafranco.42.fr 127.0.0.1:4430" --ignore-certificate-errors &
```
⚠️ Note: This command maps the domain yafranco.42.fr to the host's local port 4430 (which is configured to forward traffic directly
to the standard HTTPS port 443 inside the Virtual Machine). This allows you to access the site using the clean,
required URL without any visible port numbers.

### Web Interfaces
Once the infrastructure is running, open your web browser and navigate to:

* **WordPress Website:** https://yafranco.42.fr
* **WordPress Admin Dashboard:** https://yafranco.42.fr/wp-admin

⚠️ Note: Since the container uses a self-signed SSL certificate, your browser will display a security warning.
You can safely bypass this warning by clicking "Advanced" and proceeding to the site.

## 4. Credentials and User Management
All sensitive parameters, credentials, and configuration keys are securely separated from the codebase and stored in the local environment file:

* **Location:** srcs/.env

### Default Configured Accounts

* **Administrator Account:** Used to manage the WordPress layout and plugins (Username: db_manager).
* **Regular User Account:** Used for daily website interaction and testing (Username: yafranco).

## 5. Verifying Service Health
To confirm that all services are up and running properly, run:
```bash
docker compose -f srcs/docker-compose.yml ps
```

### Expected output
All containers (nginx, wordpress, and mariadb) should display a status of Up or Running.
If any container shows Exit 0 or Error, check the operational logs using:
```bash
docker compose -f srcs/docker-compose.yml logs [service_name]
```

