*This activity has been created as part of the 42 curriculum by yafranco.*

## Description
This project aims to broaden my knowledge of system administration by using Docker Compose to virtualize a small infrastructure.
The infrastructure consists of multiple Docker containers running specific services: an Nginx web server
(configured with TLSv1.2 or TLSv1.3 only), a WordPress instance coupled with PHP-FPM, and a MariaDB database.
All components are interconnected via a dedicated isolated Docker network and utilize persistent volumes to guarantee data retention.

## Instructions
To build, run, and manage this infrastructure, a Makefile is provided at the root of the repository.

### Setup and Execution
1. To build, configure, and start all containers in the background:
   ```bash
   make
   ```
2. To stop and remove all running containers without losing persistent data:
   ```bash
   make stop
   ```
3. To stop and fully clean up the infrastructure (including containers, networks, and images):
   ```bash
   make clean
   ```
4. To perform a deep clean (including persistent volumes data on the host machine):
   ```bash
   make fclean
   ```
### Project Description

This infrastructure uses Docker Compose to orchestrate independent containers, ensuring service isolation and reproducible environments.
Each service runs in its own container, adhering to the "one container, one service" philosophy.

### Technical Comparisons
1. Virtual Machines vs Docker

* **Virtual Machines (VMs):** VMs virtualize physical hardware. Each VM includes a full guest operating system, virtual drivers,
and a hypervisor layer. This results in a heavy resource footprint, slow boot times, and significant memory overhead.

* **Docker Containers:** Containers virtualize the operating system kernel instead of the hardware.
They share the host system's kernel, making them lightweight, fast to boot (seconds), and highly efficient in terms of CPU and
memory utilization.

2. Secrets vs Environment Variables

* **Environment Variables:** These variables are stored in plain text within the process environment.
They can easily leak through system logs, process listings (ps), or container inspection tools (docker inspect).
They are suitable for non-sensitive configurations.

* **Secrets:** Secrets are designed to handle sensitive data like passwords or API keys securely.
They are encrypted at rest, transmitted securely, and mounted dynamically in-memory only to authorized containers, minimizing the
risk of accidental exposure.

3. Docker Network vs Host Network

* **Host Network:** In host networking mode, the container shares the host's network stack directly.
There is no isolation between the host and the container, meaning container ports map directly to host ports, which can cause conflicts
and introduces security risks.

* **Docker Network (Bridge/Custom):** A custom Docker network creates an isolated private network layer for the containers.
Containers can communicate securely with each other using internal IPs or service names (via automatic DNS), and only explicitly
exposed ports are accessible from the host system.

4. Docker Volumes vs Bind Mounts

* **Bind Mounts:** A bind mount links a specific, absolute path on the host machine directly to a path inside the container.
It depends on the host's file system structure, making it less portable and exposing the host files to potential corruption or
security breaches by the container.

* **Docker Volumes:** Volumes are entirely managed by Docker and stored within a dedicated directory on the host
(/var/lib/docker/volumes/). They are completely isolated from the direct host file system structure, making them more secure,
portable, and easier to backup or share between containers.

### Resources

* Official Docker and Docker Compose Documentation.
* WordPress CLI and Alpine Linux package repositories.
* Nginx and MariaDB official administration guides.
* AI Usage: An AI assistant was used as a learning aid to clarify concepts regarding system architecture, cross-verify Docker
volume mechanisms, and ensure proper security practices regarding environment variables.
