#!/bin/bash

# Загружаем переменные из .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Файл .env не найден!"
  exit 1
fi

# Инициализация переменных
DATABASE_NAME=""

# Разбор аргументов
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -databasename=*) DATABASE_NAME="${1#*=}"; shift ;;
    *) echo "Неизвестный аргумент: $1"; exit 1 ;;
  esac
done

# Проверка, что имя базы данных указано
if [[ -z "$DATABASE_NAME" ]]; then
  echo "Использование: $0 -databasename=dbName"
  exit 1
fi

# Проверяем, существует ли контейнер
CONTAINER_EXISTS=$(docker ps -q -f name=$DOCKER_CONTAINER_MONGO_NAME)
if [ -z "$CONTAINER_EXISTS" ]; then
  echo "Контейнер $DOCKER_CONTAINER_MONGO_NAME не запущен. Проверьте Docker или имя контейнера."
  exit 1
fi

# Выполняем команду для отображения списка коллекций
docker exec -i $DOCKER_CONTAINER_MONGO_NAME mongo --port $DOCKER_CONTAINER_MONGO_PORT \
  -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase "admin" <<EOF
use $DATABASE_NAME;
show collections;
EOF

if [ $? -ne 0 ]; then
  echo "Ошибка при подключении к MongoDB или выполнении команды."
  exit 1
fi
