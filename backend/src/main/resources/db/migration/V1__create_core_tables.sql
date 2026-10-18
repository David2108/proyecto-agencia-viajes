CREATE TABLE users
(
    id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name     varchar(120) NOT NULL,
    email         varchar(160) NOT NULL,
    phone         varchar(20),
    password_hash varchar(100) NOT NULL,
    role          varchar(20)  NOT NULL,
    active        boolean      NOT NULL DEFAULT true,
    created_at    timestamptz  NOT NULL DEFAULT now(),

    CONSTRAINT uk_users_email UNIQUE (email),
    CONSTRAINT ck_users_role CHECK ( role IN ('CLIENTE', 'ADMIN') )
);

CREATE TABLE destinations
(
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        varchar(100) NOT NULL,
    country     varchar(80)  NOT NULL,
    description text,
    image_url   varchar(500),
    active      boolean      NOT NULL DEFAULT true,

    CONSTRAINT uk_destinations_name_country UNIQUE (name, country)
);

CREATE TABLE packages
(
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    destination_id bigint         NOT NULL,
    title          varchar(150)   NOT NULL,
    description    text,
    includes       text,
    duration_days  int            NOT NULL,
    base_price     numeric(10, 2) NOT NULL,
    image_url      varchar(500),
    active         boolean        NOT NULL DEFAULT true,
    created_at     timestamptz    NOT NULL DEFAULT now(),

    CONSTRAINT fk_packages_destination FOREIGN KEY (destination_id) REFERENCES destinations (id),
    CONSTRAINT ck_packages_duration_days CHECK ( duration_days > 0 ),
    CONSTRAINT ck_packages_base_price CHECK ( base_price >= 0 )
);

CREATE INDEX ix_packages_destination_id
    ON packages (destination_id);

CREATE TABLE departures
(
    id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    package_id       bigint         NOT NULL,
    start_date       date           NOT NULL,
    price_per_person numeric(10, 2) NOT NULL,
    total_seats      int            NOT NULL,
    reserved_seats   int            NOT NULL DEFAULT 0,
    active           boolean        NOT NULL DEFAULT true,
    version          bigint         NOT NULL DEFAULT 0,

    CONSTRAINT fk_departures_package FOREIGN KEY (package_id) REFERENCES packages (id),
    CONSTRAINT uk_departures_package_date UNIQUE (package_id, start_date),
    CONSTRAINT ck_departures_price CHECK (price_per_person >= 0),
    CONSTRAINT ck_departures_total_seats CHECK (total_seats > 0),
    CONSTRAINT ck_departures_seats CHECK (reserved_seats >= 0 AND reserved_seats <= total_seats)
);

CREATE INDEX ix_departures_start_date ON departures (start_date);

CREATE TABLE reservations
(
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code            varchar(20)    NOT NULL,
    user_id         bigint         NOT NULL,
    departure_id    bigint         NOT NULL,
    status          varchar(20)    NOT NULL,
    passenger_count int            NOT NULL,
    unit_price      numeric(10, 2) NOT NULL,
    total_amount    numeric(10, 2) NOT NULL,
    created_at      timestamptz    NOT NULL DEFAULT now(),
    expires_at      timestamptz    NOT NULL,
    confirmed_at    timestamptz,
    cancelled_at    timestamptz,
    cancelled_by    bigint,
    cancel_reason   varchar(300),
    version         bigint         NOT NULL DEFAULT 0,

    CONSTRAINT fk_reservations_user FOREIGN KEY (user_id) REFERENCES users (id),
    CONSTRAINT fk_reservations_departure FOREIGN KEY (departure_id) REFERENCES departures (id),
    CONSTRAINT fk_reservations_user_cancelled_by FOREIGN KEY (cancelled_by) REFERENCES users (id),
    CONSTRAINT uk_reservations_code UNIQUE (code),
    CONSTRAINT ck_reservations_status CHECK ( status IN ('PENDIENTE', 'CONFIRMADA', 'CANCELADA', 'VENCIDA') ),
    CONSTRAINT ck_reservations_status_cancelled CHECK ( (status = 'CANCELADA') = (cancelled_at IS NOT NULL) ),
    CONSTRAINT ck_reservations_status_confirmed CHECK ( status <> 'CONFIRMADA' OR confirmed_at IS NOT NULL ),
    CONSTRAINT ck_reservations_passenger_count CHECK ( passenger_count >= 1 AND passenger_count <= 8 ),
    CONSTRAINT ck_reservations_expires_at CHECK ( expires_at > created_at ),
    CONSTRAINT ck_reservations_unit_price CHECK ( unit_price >= 0 ),
    CONSTRAINT ck_reservations_calculate_total_amount CHECK ( total_amount = unit_price * passenger_count )
);

CREATE UNIQUE INDEX ux_reservations_active
    ON reservations (user_id, departure_id)
    WHERE status IN ('PENDIENTE', 'CONFIRMADA');

CREATE INDEX ix_reservations_user
    ON reservations (user_id, created_at);

CREATE INDEX ix_reservations_expiry
    ON reservations (status, expires_at);

CREATE INDEX ix_reservations_departure
    ON reservations (departure_id, status);

CREATE TABLE passengers
(
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reservation_id  bigint       NOT NULL,
    full_name       varchar(120) NOT NULL,
    document_number varchar(30)  NOT NULL,

    CONSTRAINT fk_passengers_reservation FOREIGN KEY (reservation_id) REFERENCES reservations (id),
    CONSTRAINT uk_passengers_reservation_document_number UNIQUE (reservation_id, document_number)
);