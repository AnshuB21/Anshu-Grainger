# Products app

A small full-stack web application for creating and listing products.

## Tech stack

- React and Vite
- Java 21 and Spring Boot
- Spring Data JPA and Flyway
- PostgreSQL

## Prerequisites

- Java 21
- Node.js 22 or newer
- PostgreSQL running on port `5432`
- IntelliJ IDEA (optional)

Docker is not required.

## Database setup

Create the local database once with these values:

| Setting | Value |
| --- | --- |
| Database | `products` |
| Username | `products` |
| Password | `products` |
| Port | `5432` |

On this PC, PostgreSQL 17 and the database are already configured. Spring Boot runs the Flyway migration automatically and creates the `products` table.

To use different database credentials, set `DB_URL`, `DB_USER`, and `DB_PASSWORD` before starting the backend.

## Run the complete web app

On Windows, double-click `RUN-ME.bat` in the project folder. It starts the Spring Boot API and React development server, then opens the app in your browser:

```text
http://127.0.0.1:3000
```

From PowerShell, the equivalent command is:

```powershell
.\start-app.ps1
```

To stop both servers, double-click `STOP-APP.bat` or run:

```powershell
.\stop-app.ps1
```

## Run locally in IntelliJ

1. Open the project folder in IntelliJ.
2. Allow IntelliJ to import `backend/pom.xml` as a Maven project.
3. Confirm the Project SDK is Java 21.
4. Open `backend/src/main/java/com/example/products/ProductsApiApplication.java`.
5. Click the green Run triangle beside `main`.
6. Open IntelliJ's Terminal and start the web frontend:

```powershell
cd frontend
npm install
npm run dev
```

7. Open `http://127.0.0.1:3000` in a browser.

Do not run `RUN-ME.bat` at the same time as the IntelliJ backend. Both use port `8080`.

## Run locally from terminals

Start the Spring Boot backend from one PowerShell terminal:

```powershell
cd backend
.\mvnw.cmd spring-boot:run
```

Start React from a second terminal:

```powershell
cd frontend
npm install
npm run dev
```

The services are available at:

- Web UI: `http://127.0.0.1:3000`
- REST API: `http://127.0.0.1:8080/api/products`

## API

List products:

```http
GET /api/products
```

Create a product:

```http
POST /api/products
Content-Type: application/json

{"name":"P1"}
```

## Tests and build

Run the backend tests:

```powershell
cd backend
.\mvnw.cmd test
```

Check the frontend production build:

```powershell
cd frontend
npm install
npm run build
```

## Troubleshooting

If Spring Boot says port `8080` is already in use, stop the existing copy with `STOP-APP.bat`, then click Run in IntelliJ again.

This PC needs `TomcatConfiguration` to select Tomcat's NIO2 connector because its default Windows Java selector fails during startup. The application otherwise runs as a standard Spring Boot app.

## How I built it

- Kept the data model intentionally small: an auto-generated `id` and required product `name`.
- Implemented only the requested create and list operations.
- Used Spring Data JPA for persistence and Flyway for repeatable database setup.
- Used a Vite proxy so the React app can call `/api/products` during local development.
- Added focused controller tests plus simple Windows start and stop scripts for the demo.
- With more time, I would add integration tests, structured API error responses, and CI.
