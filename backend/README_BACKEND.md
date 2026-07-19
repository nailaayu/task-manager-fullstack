# Backend Task Manager - Naila

Backend ini sudah dilengkapi sesuai kebutuhan praktikum HTTP & API Integration:

- Spring Boot 3.2.5
- REST API `/api/auth` dan `/api/tasks`
- JWT Authentication
- Spring Security
- H2 Database untuk development
- Entity User dan Task
- CRUD Task
- Update status Task
- Search dan filter Task
- Error handling JSON
- CORS untuk Flutter client

## Cara Menjalankan

```bash
./mvnw spring-boot:run
```

Server berjalan di:

```text
http://localhost:8080
```

H2 Console:

```text
http://localhost:8080/h2-console
```

JDBC URL:

```text
jdbc:h2:mem:taskdb
```

Username:

```text
sa
```

Password kosong.

## Endpoint Auth

### Register

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username":"naila",
    "email":"naila@example.com",
    "password":"123456",
    "fullName":"Naila"
  }'
```

### Login

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username":"naila",
    "password":"123456"
  }'
```

Simpan nilai `token` dari response login.

## Endpoint Task

Ganti `TOKEN_KAMU` dengan token dari login.

### Create Task

```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_KAMU" \
  -d '{
    "title":"Belajar Flutter API",
    "description":"Mengerjakan praktikum HTTP API Integration",
    "status":"TODO",
    "category":"WORK",
    "dueDate":"2026-06-30T10:00:00"
  }'
```

### Get All Tasks

```bash
curl -X GET http://localhost:8080/api/tasks \
  -H "Authorization: Bearer TOKEN_KAMU"
```

### Update Task

```bash
curl -X PUT http://localhost:8080/api/tasks/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_KAMU" \
  -d '{
    "title":"Belajar Flutter API Revisi",
    "description":"Update data task",
    "status":"IN_PROGRESS",
    "category":"WORK",
    "dueDate":"2026-06-30T10:00:00"
  }'
```

### Update Status

```bash
curl -X PATCH "http://localhost:8080/api/tasks/1/status?status=DONE" \
  -H "Authorization: Bearer TOKEN_KAMU"
```

### Search Task

```bash
curl -X GET "http://localhost:8080/api/tasks/search?query=Flutter" \
  -H "Authorization: Bearer TOKEN_KAMU"
```

### Filter Status

```bash
curl -X GET "http://localhost:8080/api/tasks/filter/status?status=TODO" \
  -H "Authorization: Bearer TOKEN_KAMU"
```

### Filter Category

```bash
curl -X GET "http://localhost:8080/api/tasks/filter/category?category=WORK" \
  -H "Authorization: Bearer TOKEN_KAMU"
```

### Delete Task

```bash
curl -X DELETE http://localhost:8080/api/tasks/1 \
  -H "Authorization: Bearer TOKEN_KAMU"
```

## Nilai Enum yang Harus Sama dengan Flutter

Status:

```text
TODO
IN_PROGRESS
DONE
```

Category:

```text
WORK
PERSONAL
SHOPPING
HEALTH
OTHER
```
