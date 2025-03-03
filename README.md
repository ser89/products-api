# API Fudo

API RESTful para gestión de productos y autenticación de usuarios, construida con Ruby y Rack.

## 🚀 Características

- Autenticación de usuarios
- Gestión de productos
- Operaciones asíncronas
- Thread-safe con Concurrent Ruby
- Documentación OpenAPI/Swagger
- Manejo de sesiones
- Encriptación de contraseñas con BCrypt

## 📋 Requisitos

- Ruby 3.2.2
- Bundler

## 🛠️ Instalación

### Opción 1: Local

1. Clonar el repositorio
    ```bash
    git clone https://github.com/ser89/products-api
    cd products-api
    ```
2. Instalar dependencias
    ```bash
    bundle install
    ```
3. Iniciar el servidor
    ```bash
    bundle exec rakeup -p 3000
    ```

### Opción 2: Docker

1. Clonar el repositorio
    ```bash
    git clone https://github.com/ser89/products-api
    cd products-api
    ```
2. Construir e iniciar los contenedores
    ```bash
    docker-compose up api --build
    ```

## 🔑 Usuario por Defecto

Al iniciar la aplicación por primera vez, se crea un usuario administrador:
- Username: `admin`
- Password: `password123`

## 📚 Documentación API

La documentación completa de la API está disponible en formato [OpenAPI/Swagger](http://localhost:3000/openapi.yml)

### Endpoints Principales

#### Usuarios
- `POST /users/sign_up` - Registro de usuario
- `POST /users/sign_in` - Inicio de sesión
- `DELETE /users/sign_out` - Cierre de sesión

#### Productos
- `GET /products` - Listar productos
- `POST /products` - Crear producto (asíncrono)
- `GET /products/:id` - Obtener producto
- `DELETE /products/:id` - Eliminar producto

#### Documentación
- `GET /openapi.yml` - Documentación OpenAPI
- `GET /AUTHORS` - Autores

## 🏗️ Estructura del Proyecto
```tree
├── app/
│ ├── controllers/
│ │ ├── products_controller.rb
│ │ └── users_controller.rb
│ ├── middlewares/
│ │ └── authentication.rb
│ └── repositories/
│ │ ├──  product_repository.rb
│ │ └── user_repository.rb
│ └── services/
│   └── product_creator.rb
├── config/
│ ├── initializers/
│ │ └── seeds.rb
│ └── routes.rb
├── lib/
│ └── formatters/
│   └──response_formatter.rb
├── public/
│ ├── AUTHORS
│ └── openapi.yml
├── Dockerfile
├── docker-compose.yml
├── config.ru
├── Gemfile
└── README.md
```

## 🔒 Seguridad

- Autenticación basada en sesiones
- Contraseñas encriptadas con BCrypt
- Middleware de autenticación para rutas protegidas
- Validación de datos de entrada
- Manejo seguro de errores

## 🧪 Testing

Para ejecutar los tests:

### Opción 1: Local

```bash
bundle exec rspec
```

### Opción 2: Docker

```bash
docker-compose run tests
```

## 📝 Características Técnicas

- **Concurrencia**: Uso de `Concurrent::Map` y `Concurrent::AtomicFixnum` para operaciones thread-safe
- **Repositorios**: Patrón Repository para abstracción de datos
- **Formatters**: Formateo consistente de respuestas JSON
- **Middlewares**: Manejo de autenticación y sesiones
- **Services**: Uso de servicios para abstracción de lógica de negocio
- **Validaciones**: Validación de datos de entrada
- **Async**: Uso de `Concurrent::ThreadPoolExecutor` para procesamiento asíncrono
- **Logging**: Logging estructurado con Logger
- **Docker**: Uso de Docker para contenerización y despliegue
- **Tests**: Uso de RSpec para testing (100% de cobertura)
- **Rubocop**: Uso de Rubocop para linting (100% de cobertura)

## ✨ Posibles Mejoras

- [ ] Migrar a una base de datos persistente
- [ ] Implementar versionado de API
- [ ] Implementar autenticación más robusta