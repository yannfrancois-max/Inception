NAME = inception

all:
	@mkdir -p /home/yafranco/data/mariadb
	@mkdir -p /home/yafranco/data/wordpress
	docker compose -f srcs/docker-compose.yml up -d --build

clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean:	clean
	@sudo rm -rf /home/yafranco/data/mariadb
	@sudo rm -rf /home/yafranco/data/wordpress
	docker system prune -af

re:	fclean all

.PHONY: all clean fclean re

