-- Задание 1

SELECT
    mo.ID_client,
    ROUND(mo.sum_period / mo.checks_cnt, 2) AS avg_check_period,
    ROUND(mo.sum_period / (
        SELECT COUNT(DISTINCT DATE_FORMAT(t3.date_new, '%Y-%m'))
        FROM transactions t3
        WHERE t3.date_new BETWEEN '2015-06-01' AND '2016-06-01'
    ), 2) AS avg_monthly_purchase,
    mo.operations_cnt AS total_operations
FROM
    ( SELECT
          t.ID_client,
          COUNT(*) AS operations_cnt,
          COUNT(DISTINCT t.Id_check) AS checks_cnt,
          COUNT(DISTINCT DATE_FORMAT(t.date_new, '%Y-%m')) AS active_months,
          SUM(t.Sum_payment) AS sum_period
      FROM transactions t
      WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
      GROUP BY t.ID_client
    ) AS mo
WHERE mo.active_months = (
    SELECT COUNT(DISTINCT DATE_FORMAT(t2.date_new, '%Y-%m'))
    FROM transactions t2
    WHERE t2.date_new BETWEEN '2015-06-01' AND '2016-06-01'
)
ORDER BY mo.ID_client;


-- Задание 2

SELECT
    mo.period AS period,
    ROUND(mo.sum_month / mo.checks_cnt, 2) AS avg_check_month,
    ROUND(mo.operations_cnt / mo.clients_cnt, 2) AS avg_operations_per_client_month,
    mo.clients_cnt  AS active_clients_month,
    ROUND(100.0 * mo.operations_cnt / yt.operations_year, 2)  AS pct_of_year_operations,
    ROUND(100.0 * mo.sum_month / yt.sum_year,2) AS pct_of_year_sum,
    ROUND(100.0 * gp.m_ops / gp.total_ops, 2) AS m_pct_ops,
    ROUND(100.0 * gp.f_ops / gp.total_ops, 2) AS f_pct_ops,
    ROUND(100.0 * gp.na_ops / gp.total_ops, 2) AS na_pct_ops,
    ROUND(100.0 * gp.m_sum  / gp.total_sum, 2)  AS m_pct_spend,
    ROUND(100.0 * gp.f_sum  / gp.total_sum, 2) AS f_pct_spend,
    ROUND(100.0 * gp.na_sum / gp.total_sum, 2) AS na_pct_spend
FROM
    ( SELECT
          DATE_FORMAT(t.date_new, '%Y-%m') AS period,
          COUNT(*) AS operations_cnt,
          COUNT(DISTINCT t.Id_check) AS checks_cnt,
          COUNT(DISTINCT t.ID_client)  AS clients_cnt,
          SUM(t.Sum_payment) AS sum_month
      FROM transactions t
      WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
      GROUP BY DATE_FORMAT(t.date_new, '%Y-%m')
    ) AS mo
CROSS JOIN
    ( SELECT
          SUM(sub.operations_cnt) AS operations_year,
          SUM(sub.sum_month)      AS sum_year
      FROM
          ( SELECT
                DATE_FORMAT(t.date_new, '%Y-%m') AS period,
                COUNT(*) AS operations_cnt,
                SUM(t.Sum_payment) AS sum_month
            FROM transactions t
            WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
            GROUP BY DATE_FORMAT(t.date_new, '%Y-%m')
          ) AS sub
    ) AS yt
JOIN
    ( SELECT
          DATE_FORMAT(t.date_new, '%Y-%m') AS period,
          SUM(CASE WHEN COALESCE(c.Gender, 'NA') = 'M'  THEN 1 ELSE 0 END) AS m_ops,
          SUM(CASE WHEN COALESCE(c.Gender, 'NA') = 'F'  THEN 1 ELSE 0 END) AS f_ops,
          SUM(CASE WHEN COALESCE(c.Gender, 'NA') = 'NA' THEN 1 ELSE 0 END) AS na_ops,
          SUM(CASE WHEN COALESCE(c.Gender, 'NA') = 'M'  THEN t.Sum_payment ELSE 0 END) AS m_sum,
          SUM(CASE WHEN COALESCE(c.Gender, 'NA') = 'F'  THEN t.Sum_payment ELSE 0 END) AS f_sum,
          SUM(CASE WHEN COALESCE(c.Gender, 'NA') = 'NA' THEN t.Sum_payment ELSE 0 END) AS na_sum,
          COUNT(*)            AS total_ops,
          SUM(t.Sum_payment)  AS total_sum
      FROM transactions t
      LEFT JOIN costumers c ON c.Id_client = t.ID_client
      WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
      GROUP BY DATE_FORMAT(t.date_new, '%Y-%m')
    ) AS gp ON gp.period = mo.period
ORDER BY mo.period;


-- Задание 3

SELECT
    ag.age_group,
    ag.quarter,
    ag.sum_amt,
    ag.operations_cnt,
    ag.clients_cnt,
    ROUND(ag.sum_amt / ag.clients_cnt, 2) AS avg_sum_per_client,
    ROUND(ag.operations_cnt / ag.clients_cnt, 2)  AS avg_operations_per_client,
    ROUND(100.0 * ag.sum_amt / qt.sum_quarter, 2) AS pct_sum_of_quarter,
    ROUND(100.0 * ag.operations_cnt / qt.operations_quarter, 2) AS pct_operations_of_quarter
FROM
    ( SELECT
          CASE WHEN c.Age IS NULL THEN 'NA'
               ELSE CONCAT(FLOOR(c.Age / 10) * 10, '-', FLOOR(c.Age / 10) * 10 + 9)
          END AS age_group,
          CASE WHEN TIMESTAMPDIFF(MONTH, '2015-06-01', t.date_new) + 1 <= 3 THEN 1
               WHEN TIMESTAMPDIFF(MONTH, '2015-06-01', t.date_new) + 1 <= 6 THEN 2
               WHEN TIMESTAMPDIFF(MONTH, '2015-06-01', t.date_new) + 1 <= 9 THEN 3
               ELSE 4
          END AS quarter,
          SUM(t.Sum_payment)            AS sum_amt,
          COUNT(*)                      AS operations_cnt,
          COUNT(DISTINCT t.ID_client)   AS clients_cnt
      FROM transactions t
      LEFT JOIN costumers c ON c.Id_client = t.ID_client
      WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
      GROUP BY age_group, quarter
    ) AS ag
JOIN
    ( SELECT
          CASE WHEN TIMESTAMPDIFF(MONTH, '2015-06-01', t.date_new) + 1 <= 3 THEN 1
               WHEN TIMESTAMPDIFF(MONTH, '2015-06-01', t.date_new) + 1 <= 6 THEN 2
               WHEN TIMESTAMPDIFF(MONTH, '2015-06-01', t.date_new) + 1 <= 9 THEN 3
               ELSE 4
          END AS quarter,
          SUM(t.Sum_payment)  AS sum_quarter,
          COUNT(*)            AS operations_quarter
      FROM transactions t
      WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
      GROUP BY quarter
    ) AS qt ON qt.quarter = ag.quarter
ORDER BY ag.quarter, ag.age_group;
