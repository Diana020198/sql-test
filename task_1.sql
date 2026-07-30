SELECT
    u.id,
    u.username,
    STRING_AGG(DISTINCT ur.role, ', ') AS roles,
    COUNT(ua.id) AS activity_count
FROM users u
LEFT JOIN user_roles ur
    ON u.id = ur.user_id
LEFT JOIN user_activity ua
    ON u.id = ua.user_id
    AND ua.activity_date >= CURRENT_DATE - INTERVAL '1 month'
GROUP BY
    u.id,
    u.username
HAVING COUNT(ua.id) > 0
ORDER BY activity_count DESC;
