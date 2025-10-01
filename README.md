# 🚀 Ambiente Docker para Laravel 6.x

Este repositório contém a configuração **Docker** para rodar o projeto **Laravel 6.x**, localizado em `www/rosie`.

Stack utilizada:
- **PHP 7.4 FPM** (com extensões necessárias, Imagick, Xdebug opcional)
- **Composer 2**
- **Node.js 14** (para compilar assets com Laravel Mix)
- **Nginx (Alpine)**
- **MySQL 8**

---

## 📂 Estrutura esperada

```text
seu-projeto/
├─ docker/
│ ├─ nginx/
│ │ └─ default.conf
│ └─ php/
│ └─ conf.d/
│ ├─ custom.ini
│ └─ xdebug.ini
├─ www/
│ └─ rosie/
│ ├─ public/
│ │ └─ index.php
│ ├─ artisan
│ └─ (restante do Laravel)
├─ Dockerfile
└─ docker-compose.yml
```

---

## ⚙️ Como subir o ambiente

### 1. Build e inicialização
```bash
docker compose up -d --build
```

### 2. Instalar dependências do Laravel
```bash
docker exec -it laravel6-app bash -lc "composer install"
```

### 3. Criar .env e gerar chave
```bash
docker exec -it laravel6-app bash -lc "cp -n .env.example .env || true"
docker exec -it laravel6-app bash -lc "php artisan key:generate"
```

### 4. Configurar .env
Edite o arquivo `www/rosie/.env` e ajuste conforme necessário:

```dotenv
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8080

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
```

### 5. Rodar migrations, storage link e limpar caches
```bash
docker exec -it laravel6-app bash -lc "php artisan migrate"
docker exec -it laravel6-app bash -lc "php artisan storage:link"
docker exec -it laravel6-app bash -lc 'php artisan config:clear && php artisan cache:clear && php artisan route:clear && php artisan view:clear'
```

---

## 🌐 Acesso à aplicação

- **Aplicação Laravel**: http://localhost:8080
- **Banco MySQL**: localhost:33060
  - **Usuário**: laravel
  - **Senha**: secret

---

## 🐞 Debug com Xdebug (opcional)

Para habilitar o Xdebug, basta rebuildar o container passando a flag:

```bash
INSTALL_XDEBUG=true docker compose build --no-cache app
docker compose up -d
```

O Xdebug escutará em `host.docker.internal:9003`.

---

## 📝 Comandos úteis

### Entrar no container app:
```bash
docker exec -it laravel6-app bash
```

### Rodar migrations/seeds:
```bash
docker exec -it laravel6-app bash -lc "php artisan migrate --seed"
```

### Compilar assets com Laravel Mix (Node.js):
```bash
docker exec -it laravel6-app bash -lc "npm install && npm run dev"
```

---

## 🗑️ Reset rápido (rebuild + reset banco)

Se quiser limpar tudo (inclusive banco) e subir novamente:

```bash
docker compose down -v
docker compose up -d --build
```