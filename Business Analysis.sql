use internal;

select count(distinct account_id) AS Total_Customers
from ravenstack_accounts;

select count(distinct account_id) AS Active_Customers
from ravenstack_subscriptions
where churn_flag = FALSE;

select count(distinct account_id) AS Churned_Customers
from ravenstack_churn_events;

select
round(sum(mrr_amount),2) AS Total_MRR
from ravenstack_subscriptions
where churn_flag = FALSE;

select
round(sum(arr_amount),2) AS Total_ARR
from ravenstack_subscriptions
where churn_flag = FALSE;

select
round(
sum(mrr_amount)/count(distinct account_id),2
) AS ARPU
from ravenstack_subscriptions
where churn_flag = FALSE;

select
count(distinct account_id) AS Trial_Customer
from ravenstack_subscriptions
where is_trial = 'TRUE';

select count(*) AS Auto_Renew_Subscriptions
from ravenstack_subscriptions
where auto_renew_flag = 'TRUE';

SELECT
SUM(CASE WHEN upgrade_flag = 'TRUE' THEN 1 ELSE 0 END) AS Upgrades,
SUM(CASE WHEN downgrade_flag = 'TRUE' THEN 1 ELSE 0 END) AS Downgrades
FROM ravenstack_subscriptions;

select round(
(
select count(distinct account_id)
from ravenstack_churn_events
)
/
(
select count(distinct account_id)
from ravenstack_accounts
)
*100,2
) AS Churn_Rate_Percentage;

/* Revenue Analysis */
SELECT
    plan_tier,
    COUNT(*) AS Total_Subscriptions,
    SUM(mrr_amount) AS Total_MRR,
    SUM(arr_amount) AS Total_ARR
FROM ravenstack_subscriptions
WHERE churn_flag = 'FALSE'
GROUP BY plan_tier
ORDER BY Total_MRR DESC;

SELECT
    billing_frequency,
    COUNT(*) AS Total_Subscriptions,
    SUM(mrr_amount) AS Total_MRR,
    SUM(arr_amount) AS Total_ARR
FROM ravenstack_subscriptions
WHERE churn_flag = 'FALSE'
GROUP BY billing_frequency;

SELECT
    a.industry,
    COUNT(DISTINCT s.account_id) AS Customers,
    SUM(s.mrr_amount) AS Total_MRR,
    SUM(s.arr_amount) AS Total_ARR
FROM ravenstack_accounts a
JOIN ravenstack_subscriptions s
ON a.account_id = s.account_id
WHERE s.churn_flag = 'FALSE'
GROUP BY a.industry
ORDER BY Total_MRR DESC;

SELECT
    a.country,
    COUNT(DISTINCT s.account_id) AS Customers,
    SUM(s.mrr_amount) AS Total_MRR,
    SUM(s.arr_amount) AS Total_ARR
FROM ravenstack_accounts a
JOIN ravenstack_subscriptions s
ON a.account_id = s.account_id
WHERE s.churn_flag = 'FALSE'
GROUP BY a.country
ORDER BY Total_MRR DESC;

/* Churn Analysis*/
SELECT
    reason_code,
    COUNT(*) AS Churn_Count
FROM ravenstack_churn_events
GROUP BY reason_code
ORDER BY Churn_Count DESC;

SELECT
    s.plan_tier,
    COUNT(DISTINCT c.account_id) AS Churned_Customers
FROM ravenstack_churn_events c
JOIN ravenstack_subscriptions s
ON c.account_id = s.account_id
GROUP BY s.plan_tier
ORDER BY Churned_Customers DESC;

SELECT
    a.industry,
    COUNT(DISTINCT c.account_id) AS Churned_Customers
FROM ravenstack_churn_events c
JOIN ravenstack_accounts a
ON c.account_id = a.account_id
GROUP BY a.industry
ORDER BY Churned_Customers DESC;

SELECT
    a.country,
    COUNT(DISTINCT c.account_id) AS Churned_Customers
FROM ravenstack_churn_events c
JOIN ravenstack_accounts a
ON c.account_id = a.account_id
GROUP BY a.country
ORDER BY Churned_Customers DESC;

SELECT
    reason_code,
    COUNT(*) AS Churn_Count,
    SUM(refund_amount_usd) AS Total_Refund
FROM ravenstack_churn_events
GROUP BY reason_code
ORDER BY Total_Refund DESC;

SELECT
    COUNT(*) AS Reactivated_Customers
FROM ravenstack_churn_events
WHERE is_reactivation = 'TRUE';

SELECT
    COUNT(*) AS Upgraded_Before_Churn
FROM ravenstack_churn_events
WHERE preceding_upgrade_flag = 'TRUE';

SELECT
    COUNT(*) AS Downgraded_Before_Churn
FROM ravenstack_churn_events
WHERE preceding_downgrade_flag = 'TRUE';

/* Feature Usage Analysis */
SELECT
    feature_name,
    SUM(usage_count) AS Total_Usage
FROM ravenstack_feature_usage
GROUP BY feature_name
ORDER BY Total_Usage DESC;

SELECT
    feature_name,
    ROUND(AVG(usage_count),2) AS Average_Usage
FROM ravenstack_feature_usage
GROUP BY feature_name
ORDER BY Average_Usage DESC;

SELECT
    feature_name,
    ROUND(AVG(usage_duration_secs),2) AS Avg_Duration_Seconds
FROM ravenstack_feature_usage
GROUP BY feature_name
ORDER BY Avg_Duration_Seconds DESC;

SELECT
    feature_name,
    SUM(error_count) AS Total_Errors
FROM ravenstack_feature_usage
GROUP BY feature_name
ORDER BY Total_Errors DESC;

SELECT
    is_beta_feature,
    COUNT(*) AS Usage_Records,
    SUM(usage_count) AS Total_Usage
FROM ravenstack_feature_usage
GROUP BY is_beta_feature;

SELECT
    s.plan_tier,
    f.feature_name,
    SUM(f.usage_count) AS Total_Usage
FROM ravenstack_feature_usage f
JOIN ravenstack_subscriptions s
ON f.subscription_id = s.subscription_id
GROUP BY
    s.plan_tier,
    f.feature_name
ORDER BY
    s.plan_tier,
    Total_Usage DESC;

/* Support Ticket Analysis */
SELECT
COUNT(*) AS Total_Tickets
FROM ravenstack_support_tickets;

SELECT
ROUND(AVG(resolution_time_hours),2) AS Avg_Resolution_Time_Hours
FROM ravenstack_support_tickets;

SELECT
ROUND(AVG(first_response_time_minutes),2) AS Avg_First_Response_Minutes
FROM ravenstack_support_tickets;

SELECT
ROUND(
AVG(CAST(satisfaction_score AS DECIMAL(2,1))),
2
) AS Avg_Satisfaction
FROM ravenstack_support_tickets
WHERE TRIM(satisfaction_score)<>'';

SELECT
priority,
COUNT(*) AS Total_Tickets
FROM ravenstack_support_tickets
GROUP BY priority
ORDER BY Total_Tickets DESC;

SELECT
escalation_flag,
COUNT(*) AS Total_Tickets
FROM ravenstack_support_tickets
GROUP BY escalation_flag;

SELECT
priority,
ROUND(AVG(resolution_time_hours),2) AS Avg_Resolution_Time
FROM ravenstack_support_tickets
GROUP BY priority
ORDER BY Avg_Resolution_Time DESC;

SELECT
a.country,
COUNT(*) AS Total_Tickets
FROM ravenstack_support_tickets t
JOIN ravenstack_accounts a
ON t.account_id = a.account_id
GROUP BY a.country
ORDER BY Total_Tickets DESC;

SELECT
a.industry,
COUNT(*) AS Total_Tickets
FROM ravenstack_support_tickets t
JOIN ravenstack_accounts a
ON t.account_id = a.account_id
GROUP BY a.industry
ORDER BY Total_Tickets DESC;

SELECT
priority,
ROUND(
AVG(CAST(satisfaction_score AS DECIMAL(2,1))),
2
) AS Avg_Satisfaction
FROM ravenstack_support_tickets
WHERE TRIM(satisfaction_score)<>''
GROUP BY priority
ORDER BY Avg_Satisfaction DESC;

SELECT
    churn_flag,
    COUNT(*) AS Count
FROM ravenstack_subscriptions
GROUP BY churn_flag;
