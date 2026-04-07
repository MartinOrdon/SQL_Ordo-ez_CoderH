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
