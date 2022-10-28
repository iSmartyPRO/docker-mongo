# Краткое описание
Сервер базы данных MongoDB, версия 4.4.13


# Как пользоваться

## Установка
```
docker-compose up -d
```

## Удаление
```
docker-compose down
```

## Подключение к серверу
```
mongosh mongodb://ismarty:SomePasswordHere@yourIpHere
```

## Создание пользователя и базы данных
```
db = db.getSiblingDB('DATABASE_NAME')
db.createUser( { user: "DATABASE_USER", pwd: "DATABASE_PASSWORD", roles: [ "readWrite"]} )
```
