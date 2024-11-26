#!/bin/bash

# Загружаем переменные из .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Файл .env не найден!"
  exit 1
fi

# Проверяем, существует ли контейнер
CONTAINER_EXISTS=$(docker ps -q -f name=$DOCKER_CONTAINER_MONGO_NAME)
if [ -z "$CONTAINER_EXISTS" ]; then
  echo "Контейнер $DOCKER_CONTAINER_MONGO_NAME не запущен. Проверьте Docker или имя контейнера."
  exit 1
fi

# Выполняем команду для отображения списка баз данных
docker exec -i $DOCKER_CONTAINER_MONGO_NAME mongo --port $DOCKER_CONTAINER_MONGO_PORT \
  -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase "admin" <<EOF
show dbs;
EOF

if [ $? -ne 0 ]; then
  echo "Ошибка при подключении к MongoDB или выполнении команды."
  exit 1
fi
