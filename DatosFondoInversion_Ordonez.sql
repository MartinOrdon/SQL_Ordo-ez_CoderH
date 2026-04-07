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