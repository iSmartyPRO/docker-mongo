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
USER_NAME=""
USER_PASSWORD=""

# Разбор именованных аргументов
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -databasename=*) DATABASE_NAME="${1#*=}"; shift ;;
    -username=*) USER_NAME="${1#*=}"; shift ;;
    -password=*) USER_PASSWORD="${1#*=}"; shift ;;
    *) echo "Неизвестный аргумент: $1"; exit 1 ;;
  esac
done

# Проверка, что все параметры переданы
if [[ -z "$DATABASE_NAME" || -z "$USER_NAME" || -z "$USER_PASSWORD" ]]; then
  echo "Использование: $0 -databasename=name -username=name -password=somepassword"
  exit 1
fi

# Проверяем, существует ли контейнер
CONTAINER_EXISTS=$(docker ps -q -f name=$DOCKER_CONTAINER_MONGO_NAME)
if [ -z "$CONTAINER_EXISTS" ]; then
  echo "Контейнер $DOCKER_CONTAINER_MONGO_NAME не запущен. Проверьте Docker или имя контейнера."
  exit 1
fi

# Выполняем команды MongoDB через Docker
docker exec -i $DOCKER_CONTAINER_MONGO_NAME mongo --port $DOCKER_CONTAINER_MONGO_PORT \
  -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase "admin" <<EOF
use $DATABASE_NAME;
db.createUser({
  user: "$USER_NAME",
  pwd: "$USER_PASSWORD",
  roles: [ { role: "readWrite", db: "$DATABASE_NAME" } ]
});
EOF

if [ $? -eq 0 ]; then
  echo "База данных '$DATABASE_NAME' и пользователь '$USER_NAME' успешно созданы."
else
  echo "Ошибка при создании базы данных или пользователя."
  exit 1
fi
