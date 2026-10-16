# 🛒 Shoope API

Backend API untuk aplikasi **Shoope** — clone Shopee sederhana yang dibangun dengan Node.js, Express, dan MySQL.

## Prasyarat

Pastikan sudah terinstall:

- [Node.js](https://nodejs.org/) (v18 atau lebih baru)
- [MySQL](https://www.mysql.com/) / [XAMPP](https://www.apachefriends.org/) (untuk MySQL & phpMyAdmin)

## Cara Setup

### 1. Import Database

Buka **phpMyAdmin** (`http://localhost/phpmyadmin`), lalu import file-file berikut secara berurutan:

```
database/schema.sql   → membuat struktur tabel
database/seed.sql     → mengisi data awal (seed)
```

### 2. Copy File Environment

```bash
cp .env.example .env
```

Sesuaikan konfigurasi di `.env` jika diperlukan (misal: password database).

### 3. Install Dependencies

```bash
npm install
```

### 4. Jalankan Server (Development)

```bash
npm run dev
```

### 5. Server Berjalan

Server akan berjalan di:

```
http://localhost:3000
```

---

## API Endpoints

| Method | Path                 | Auth | Deskripsi                     |
| ------ | -------------------- | ---- | ----------------------------- |
| `POST` | `/api/auth/register` | ❌   | Registrasi user baru          |
| `POST` | `/api/auth/login`    | ❌   | Login & mendapat token JWT    |
| `GET`  | `/api/auth/me`       | ✅   | Mendapat data user yang login |
| `GET`  | `/api/health`        | ❌   | Health check server           |

> **Auth** ✅ = memerlukan header `Authorization: Bearer <token>`

---

## Format Response

Semua response menggunakan format standar:

```json
{
  "success": true,
  "message": "Pesan deskriptif",
  "data": { }
}
```

---

## Contoh Request & Response

### POST `/api/auth/register`

Registrasi user baru.

**Request Body:**

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "message": "Registrasi berhasil",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

---

### POST `/api/auth/login`

Login dan mendapatkan token JWT.

**Request Body:**

```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    }
  }
}
```

---

### GET `/api/auth/me`

Mendapatkan data user yang sedang login.

**Request Header:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Data user berhasil diambil",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2024-01-01T00:00:00.000Z"
  }
}
```

---

### GET `/api/health`

Cek status server.

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Server berjalan dengan baik",
  "data": {
    "uptime": 12345,
    "timestamp": "2024-01-01T00:00:00.000Z"
  }
}
```

---

## Tech Stack

| Teknologi      | Kegunaan                        |
| -------------- | ------------------------------- |
| **Node.js**    | Runtime JavaScript              |
| **Express**    | Web framework                   |
| **MySQL**      | Database relasional             |
| **mysql2**     | MySQL driver untuk Node.js      |
| **bcryptjs**   | Hashing password                |
| **jsonwebtoken** | Autentikasi JWT               |
| **dotenv**     | Manajemen environment variable  |
| **cors**       | Cross-Origin Resource Sharing   |
| **nodemon**    | Auto-restart saat development   |
