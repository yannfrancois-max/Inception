NAME = inception

all:
	@mkdir -p /home/yafranco/data/mariadb
	@mkdir -p /home/yafranco/data/wordpress
	docker compose -f srcs/docker-compose.yml up -d --build

stop:
	docker compose -f srcs/docker-compose.yml stop

clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean:	clean
	@# Utilisation d'un conteneur temporaire pour supprimer les fichiers root sans sudo
	@if [ -d "/home/yafranco/data" ]; then \
		docker run --rm -v /home/yafranco/data:/data debian:bookworm rm -rf /data/mariadb /data/wordpress; \
	fi
	docker system prune -af

re:	fclean all

.PHONY: all stop clean fclean re

