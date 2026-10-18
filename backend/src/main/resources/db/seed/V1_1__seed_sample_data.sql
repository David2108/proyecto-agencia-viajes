-- V1_1__seed_sample_data.sql
-- Datos de ejemplo para desarrollo: 1 administrador, 2 clientes,
-- 5 destinos, 10 paquetes y 20 salidas. Sin reservas (reserved_seats = 0).
--
-- Contraseñas (en texto plano SOLO aquí y en el README, para poder entrar):
--   admin@agencia.test       -> Admin123!
--   ana.torres@mail.test     -> Cliente123!
--   luis.mora@mail.test      -> Cliente123!

-- ---------------------------------------------------------------------------
-- Usuarios
-- ---------------------------------------------------------------------------
INSERT INTO users (full_name, email, phone, password_hash, role)
VALUES ('Administradora Agencia', 'admin@agencia.test', '0990000001',
        '$2a$10$AvMf23RFgGzn9DvarP9E1OA0CsD0g52VzLaTLcJpM8Kj5m2G4Ic4G', 'ADMIN'),
       ('Ana Torres', 'ana.torres@mail.test', '0990000002',
        '$2a$10$nsWTogMfejV5ss8HlUvy1OIRsVF5RUWK9DA3sNkfpXKuZZiiMq.uW', 'CLIENTE'),
       ('Luis Mora', 'luis.mora@mail.test', '0990000003',
        '$2a$10$nsWTogMfejV5ss8HlUvy1OIRsVF5RUWK9DA3sNkfpXKuZZiiMq.uW', 'CLIENTE');

-- ---------------------------------------------------------------------------
-- Destinos
-- ---------------------------------------------------------------------------
INSERT INTO destinations (name, country, description)
VALUES ('Galápagos', 'Ecuador', 'Islas volcánicas con fauna que no existe en ningún otro lugar.'),
       ('Cusco', 'Perú', 'Antigua capital inca y puerta de entrada a Machu Picchu.'),
       ('Cartagena', 'Colombia', 'Ciudad amurallada en el Caribe, con playas e islas cercanas.'),
       ('Buenos Aires', 'Argentina', 'Capital del tango, la gastronomía y la vida nocturna.'),
       ('Cancún', 'México', 'Playas de arena blanca y zonas arqueológicas mayas.');

-- ---------------------------------------------------------------------------
-- Paquetes (2 por destino). El destino se resuelve por (name, country),
-- que es único, así no dependemos de ids fijos.
-- ---------------------------------------------------------------------------
INSERT INTO packages (destination_id, title, description, includes, duration_days, base_price, active)
SELECT d.id, v.title, v.description, v.includes, v.duration_days, v.base_price, v.active
FROM (VALUES
          ('Galápagos', 'Ecuador', 'Galápagos esencial 5 días',
           'Recorrido por Santa Cruz e Isabela.', 'Vuelo Quito-Baltra, hotel, desayunos, tours diarios', 5, 1200.00, true),
          ('Galápagos', 'Ecuador', 'Crucero Galápagos 8 días',
           'Crucero por las islas del centro y el sur.', 'Camarote doble, pensión completa, guía naturalista', 8, 2900.00, true),
          ('Cusco', 'Perú', 'Cusco y Machu Picchu 4 días',
           'Ciudad de Cusco y visita a Machu Picchu.', 'Hotel, tren a Aguas Calientes, entradas, guía', 4, 850.00, true),
          ('Cusco', 'Perú', 'Valle Sagrado completo 6 días',
           'Pisac, Ollantaytambo, Moray y Machu Picchu.', 'Hotel, traslados, entradas, almuerzos', 6, 1100.00, true),
          ('Cartagena', 'Colombia', 'Cartagena colonial 4 días',
           'Centro histórico y fortalezas.', 'Hotel en el centro, desayunos, city tour', 4, 600.00, true),
          ('Cartagena', 'Colombia', 'Islas del Rosario 5 días',
           'Cartagena más dos noches en las islas.', 'Hoteles, lancha, pensión completa en las islas', 5, 780.00, true),
          ('Buenos Aires', 'Argentina', 'Buenos Aires clásico 5 días',
           'Barrios, tango y gastronomía porteña.', 'Hotel, desayunos, cena show de tango', 5, 950.00, true),
          ('Buenos Aires', 'Argentina', 'Buenos Aires y Patagonia 7 días',
           'Buenos Aires y glaciares en El Calafate.', 'Hoteles, vuelo interno, excursión al Perito Moreno', 7, 1800.00, false),
          ('Cancún', 'México', 'Cancún todo incluido 5 días',
           'Resort frente al mar.', 'Hotel todo incluido, traslados aeropuerto', 5, 1300.00, true),
          ('Cancún', 'México', 'Chichén Itzá exprés 3 días',
           'Cancún y la zona arqueológica de Chichén Itzá.', 'Hotel, excursión con guía, almuerzo', 3, 450.00, true)
     ) AS v(dest_name, dest_country, title, description, includes, duration_days, base_price, active)
         JOIN destinations d ON d.name = v.dest_name AND d.country = v.dest_country;

-- ---------------------------------------------------------------------------
-- Salidas (2 por paquete). Fechas relativas al día en que se aplica la
-- migración, para que el catálogo no quede vacío con el tiempo.
-- Casos de prueba incluidos a propósito:
--   * +2 días        -> no se puede reservar (RN-03, menos de 3 días)
--   * +3 días        -> justo en el límite de RN-03
--   * -10 días       -> salida pasada (RF-08, RN-03)
--   * total_seats 1  -> concurrencia (prueba de aceptación 2, RN-02)
--   * total_seats 2  -> "solo quedan 2 cupos" (prueba de aceptación 3)
--   * paquete inactivo con salidas futuras -> no debe salir en el catálogo (RF-08)
-- ---------------------------------------------------------------------------
INSERT INTO departures (package_id, start_date, price_per_person, total_seats)
SELECT p.id, CURRENT_DATE + v.days_from_today, v.price_per_person, v.total_seats
FROM (VALUES
          ('Galápagos esencial 5 días',        2,   1250.00, 12),
          ('Galápagos esencial 5 días',        30,  1200.00, 12),
          ('Crucero Galápagos 8 días',         45,  2900.00, 16),
          ('Crucero Galápagos 8 días',         90,  3100.00, 16),
          ('Cusco y Machu Picchu 4 días',      -10, 850.00,  20),
          ('Cusco y Machu Picchu 4 días',      20,  880.00,  20),
          ('Valle Sagrado completo 6 días',    60,  1100.00, 15),
          ('Valle Sagrado completo 6 días',    120, 1150.00, 15),
          ('Cartagena colonial 4 días',        15,  600.00,  10),
          ('Cartagena colonial 4 días',        40,  620.00,  1),
          ('Islas del Rosario 5 días',         25,  780.00,  8),
          ('Islas del Rosario 5 días',         75,  800.00,  8),
          ('Buenos Aires clásico 5 días',      35,  950.00,  25),
          ('Buenos Aires clásico 5 días',      65,  990.00,  25),
          ('Buenos Aires y Patagonia 7 días',  50,  1800.00, 12),
          ('Buenos Aires y Patagonia 7 días',  100, 1850.00, 12),
          ('Cancún todo incluido 5 días',      3,   1300.00, 30),
          ('Cancún todo incluido 5 días',      10,  1350.00, 30),
          ('Chichén Itzá exprés 3 días',       18,  450.00,  10),
          ('Chichén Itzá exprés 3 días',       28,  470.00,  2)
     ) AS v(package_title, days_from_today, price_per_person, total_seats)
         JOIN packages p ON p.title = v.package_title;