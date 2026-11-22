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
## 6 баллов
Файл с настройками-образцом `.env.example` (рабочий `.env` создаётся копированием и не попадает в git):
```
GREETING=Привет из DOCKER
HOST_PORT=127.0.0.1:8080
```

Создание своего `.env`:
```
cp .env.example .env
```

Запуск через Docker Compose:
```
docker compose up -d --build
```
Выводит:
```
[+] up 4/4
 ✔ Image aleksandrmatveev_hw_3-app           Built                                                                  2.6s
 ✔ Volume aleksandrmatveev_hw_3_counter_data Created                                                                0.0s
 ✔ Network aleksandrmatveev_hw_3_default     Created                                                                0.1s
 ✔ Container aleksandrmatveev_hw_3-app-1     Started  
```

Команда (увеличиваем счётчик два раза):
```
curl -fsS -X POST http://127.0.0.1:8080/increment
curl -fsS -X POST http://127.0.0.1:8080/increment
```
Выводит (`count` увеличился до 2):
```
{"greeting": "Привет из DOCKER", "count": 1, "hostname": "faeaa39043d1", "storage": "sqlite"}
{"greeting": "Привет из DOCKER", "count": 2, "hostname": "faeaa39043d1", "storage": "sqlite"}
```

Команда (смотрим значение до удаления контейнера):
```
curl -fsS http://127.0.0.1:8080/
```
Выводит:
```
{"greeting": "Привет из DOCKER", "count": 2, "hostname": "faeaa39043d1", "storage": "sqlite"}
```

Удаление и повторное создание контейнера:
```
docker compose down
docker compose up -d
```
Выводит:
```
[+] down 2/2
 ✔ Container aleksandrmatveev_hw_3-app-1 Removed                                                                                                                            3.3s
 ✔ Network aleksandrmatveev_hw_3_default Removed                                                                                                                            0.2s
[+] up 2/2
 ✔ Network aleksandrmatveev_hw_3_default Created                                                                                                                            0.1s
 ✔ Container aleksandrmatveev_hw_3-app-1 Started 
```

Команда (смотрим значение после пересоздания):
```
curl -fsS http://127.0.0.1:8080/
```
Выводит (`count` тот же, `hostname` изменился, значит контейнер новый, а данные сохранились в volume):
```
{"greeting": "Привет из DOCKER", "count": 2, "hostname": "05568d12f63d", "storage": "sqlite"}
```

Проверка, что volume существует:
```
docker volume ls
```
Выводит:
```
DRIVER    VOLUME NAME
local     aleksandrmatveev_hw_3_counter_data
```
## 8 баллов: отдельное хранилище (Redis)

В `compose.yaml` теперь два сервиса: `app` и `redis`. Приложение работает с `STORAGE=redis` и `REDIS_URL=redis://redis:6379/0`. Volume `redis_data` подключён к `/data` сервиса `redis`.
У обоих сервисов есть healthcheck. Наружу опубликован только порт приложения, у `redis` порты не публикуются.

Запуск:
```
docker compose up -d --build
```
Выводит:
```
[+] up 5/5
 ✔ Image aleksandrmatveev_hw_3-app         Built
 ✔ Network aleksandrmatveev_hw_3_default   Created
 ✔ Volume aleksandrmatveev_hw_3_redis_data Created
 ✔ Container aleksandrmatveev_hw_3-redis-1 Healthy
 ✔ Container aleksandrmatveev_hw_3-app-1   Started
```

Команда:
```
docker compose ps
```
Выводит (Redis `healthy`, приложение ещё проходит первую проверку):
```
NAME                            IMAGE                       COMMAND                  SERVICE   CREATED         STATUS                                     PORTS
aleksandrmatveev_hw_3-app-1     aleksandrmatveev_hw_3-app   "python -u app.py"       app       5 seconds ago   Up Less than a second (healthy)   127.0.0.1:8080->8000/tcp
aleksandrmatveev_hw_3-redis-1   redis:7.4-alpine            "docker-entrypoint.s…"   redis     5 seconds ago   Up 5 seconds (healthy)                     6379/tcp
```

Команда (начальное состояние):
```
curl -fsS http://127.0.0.1:8080/
```
Выводит (`storage` теперь `redis`, `count` равен 0):
```
{"greeting": "Привет из DOCKER", "count": 0, "hostname": "1a63000ace70", "storage": "redis"}
```

# Проверка 1: данные сохраняются после пересоздания

Команда (увеличиваем счётчик три раза):
```
curl -fsS -X POST http://127.0.0.1:8080/increment
curl -fsS -X POST http://127.0.0.1:8080/increment
curl -fsS -X POST http://127.0.0.1:8080/increment
```
Выводит (`count` растёт до 3):
```
{"greeting": "Привет из DOCKER", "count": 1, "hostname": "1a63000ace70", "storage": "redis"}
{"greeting": "Привет из DOCKER", "count": 2, "hostname": "1a63000ace70", "storage": "redis"}
{"greeting": "Привет из DOCKER", "count": 3, "hostname": "1a63000ace70", "storage": "redis"}
```

Команда:
```
curl -fsS http://127.0.0.1:8080/
```
Выводит (`count = 3`):
```
{"greeting": "Привет из DOCKER", "count": 3, "hostname": "1a63000ace70", "storage": "redis"}
```

Удаление и повторное создание контейнеров:
```
docker compose down
docker compose up -d
```
Выводит:
```
[+] down 3/3
 ✔ Container aleksandrmatveev_hw_3-app-1   Removed
 ✔ Container aleksandrmatveev_hw_3-redis-1 Removed
 ✔ Network aleksandrmatveev_hw_3_default   Removed
[+] up 3/3
 ✔ Network aleksandrmatveev_hw_3_default   Created
 ✔ Container aleksandrmatveev_hw_3-redis-1 Healthy
 ✔ Container aleksandrmatveev_hw_3-app-1   Started
```

Команда:
```
docker compose ps
```
Выводит:
```
NAME                            IMAGE                       COMMAND                  SERVICE   CREATED         STATUS                           PORTS
aleksandrmatveev_hw_3-app-1     aleksandrmatveev_hw_3-app   "python -u app.py"       app       7 seconds ago   Up 1 second (health: starting)   127.0.0.1:8080->8000/tcp
aleksandrmatveev_hw_3-redis-1   redis:7.4-alpine            "docker-entrypoint.s…"   redis     8 seconds ago   Up 7 seconds (healthy)           6379/tcp
```

Команда:
```
curl -fsS http://127.0.0.1:8080/
```
Выводит (`count` тот же, `hostname` изменился с `1a63000ace70` на `6f22512cbdfc`, значит контейнер новый, а данные сохранились в volume):
```
{"greeting": "Привет из DOCKER", "count": 3, "hostname": "6f22512cbdfc", "storage": "redis"}
```

# Проверка 2: Redis остановлен

Команда:
```
docker compose stop redis
```
Выводит:
```
[+] stop 1/1
 ✔ Container aleksandrmatveev_hw_3-redis-1 Stopped
```

Команда (приложение живо):
```
curl -fsS http://127.0.0.1:8080/healthz
```
Выводит:
```
{"status": "alive"}
```

Команда (ошибка, ответ 503 виден в логах):
```
curl -fsS http://127.0.0.1:8080/readyz
```
Выводит:
```
{"error": "storage_unavailable"}
```

Команда (ошибка, ответ 503 виден в логах):
```
curl -fsS -X POST http://127.0.0.1:8080/increment
```
Выводит:
```
{"error": "storage_unavailable"}
```

Команда:
```
curl -fsS http://127.0.0.1:8080/
```
Выводит:
```
{"error": "storage_unavailable"}
```


# Проверка 3: Redis возвращается

Команда:
```
docker compose start redis
```
Выводит:
```
[+] start 1/1
 ✔ Container aleksandrmatveev_hw_3-redis-1 Started
```

Команда (ждём, пока Redis снова станет `healthy`):
```
docker compose ps
```
Выводит (приложение не перезапускалось: оно работает с прошлого запуска, а Redis поднят всего 3 секунды назад):
```
NAME                            IMAGE                       COMMAND                  SERVICE   CREATED              STATUS                        PORTS
aleksandrmatveev_hw_3-app-1     aleksandrmatveev_hw_3-app   "python -u app.py"       app       About a minute ago   Up About a minute (healthy)   127.0.0.1:8080->8000/tcp
aleksandrmatveev_hw_3-redis-1   redis:7.4-alpine            "docker-entrypoint.s…"   redis     About a minute ago   Up 3 seconds (healthy)        6379/tcp
```

Команда:
```
curl -fsS http://127.0.0.1:8080/readyz
```
Выводит:
```
{"status": "ready", "storage": "redis"}
```

Команда (приложение без перезапуска снова отдаёт `count = 3`, `hostname` тот же):
```
curl -fsS http://127.0.0.1:8080/
```
Выводит:
```
{"greeting": "Привет из DOCKER", "count": 3, "hostname": "6f22512cbdfc", "storage": "redis"}
```

Команда (следующий POST даёт `count + 1 = 4`):
```
curl -fsS -X POST http://127.0.0.1:8080/increment
```
Выводит:
```
{"greeting": "Привет из DOCKER", "count": 4, "hostname": "6f22512cbdfc", "storage": "redis"}
```

# Логи приложения

Команда:
```
docker compose logs app
```
Выводит (строки `GET /healthz` с адреса `127.0.0.1` это проверки здоровья от самого Docker каждые 5 секунд; запросы с `172.18.0.1` это запросы с хоста):
```
app-1  | 2026-11-22 17:13:28,323 listening port=8000 storage=redis
app-1  | 2026-11-22 17:13:33,184 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:13:34,609 http 172.18.0.1 "GET / HTTP/1.1" 200 -
app-1  | 2026-11-22 17:13:38,345 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:13:46,213 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:13:46,434 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:13:51,578 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:13:56,724 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:13:57,050 http 172.18.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:01,893 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:07,021 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:10,561 storage_unavailable: ConnectionError
app-1  | 2026-11-22 17:14:10,562 http 172.18.0.1 "GET /readyz HTTP/1.1" 503 -
app-1  | 2026-11-22 17:14:09,857 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:15,011 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:20,150 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:22,219 storage_unavailable: ConnectionError
app-1  | 2026-11-22 17:14:22,219 http 172.18.0.1 "POST /increment HTTP/1.1" 503 -
app-1  | 2026-11-22 17:14:25,287 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:30,459 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:35,605 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:35,756 storage_unavailable: ConnectionError
app-1  | 2026-11-22 17:14:35,757 http 172.18.0.1 "GET / HTTP/1.1" 503 -
app-1  | 2026-11-22 17:14:38,453 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:43,606 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:48,772 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:50,909 http 172.18.0.1 "GET /readyz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:53,960 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:55,858 http 172.18.0.1 "GET / HTTP/1.1" 200 -
app-1  | 2026-11-22 17:14:59,108 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
app-1  | 2026-11-22 17:15:00,420 http 172.18.0.1 "POST /increment HTTP/1.1" 200 -
app-1  | 2026-11-22 17:15:04,286 http 127.0.0.1 "GET /healthz HTTP/1.1" 200 -
```