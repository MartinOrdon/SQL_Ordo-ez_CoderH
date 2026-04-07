DROP DATABASE IF EXISTS fondo_inversiones;
CREATE DATABASE fondo_inversiones;
USE fondo_inversiones;

CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    tipo_cliente VARCHAR(20) NOT NULL,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    razon_social VARCHAR(150),
    documento_identificacion VARCHAR(30) NOT NULL UNIQUE,
    email VARCHAR(120) NOT NULL UNIQUE,
    telefono VARCHAR(30),
    pais_residencia VARCHAR(80) NOT NULL,
    fecha_alta DATE NOT NULL,
    estado_cliente VARCHAR(20) NOT NULL
);

CREATE TABLE monedas (
    id_moneda INT AUTO_INCREMENT PRIMARY KEY,
    codigo_moneda VARCHAR(10) NOT NULL UNIQUE,
    nombre_moneda VARCHAR(50) NOT NULL,
    simbolo VARCHAR(10),
    pais_referencia VARCHAR(80),
    estado_moneda VARCHAR(20) NOT NULL
);

CREATE TABLE sectores (
    id_sector INT AUTO_INCREMENT PRIMARY KEY,
    nombre_sector VARCHAR(100) NOT NULL UNIQUE,
    descripcion_sector VARCHAR(255)
);

CREATE TABLE empresas (
    id_empresa INT AUTO_INCREMENT PRIMARY KEY,
    nombre_empresa VARCHAR(150) NOT NULL,
    id_sector INT NOT NULL,
    pais_operacion VARCHAR(80) NOT NULL,
    tipo_empresa VARCHAR(50),
    fecha_fundacion DATE,
    estado_empresa VARCHAR(20) NOT NULL,
    INDEX idx_empresas_id_sector (id_sector),
    CONSTRAINT fk_empresas_sector
        FOREIGN KEY (id_sector)
        REFERENCES sectores(id_sector)
);

CREATE TABLE inversiones (
    id_inversion INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_empresa INT NOT NULL,
    id_moneda INT NOT NULL,
    fecha_inversion DATE NOT NULL,
    monto_inicial DECIMAL(18,2) NOT NULL,
    tipo_inversion VARCHAR(50) NOT NULL,
    plazo_meses INT,
    rentabilidad_esperada DECIMAL(5,2),
    estado_inversion VARCHAR(20) NOT NULL,
    observaciones VARCHAR(255),
    INDEX idx_inversiones_id_cliente (id_cliente),
    INDEX idx_inversiones_id_empresa (id_empresa),
    INDEX idx_inversiones_id_moneda (id_moneda),
    CONSTRAINT fk_inversiones_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente),
    CONSTRAINT fk_inversiones_empresa
        FOREIGN KEY (id_empresa)
        REFERENCES empresas(id_empresa),
    CONSTRAINT fk_inversiones_moneda
        FOREIGN KEY (id_moneda)
        REFERENCES monedas(id_moneda)
);

CREATE TABLE movimientos (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_inversion INT NOT NULL,
    fecha_movimiento DATE NOT NULL,
    tipo_movimiento VARCHAR(50) NOT NULL,
    monto_movimiento DECIMAL(18,2) NOT NULL,
    descripcion_movimiento VARCHAR(255),
    saldo_posterior DECIMAL(18,2),
    INDEX idx_movimientos_id_inversion (id_inversion),
    CONSTRAINT fk_movimientos_inversion
        FOREIGN KEY (id_inversion)
        REFERENCES inversiones(id_inversion)
);

CREATE VIEW vw_inversiones_detalladas AS
SELECT
    i.id_inversion,
    i.fecha_inversion,
    i.monto_inicial,
    i.tipo_inversion,
    i.plazo_meses,
    i.rentabilidad_esperada,
    i.estado_inversion,
    i.observaciones,
    c.id_cliente,
    c.tipo_cliente,
    c.nombre,
    c.apellido,
    c.razon_social,
    c.documento_identificacion,
    c.email,
    e.id_empresa,
    e.nombre_empresa,
    e.pais_operacion,
    e.tipo_empresa,
    s.id_sector,
    s.nombre_sector,
    m.id_moneda,
    m.codigo_moneda,
    m.nombre_moneda,
    m.simbolo
FROM inversiones i
INNER JOIN clientes c ON i.id_cliente = c.id_cliente
INNER JOIN empresas e ON i.id_empresa = e.id_empresa
INNER JOIN sectores s ON e.id_sector = s.id_sector
INNER JOIN monedas m ON i.id_moneda = m.id_moneda;

CREATE VIEW vw_inversiones_activas AS
SELECT
    i.id_inversion,
    i.fecha_inversion,
    i.monto_inicial,
    i.tipo_inversion,
    i.estado_inversion,
    c.id_cliente,
    c.nombre,
    c.apellido,
    c.razon_social,
    e.id_empresa,
    e.nombre_empresa,
    m.codigo_moneda,
    m.nombre_moneda
FROM inversiones i
INNER JOIN clientes c ON i.id_cliente = c.id_cliente
INNER JOIN empresas e ON i.id_empresa = e.id_empresa
INNER JOIN monedas m ON i.id_moneda = m.id_moneda
WHERE i.estado_inversion = 'activa';

CREATE VIEW vw_movimientos_por_inversion AS
SELECT
    mv.id_movimiento,
    mv.fecha_movimiento,
    mv.tipo_movimiento,
    mv.monto_movimiento,
    mv.descripcion_movimiento,
    mv.saldo_posterior,
    i.id_inversion,
    i.fecha_inversion,
    i.monto_inicial,
    i.estado_inversion,
    c.id_cliente,
    c.nombre,
    c.apellido,
    c.razon_social,
    e.id_empresa,
    e.nombre_empresa
FROM movimientos mv
INNER JOIN inversiones i ON mv.id_inversion = i.id_inversion
INNER JOIN clientes c ON i.id_cliente = c.id_cliente
INNER JOIN empresas e ON i.id_empresa = e.id_empresa;

DELIMITER $$

CREATE FUNCTION fn_total_invertido_cliente(p_id_cliente INT)
RETURNS DECIMAL(18,2)
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(18,2);

    SELECT COALESCE(SUM(monto_inicial), 0)
    INTO v_total
    FROM inversiones
    WHERE id_cliente = p_id_cliente;

    RETURN v_total;
END $$

CREATE FUNCTION fn_cantidad_movimientos_inversion(p_id_inversion INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_cantidad INT;

    SELECT COUNT(*)
    INTO v_cantidad
    FROM movimientos
    WHERE id_inversion = p_id_inversion;

    RETURN v_cantidad;
END $$

CREATE PROCEDURE sp_insertar_inversion(
    IN p_id_cliente INT,
    IN p_id_empresa INT,
    IN p_id_moneda INT,
    IN p_fecha_inversion DATE,
    IN p_monto_inicial DECIMAL(18,2),
    IN p_tipo_inversion VARCHAR(50),
    IN p_plazo_meses INT,
    IN p_rentabilidad_esperada DECIMAL(5,2),
    IN p_estado_inversion VARCHAR(20),
    IN p_observaciones VARCHAR(255)
)
BEGIN
    INSERT INTO inversiones (
        id_cliente,
        id_empresa,
        id_moneda,
        fecha_inversion,
        monto_inicial,
        tipo_inversion,
        plazo_meses,
        rentabilidad_esperada,
        estado_inversion,
        observaciones
    )
    VALUES (
        p_id_cliente,
        p_id_empresa,
        p_id_moneda,
        p_fecha_inversion,
        p_monto_inicial,
        p_tipo_inversion,
        p_plazo_meses,
        p_rentabilidad_esperada,
        p_estado_inversion,
        p_observaciones
    );
END $$

CREATE PROCEDURE sp_registrar_movimiento(
    IN p_id_inversion INT,
    IN p_fecha_movimiento DATE,
    IN p_tipo_movimiento VARCHAR(50),
    IN p_monto_movimiento DECIMAL(18,2),
    IN p_descripcion_movimiento VARCHAR(255),
    IN p_saldo_posterior DECIMAL(18,2)
)
BEGIN
    INSERT INTO movimientos (
        id_inversion,
        fecha_movimiento,
        tipo_movimiento,
        monto_movimiento,
        descripcion_movimiento,
        saldo_posterior
    )
    VALUES (
        p_id_inversion,
        p_fecha_movimiento,
        p_tipo_movimiento,
        p_monto_movimiento,
        p_descripcion_movimiento,
        p_saldo_posterior
    );
END $$

CREATE PROCEDURE sp_listar_inversiones_cliente(
    IN p_id_cliente INT
)
BEGIN
    SELECT
        i.id_inversion,
        i.fecha_inversion,
        i.monto_inicial,
        i.tipo_inversion,
        i.estado_inversion,
        e.nombre_empresa,
        s.nombre_sector,
        m.codigo_moneda,
        m.nombre_moneda
    FROM inversiones i
    INNER JOIN empresas e ON i.id_empresa = e.id_empresa
    INNER JOIN sectores s ON e.id_sector = s.id_sector
    INNER JOIN monedas m ON i.id_moneda = m.id_moneda
    WHERE i.id_cliente = p_id_cliente
    ORDER BY i.fecha_inversion, i.id_inversion;
END $$

CREATE TRIGGER tr_insert_movimiento_inicial_inversion
AFTER INSERT ON inversiones
FOR EACH ROW
BEGIN
    INSERT INTO movimientos (
        id_inversion,
        fecha_movimiento,
        tipo_movimiento,
        monto_movimiento,
        descripcion_movimiento,
        saldo_posterior
    )
    VALUES (
        NEW.id_inversion,
        NEW.fecha_inversion,
        'aporte inicial',
        NEW.monto_inicial,
        'Movimiento generado automaticamente al crear la inversion',
        NEW.monto_inicial
    );
END $$

DELIMITER ;

INSERT INTO clientes (
    tipo_cliente,
    nombre,
    apellido,
    razon_social,
    documento_identificacion,
    email,
    telefono,
    pais_residencia,
    fecha_alta,
    estado_cliente
) VALUES
('persona fisica', 'Juan', 'Perez', NULL, 'DNI30111222', 'juan.perez@email.com', '+54 11 5555 1111', 'Argentina', '2025-01-15', 'activo'),
('persona fisica', 'Maria', 'Lopez', NULL, 'DNI28999888', 'maria.lopez@email.com', '+54 11 5555 2222', 'Argentina', '2025-02-10', 'activo'),
('persona juridica', NULL, NULL, 'Inversora Delta SA', 'CUIT30711222334', 'contacto@deltasa.com', '+54 11 5555 3333', 'Argentina', '2025-03-01', 'activo'),
('persona juridica', NULL, NULL, 'Patagonia Capital SRL', 'CUIT30722333445', 'info@patagoniacapital.com', '+54 11 5555 4444', 'Uruguay', '2025-04-20', 'activo');

INSERT INTO monedas (
    codigo_moneda,
    nombre_moneda,
    simbolo,
    pais_referencia,
    estado_moneda
) VALUES
('USD', 'Dolar estadounidense', '$', 'Estados Unidos', 'activa'),
('EUR', 'Euro', '€', 'Union Europea', 'activa'),
('GBP', 'Libra esterlina', '£', 'Reino Unido', 'activa');

INSERT INTO sectores (
    nombre_sector,
    descripcion_sector
) VALUES
('Energetico', 'Empresas vinculadas a generacion, distribucion y servicios energeticos'),
('Inmobiliario', 'Empresas vinculadas a desarrollos, construccion y administracion inmobiliaria');

INSERT INTO empresas (
    nombre_empresa,
    id_sector,
    pais_operacion,
    tipo_empresa,
    fecha_fundacion,
    estado_empresa
) VALUES
('Energia del Sur SA', 1, 'Argentina', 'privada', '2010-06-15', 'activa'),
('Solar Grid Latam', 1, 'Chile', 'privada', '2016-09-20', 'activa'),
('Desarrollos Urbanos BA', 2, 'Argentina', 'privada', '2012-03-08', 'activa'),
('Real Estate Andino', 2, 'Uruguay', 'holding', '2018-11-12', 'activa');

INSERT INTO inversiones (
    id_cliente,
    id_empresa,
    id_moneda,
    fecha_inversion,
    monto_inicial,
    tipo_inversion,
    plazo_meses,
    rentabilidad_esperada,
    estado_inversion,
    observaciones
) VALUES
(1, 1, 1, '2026-01-10', 100000.00, 'aporte de capital', 24, 12.50, 'activa', 'Inversion inicial en empresa energetica'),
(1, 3, 2, '2026-01-25', 60000.00, 'participacion', 18, 10.00, 'activa', 'Inversion diversificada en desarrollo inmobiliario'),
(2, 2, 1, '2026-02-05', 85000.00, 'bono privado', 12, 9.50, 'activa', 'Colocacion de corto plazo'),
(3, 4, 3, '2026-02-20', 150000.00, 'aporte de capital', 36, 14.00, 'cerrada', 'Inversion corporativa en real estate'),
(4, 1, 1, '2026-03-03', 120000.00, 'participacion', 24, 11.75, 'activa', 'Ingreso institucional al sector energetico');

CALL sp_insertar_inversion(
    2,
    4,
    2,
    '2026-03-18',
    75000.00,
    'aporte de capital',
    24,
    13.00,
    'activa',
    'Inversion registrada mediante stored procedure'
);

INSERT INTO movimientos (
    id_inversion,
    fecha_movimiento,
    tipo_movimiento,
    monto_movimiento,
    descripcion_movimiento,
    saldo_posterior
) VALUES
(1, '2026-02-15', 'aporte adicional', 25000.00, 'Aporte extraordinario del cliente', 125000.00),
(1, '2026-03-10', 'retiro parcial', 10000.00, 'Retiro parcial de utilidades', 115000.00),
(2, '2026-03-05', 'aporte adicional', 15000.00, 'Refuerzo de posicion en proyecto inmobiliario', 75000.00),
(3, '2026-03-22', 'ajuste', 5000.00, 'Ajuste por reexpresion de posicion', 90000.00),
(4, '2026-04-01', 'retiro parcial', 20000.00, 'Distribucion parcial de retorno', 130000.00),
(5, '2026-04-08', 'aporte adicional', 30000.00, 'Ampliacion de participacion institucional', 150000.00);

CALL sp_registrar_movimiento(
    6,
    '2026-04-10',
    'aporte adicional',
    5000.00,
    'Aporte registrado mediante stored procedure',
    80000.00
);

SELECT * FROM vw_inversiones_detalladas;
SELECT * FROM vw_inversiones_activas;
SELECT * FROM vw_movimientos_por_inversion;

SELECT fn_total_invertido_cliente(1) AS total_invertido_cliente_1;
SELECT fn_cantidad_movimientos_inversion(1) AS cantidad_movimientos_inversion_1;

CALL sp_listar_inversiones_cliente(1);