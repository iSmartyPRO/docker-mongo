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
COLLECTION_NAME=""
LIMIT=10
FILTER="{}"  # По умолчанию фильтр пустой (все документы)

# Разбор аргументов
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -databasename=*) DATABASE_NAME="${1#*=}"; shift ;;
    -collection=*) COLLECTION_NAME="${1#*=}"; shift ;;
    -limit=*) LIMIT="${1#*=}"; shift ;;
    -filter=*) FILTER="${1#*=}"; shift ;;  # Устанавливаем фильтр
    *) echo "Неизвестный аргумент: $1"; exit 1 ;;
  esac
done

# Проверка обязательных параметров
if [[ -z "$DATABASE_NAME" || -z "$COLLECTION_NAME" ]]; then
  echo "Использование: $0 -databasename=dbName -collection=collectionName [-limit=10] [-filter='{field:value}']"
  exit 1
fi

# Проверяем, существует ли контейнер
CONTAINER_EXISTS=$(docker ps -q -f name=$DOCKER_CONTAINER_MONGO_NAME)
if [ -z "$CONTAINER_EXISTS" ]; then
  echo "Контейнер $DOCKER_CONTAINER_MONGO_NAME не запущен. Проверьте Docker или имя контейнера."
  exit 1
fi

# Проверяем корректность фильтра (например, чтобы он начинался и заканчивался фигурными скобками)
if [[ ! "$FILTER" =~ ^\{.*\}$ ]]; then
  echo "Некорректный фильтр. Фильтр должен быть в формате JSON: '{field:value}'"
  exit 1
fi

# Сформируем запрос
QUERY="db.$COLLECTION_NAME.find($FILTER).limit($LIMIT).pretty();"

# Выведем сформированный запрос
echo "Сформированный запрос:"
echo "$QUERY"
echo "====================="

# Выполняем команду для отображения содержимого коллекции с фильтром
docker exec -i $DOCKER_CONTAINER_MONGO_NAME mongo --port $DOCKER_CONTAINER_MONGO_PORT \
  -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --authenticationDatabase "admin" <<EOF
use $DATABASE_NAME;
$QUERY
EOF

if [ $? -ne 0 ]; then
  echo "Ошибка при подключении к MongoDB или выполнении команды."
  exit 1
fi
