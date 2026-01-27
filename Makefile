COMPOSE_FILE=./srcs/docker-compose.yml

up:
	docker compose -f $(COMPOSE_FILE) up --build -d

down:
	docker compose -f $(COMPOSE_FILE) down

clean:
	docker compose -f $(COMPOSE_FILE) down -v

fclean: clean
	docker system prune -a --volumes -f

re: fclean up

.PHONY: up down clean fclean re
