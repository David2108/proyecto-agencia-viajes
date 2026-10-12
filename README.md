# Proyecto Agencia de Viajes

Sistema de reservas para una agencia de viajes que vende paquetes turísticos con salidas en fechas fijas y cupo limitado. El problema central es no vender nunca más cupos de los que hay, aunque dos personas reserven al mismo instante.

Es un proyecto de práctica que crece por fases, siguiendo la ruta Java de DevTalles.

## Stack Fase #1

| Tema | Decisión |
| --- | --- |
| Backend | API REST con Java 21 y Spring Boot 4, en capas: controlador, servicio, repositorio |
| Base de datos | Solo PostgreSQL, con Spring Data JPA |
| Seguridad | Spring Security con JWT, BCrypt, roles CLIENTE y ADMIN |
| Entrada y salida | DTOs en todos los endpoints; mapeo con MapStruct |
| Errores | Formato único con ProblemDetail y códigos HTTP correctos |
| Documentación | OpenAPI (Swagger) con login por token |
| Frontend | React |
| Entorno | Docker Compose levanta API y base con un comando |
| Migración Base de Datos | Flyway para las migraciones, en lugar de `ddl-auto`. |
| Testing | Testcontainers para las pruebas de integración contra PostgreSQL real. |
| CI/CD | GitHub Actions para compilar y correr pruebas en cada push. |

## Estado

Fase 1 de 5, paso 2 de 20 completado. El plan está en la [documentación](docs/proyecto-agencia-viajes.md). 

## Instrucciones para levantar proyecto

Pendiente (paso 3).

## Pruebas de aceptación
1. [ ] Me registro, inicio sesión y reservo 2 pasajeros en una salida con cupo. Veo la reserva Pendiente, con código y total correcto.
2. [ ] En una salida con 1 cupo, dos clientes reservan al mismo tiempo. Solo queda una reserva y el otro recibe un mensaje claro.
3. [ ] Intento reservar 3 pasajeros donde quedan 2 cupos. El sistema lo rechaza y dice cuántos quedan.
4. [ ] Cancelo una reserva y el cupo vuelve a estar disponible.
5. [ ] Como administrador confirmo una reserva. El cliente la ve Confirmada.
6. [ ] Una reserva Pendiente de más de 48 horas aparece como Vencida y su cupo queda libre.
7. [ ] Cambio el precio de una salida. Las reservas anteriores conservan su total.
8. [ ] Un cliente no puede ver la reserva de otro ni entrar a las pantallas de administración.
9. [ ] Intento borrar un paquete con reservas. El sistema no lo permite y ofrece desactivarlo.
10. [ ] Filtro el catálogo por destino, precio y fechas, y los resultados son correctos.
11. [ ] Los números del resumen coinciden con la lista de reservas.
12. [ ] El proyecto se levanta con un comando siguiendo el README, Swagger abre y las pruebas pasan.
