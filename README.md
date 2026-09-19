# Tarea 1 – API sobre AdventureWorks

## 1. Introducción
Este proyecto implementa una API REST en Node.js/Express que se comunica con una base
de datos SQL Server (AdventureWorks) por medio de Stored Procedures (y sinónimos sobre
ellos), corriendo SQL Server en un contenedor Docker dentro de WSL (Ubuntu). El objetivo
es demostrar una arquitectura desacoplada entre la aplicación y la base de datos.

## 2. Instalación de los requerimientos (paso a paso)

### 2.1 WSL + Ubuntu
Si no tienes WSL instalado, desde PowerShell (como administrador):
```bash
wsl --install -d Ubuntu-22.04
```

### 2.2 Docker dentro de WSL
Se usó el motor de Docker instalado directamente en Ubuntu (WSL), sin depender de
Docker Desktop:
```bash
sudo apt update
sudo apt install -y docker.io
sudo service docker start
sudo usermod -aG docker $USER
```
Cierra y vuelve a abrir la terminal de WSL para que el cambio de grupo tome efecto.

> Nota: cada vez que reinicies WSL, el servicio de Docker no arranca solo — hay que
> volver a correr `sudo service docker start` antes de usar `docker`.

### 2.3 Levantar SQL Server en un contenedor
```bash
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=TuPassword123!" \
  -p 1433:1433 --name sqlserver \
  -d mcr.microsoft.com/mssql/server:2022-latest
```
Verificar que quedó corriendo:
```bash
docker ps
```

### 2.4 Instalar sqlcmd (cliente de línea de comandos) en WSL
```bash
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt update
sudo ACCEPT_EULA=Y apt install -y mssql-tools18 unixodbc-dev
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc
```

### 2.4.1 Extensión SQL Server (mssql) en VS Code
Para crear los Stored Procedures y sinónimos de forma visual, se usó la extensión
**SQL Server (mssql)** de Microsoft en VS Code (conectado en modo remoto WSL):
1. Instalar la extensión `ms-mssql.mssql` desde el marketplace de VS Code.
2. Conectarse con `Ctrl+Shift+P` → "MS SQL: Connect": server `localhost`, autenticación SQL Login, usuario `sa`, tu contraseña, base de datos `AdventureWorks`, y "Trust server certificate" activado (necesario porque el contenedor no tiene certificado válido).

### 2.5 Descargar y restaurar AdventureWorks
El backup se descarga **fuera** del repositorio (pesa ~200MB y no debe subirse a Git):
```bash
wget https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2022.bak
```
Copiarlo dentro del contenedor:
```bash
docker cp AdventureWorks2022.bak sqlserver:/var/opt/mssql/data/
```
Revisar los nombres lógicos del backup (necesarios para el `RESTORE`):
```bash
sqlcmd -S localhost -U sa -P 'TuPassword123!' -C -Q "RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/data/AdventureWorks2022.bak'"
```
Restaurar la base de datos con los nombres lógicos obtenidos (`AdventureWorks2022` y
`AdventureWorks2022_log`):
```bash
sqlcmd -S localhost -U sa -P 'TuPassword123!' -C -Q "
RESTORE DATABASE AdventureWorks
FROM DISK = '/var/opt/mssql/data/AdventureWorks2022.bak'
WITH MOVE 'AdventureWorks2022' TO '/var/opt/mssql/data/AdventureWorks.mdf',
     MOVE 'AdventureWorks2022_log' TO '/var/opt/mssql/data/AdventureWorks.ldf'"
```
Verificar:
```bash
sqlcmd -S localhost -U sa -P 'TuPassword123!' -C -Q "SELECT name FROM sys.databases"
sqlcmd -S localhost -U sa -P 'TuPassword123!' -C -d AdventureWorks -Q "SELECT TOP 5 * FROM Production.Product"
```

### 2.6 Crear los Stored Procedures
Usando la extensión **SQL Server (mssql)** de VS Code:
1. Conéctate al servidor (`Ctrl+Shift+P` → "MS SQL: Connect", con `localhost`, usuario `sa`, tu contraseña, y "Trust server certificate" activado).
2. Abre el archivo `sql/procedures.sql` en VS Code.
3. Selecciona todo el contenido (`Ctrl+A`) y ejecuta con **"Execute Query"** (`Ctrl+Shift+E`) o clic derecho → "Execute Query".

Esto crea los 5 SP directamente sobre la base de datos conectada.

Verificar (puedes usar el árbol de la conexión, expandiendo `AdventureWorks → Programmability → Stored Procedures`, o correr una query rápida en un nuevo archivo `.sql`):
```sql
SELECT name FROM sys.procedures WHERE name LIKE 'sp_%';
```

### 2.7 Crear los sinónimos sobre los Stored Procedures
Como capa extra de abstracción entre la API y los nombres reales de los SP. Igual que
en el paso anterior, con la extensión mssql:
1. Abre `sql/synonyms.sql` en VS Code (ya conectado a `AdventureWorks`).
2. Selecciona todo (`Ctrl+A`) y ejecuta con **"Execute Query"**.

Verificar (en el árbol de la conexión, carpeta `Synonyms` de la base de datos, o con una query):
```sql
SELECT name, base_object_name FROM sys.synonyms;
```

| Sinónimo  | Stored Procedure              |
|-----------|--------------------------------|
| `syn_gp`  | `sp_GetProducts`               |
| `syn_gpc` | `sp_GetProductsWithCategory`   |
| `syn_ip`  | `sp_InsertProduct`             |
| `syn_up`  | `sp_UpdateProduct`             |
| `syn_dp`  | `sp_DeleteProduct`             |

### 2.8 Instalar Node.js y dependencias
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
npm install
```

## 3. Configuración de los servicios
1. Copiar el archivo de variables de entorno y completar la contraseña real:
   ```bash
   cp env.example .env
   ```
2. Levantar la API:
   ```bash
   npm start
   ```
   Por defecto queda disponible en `http://localhost:3000`.

## 4. Datos de prueba

Probado con Postman (Web + Desktop Agent) y `curl`.

**GET /api/products**
```json
[
  { "ProductID": 1, "Name": "Adjustable Race", "ProductNumber": "AR-5381", "ListPrice": 0.0 }
]
```

**GET /api/products/with-category**
```json
[
  { "ProductID": 680, "Name": "HL Road Frame - Black, 58", "ListPrice": 1059.31, "Subcategory": "Road Frames" }
]
```

**POST /api/products**
```json
{ "name": "Test Product", "productNumber": "TP-0001", "listPrice": 25.5, "subcategoryId": 1 }
```

**PUT /api/products/:id**
```json
{ "name": "Test Product Updated", "listPrice": 30.0 }
```

**DELETE /api/products/:id**
Elimina el producto con ese ProductID.

## 5. Video de prueba
[Enlace al video de YouTube](https://youtu.be/JnrlYXf62N0)
