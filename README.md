## Как работает 
Создание образа и конnейнера с кастомным GREETING
```
docker build -t counter-app .
docker run -d --name counter -p 8080:8000 -e GREETING="Привет из DOCKER" counter-app
```

Применение команды:
```
curl -fsS http://127.0.0.1:8080/
```
Выводит(не увеличивает `count`):
```
{"greeting": "Привет из DOCKER", "count": 0, "hostname": "8e524160bed0", "storage": "sqlite"}
```

Использование команды:
```
curl -fsS -X POST http://127.0.0.1:8080/increment
```

Выводит(`count` увеличивался):
```
{"greeting": "Привет из DOCKER", "count": 1, "hostname": "8e524160bed0", "storage": "sqlite"}
```

Команда:
```
curl -fsS http://127.0.0.1:8080/readyz
```
Выводит:
```
{"status": "ready", "storage": "sqlite"}
```
Команда:
```
docker logs counter
```
Выводит:
```
2026-11-22 15:50:40,641 listening port=8000 storage=sqlite
2026-11-22 15:50:52,195 http 172.17.0.1 "GET / HTTP/1.1" 200 -
2026-11-22 15:51:08,745 http 172.17.0.1 "POST /increment HTTP/1.1" 200 -
2026-11-22 15:51:20,485 http 172.17.0.1 "GET /readyz HTTP/1.1" 200 -
```