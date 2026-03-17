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