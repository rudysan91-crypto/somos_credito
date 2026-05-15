--CONSULTAS SQL
--el codigo debera traer unicamente los creditos que tengan dias de atraso, se utiliza el having para delimitar esa condicion
SELECT TOP 10
    p.credito_id,
    SUM(
        CASE 
            WHEN p.fecha_pago IS NOT NULL 
                 AND p.fecha_pago > p.fecha_vencimiento
                THEN DATEDIFF(DAY, p.fecha_vencimiento, p.fecha_pago)

            WHEN p.fecha_pago IS NULL 
                 AND p.estado_cuota = 'vencida'
                THEN DATEDIFF(DAY, p.fecha_vencimiento, CAST(GETDATE() AS DATE))

            ELSE 0
        END
    ) AS atraso_acumulado_dias
FROM dbo.pagos p
GROUP BY p.credito_id
HAVING 
    SUM(
        CASE 
            WHEN p.fecha_pago IS NOT NULL 
                 AND p.fecha_pago > p.fecha_vencimiento
                THEN DATEDIFF(DAY, p.fecha_vencimiento, p.fecha_pago)

            WHEN p.fecha_pago IS NULL 
                 AND p.estado_cuota = 'vencida'
                THEN DATEDIFF(DAY, p.fecha_vencimiento, CAST(GETDATE() AS DATE))

            ELSE 0
        END
    ) > 0
ORDER BY atraso_acumulado_dias DESC;

--TASA DE MORA
SELECT
    YEAR(fecha_desembolso) AS anio,
    MONTH(fecha_desembolso) AS mes,
    COUNT(*) AS total_desembolsados,
    SUM(CASE WHEN estado = 'mora' THEN 1 ELSE 0 END) AS creditos_en_mora,
    SUM(CASE WHEN estado = 'mora' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS tasa_mora_porcentaje
FROM dbo.creditos
GROUP BY 
    YEAR(fecha_desembolso),
    MONTH(fecha_desembolso)
ORDER BY 
    anio,
    mes;


--LISTADO DE CLIENTES QUE PAGARON EN DESORDEN SU CREDITO

SELECT
    p_mayor.credito_id,
    p_mayor.cuota_numero AS cuota_pagada_antes,
    p_mayor.fecha_pago AS fecha_pago_cuota_mayor,
    p_menor.cuota_numero AS cuota_anterior_pagada_despues,
    p_menor.fecha_pago AS fecha_pago_cuota_menor
FROM dbo.pagos p_mayor
JOIN dbo.pagos p_menor
    ON p_mayor.credito_id = p_menor.credito_id
WHERE p_mayor.cuota_numero > p_menor.cuota_numero
  AND p_mayor.fecha_pago IS NOT NULL
  AND p_menor.fecha_pago IS NOT NULL
  AND p_mayor.fecha_pago < p_menor.fecha_pago
ORDER BY 
    p_mayor.credito_id,
    p_mayor.cuota_numero;

