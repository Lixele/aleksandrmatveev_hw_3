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
[+] Building 2.3s (13/13) FINISHED
 => [internal] load local bake definitions                                                                         0.0s
 => => reading from stdin 542B                                                                                     0.0s
 => [internal] load build definition from Dockerfile                                                               0.0s
 => => transferring dockerfile: 215B                                                                               0.0s
 => [internal] load metadata for docker.io/library/python:3.13-slim                                                1.8s
 => [internal] load .dockerignore                                                                                  0.0s
 => => transferring context: 2B                                                                                    0.0s
 => [1/6] FROM docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc10  0.0s
 => => resolve docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc10  0.0s
 => [internal] load build context                                                                                  0.0s
 => => transferring context: 127B                                                                                  0.0s
 => CACHED [2/6] WORKDIR /app                                                                                      0.0s
 => CACHED [3/6] COPY app/requirements.txt .                                                                       0.0s
 => CACHED [4/6] RUN pip install -r requirements.txt                                                               0.0s
 => CACHED [5/6] COPY app/ .                                                                                       0.0s
 => CACHED [6/6] RUN mkdir -p /data                                                                                0.0s
 => exporting to image                                                                                             0.1s
 => => exporting layers                                                                                            0.0s
 => => exporting manifest sha256:dcaef10d19904d7f4a9ee183705ddd602629a60bb1bc0084512c8f4a6daebc01                  0.0s
 => => exporting config sha256:1c1107e02ed7b4f31e9fc94e2846c09d92843aac9a33ebe64c80b95abfd6b239                    0.0s
 => => exporting attestation manifest sha256:e403d568ab76fba421bf1cb8cbefa954cbdeaaee84a17d43fba86aa85ea054d5      0.0s
 => => exporting manifest list sha256:01edd04241a920eb1b2fd5ab5f5537abe810afdb4e07383d9de746485c7b4b4e             0.0s
 => => naming to docker.io/library/aleksandrmatveev_hw_3-app:latest                                                0.0s
 => => unpacking to docker.io/library/aleksandrmatveev_hw_3-app:latest                                             0.0s
 => resolving provenance for metadata file                                                                         0.0s
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

Удаление и повторное создание контейнера (без `-v`, чтобы volume остался):
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