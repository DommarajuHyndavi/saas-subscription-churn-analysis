USE internal;

-- ===========================================================
-- DATA PROFILING
-- ===========================================================

SELECT COUNT(*) FROM ravenstack_accounts;
SELECT COUNT(*) FROM ravenstack_subscriptions;
SELECT COUNT(*) FROM ravenstack_churn_events;
SELECT COUNT(*) FROM ravenstack_feature_usage;
SELECT COUNT(*) FROM ravenstack_support_tickets;

-- ===========================================================
-- ACCOUNTS TABLE
-- ===========================================================

DESC ravenstack_accounts;

-- Duplicate Check
SELECT account_id, COUNT(*)
FROM ravenstack_accounts
GROUP BY account_id
HAVING COUNT(*) > 1;

-- Missing Values
SELECT *
FROM ravenstack_accounts
WHERE account_id IS NULL
   OR account_name IS NULL
   OR industry IS NULL
   OR country IS NULL
   OR signup_date IS NULL;

-- Negative Seats
SELECT *
FROM ravenstack_accounts
WHERE seats < 0;

-- Distinct Values
SELECT DISTINCT industry
FROM ravenstack_accounts;

SELECT DISTINCT country
FROM ravenstack_accounts;

SELECT DISTINCT referral_source
FROM ravenstack_accounts;

SELECT DISTINCT plan_tier
FROM ravenstack_accounts;

SELECT DISTINCT is_trial
FROM ravenstack_accounts;

SELECT DISTINCT churn_flag
FROM ravenstack_accounts;

-- ===========================================================
-- SUBSCRIPTIONS TABLE
-- ===========================================================

DESC ravenstack_subscriptions;

-- Duplicate Check
SELECT subscription_id, COUNT(*)
FROM ravenstack_subscriptions
GROUP BY subscription_id
HAVING COUNT(*) > 1;

-- Missing Values
SELECT *
FROM ravenstack_subscriptions
WHERE subscription_id IS NULL
   OR account_id IS NULL
   OR start_date IS NULL
   OR plan_tier IS NULL
   OR mrr_amount IS NULL
   OR arr_amount IS NULL;

-- Blank End Dates
SELECT COUNT(*)
FROM ravenstack_subscriptions
WHERE TRIM(end_date) = '';

-- Invalid Date Range
SELECT subscription_id,
       start_date,
       end_date
FROM ravenstack_subscriptions
WHERE end_date IS NOT NULL
AND end_date < start_date;

-- Negative Values
SELECT *
FROM ravenstack_subscriptions
WHERE seats < 0
   OR mrr_amount < 0
   OR arr_amount < 0;

-- Distinct Values
SELECT DISTINCT plan_tier
FROM ravenstack_subscriptions;

SELECT DISTINCT billing_frequency
FROM ravenstack_subscriptions;

SELECT DISTINCT is_trial
FROM ravenstack_subscriptions;

SELECT DISTINCT upgrade_flag
FROM ravenstack_subscriptions;

SELECT DISTINCT downgrade_flag
FROM ravenstack_subscriptions;

SELECT DISTINCT churn_flag
FROM ravenstack_subscriptions;

SELECT DISTINCT auto_renew_flag
FROM ravenstack_subscriptions;

-- Foreign Key Validation
SELECT s.account_id
FROM ravenstack_subscriptions s
LEFT JOIN ravenstack_accounts a
ON s.account_id = a.account_id
WHERE a.account_id IS NULL;

-- ===========================================================
-- DATA CLEANING
-- ===========================================================

ALTER TABLE ravenstack_subscriptions
MODIFY start_date DATE;

ALTER TABLE ravenstack_subscriptions
MODIFY end_date DATE;

-- Validate After Cleaning
DESC ravenstack_subscriptions;

SELECT subscription_id,
       start_date,
       end_date
FROM ravenstack_subscriptions
WHERE end_date IS NOT NULL
AND end_date < start_date;

-- ===========================================================
-- CHURN EVENTS TABLE
-- ===========================================================

DESC ravenstack_churn_events;

-- Duplicate Check
SELECT churn_event_id, COUNT(*)
FROM ravenstack_churn_events
GROUP BY churn_event_id
HAVING COUNT(*) > 1;

-- Missing Values
SELECT *
FROM ravenstack_churn_events
WHERE churn_event_id IS NULL
   OR account_id IS NULL
   OR churn_date IS NULL;

-- Negative Refund
SELECT *
FROM ravenstack_churn_events
WHERE refund_amount_usd < 0;

-- Distinct Churn Reasons
SELECT DISTINCT reason_code
FROM ravenstack_churn_events;

-- Foreign Key Validation
SELECT c.account_id
FROM ravenstack_churn_events c
LEFT JOIN ravenstack_accounts a
ON c.account_id = a.account_id
WHERE a.account_id IS NULL;

-- ===========================================================
-- FEATURE USAGE TABLE
-- ===========================================================

DESC ravenstack_feature_usage;

-- Duplicate usage_id Check
SELECT usage_id, COUNT(*)
FROM ravenstack_feature_usage
GROUP BY usage_id
HAVING COUNT(*) > 1;

-- Check if Complete Duplicate Rows Exist
SELECT
    usage_id,
    subscription_id,
    usage_date,
    feature_name,
    usage_count,
    usage_duration_secs,
    error_count,
    is_beta_feature,
    COUNT(*) AS cnt
FROM ravenstack_feature_usage
GROUP BY
    usage_id,
    subscription_id,
    usage_date,
    feature_name,
    usage_count,
    usage_duration_secs,
    error_count,
    is_beta_feature
HAVING COUNT(*) > 1;

-- Missing Values
SELECT *
FROM ravenstack_feature_usage
WHERE usage_id IS NULL
   OR subscription_id IS NULL
   OR usage_date IS NULL
   OR feature_name IS NULL;

-- Negative Values
SELECT *
FROM ravenstack_feature_usage
WHERE usage_count < 0
   OR usage_duration_secs < 0
   OR error_count < 0;

-- Distinct Values
SELECT DISTINCT is_beta_feature
FROM ravenstack_feature_usage;

-- Foreign Key Validation
SELECT f.subscription_id
FROM ravenstack_feature_usage f
LEFT JOIN ravenstack_subscriptions s
ON f.subscription_id = s.subscription_id
WHERE s.subscription_id IS NULL;

-- ===========================================================
-- SUPPORT TICKETS TABLE
-- ===========================================================

DESC ravenstack_support_tickets;

-- Duplicate Check
SELECT ticket_id, COUNT(*)
FROM ravenstack_support_tickets
GROUP BY ticket_id
HAVING COUNT(*) > 1;

-- Missing Values
SELECT *
FROM ravenstack_support_tickets
WHERE ticket_id IS NULL
   OR account_id IS NULL
   OR submitted_at IS NULL;

-- Negative Resolution Time
SELECT *
FROM ravenstack_support_tickets
WHERE resolution_time_hours < 0;

-- Negative First Response Time
SELECT *
FROM ravenstack_support_tickets
WHERE first_response_time_minutes < 0;

-- Satisfaction Score Values
SELECT DISTINCT satisfaction_score
FROM ravenstack_support_tickets;

-- Invalid Satisfaction Values
SELECT DISTINCT satisfaction_score
FROM ravenstack_support_tickets
WHERE satisfaction_score NOT IN ('1.0','2.0','3.0','4.0','5.0')
AND TRIM(satisfaction_score) <> '';

-- Missing Satisfaction Score
SELECT *
FROM ravenstack_support_tickets
WHERE satisfaction_score IS NULL
OR TRIM(satisfaction_score) = '';

-- Invalid Ticket Dates
SELECT ticket_id,
       submitted_at,
       closed_at
FROM ravenstack_support_tickets
WHERE TRIM(closed_at) <> ''
AND closed_at < submitted_at;

-- Foreign Key Validation
SELECT s.account_id
FROM ravenstack_support_tickets s
LEFT JOIN ravenstack_accounts a
ON s.account_id = a.account_id
WHERE a.account_id IS NULL;

select count(distinct account_id) AS Total_Customers
from ravenstack_accounts;

select distinct churn_flag
from ravenstack_accounts;

select distinct is_trial
from ravenstack_accounts;

select distinct churn_flag
from ravenstack_subscriptions;

select distinct is_trial
from ravenstack_subscriptions;

select distinct auto_renew_flag
from ravenstack_subscriptions;

select distinct upgrade_flag
from ravenstack_subscriptions;

select distinct downgrade_flag
from ravenstack_subscriptions;