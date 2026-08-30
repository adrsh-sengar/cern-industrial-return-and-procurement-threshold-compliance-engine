-- Creating table for CERN member states and their contribution share
CREATE TABLE member_states (
    state_id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_name      VARCHAR2(50),
    contribution_pct  NUMBER(5,2)
);

-- Creating table for contract awards by country
CREATE TABLE contract_awards (
    award_id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_name      VARCHAR2(50),
    category          VARCHAR2(50),
    award_year        NUMBER,
    award_amount_chf  NUMBER(12,2)
);

-- Creating table for purchase requisitions
CREATE TABLE purchase_requisitions (
    req_id            NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_name     VARCHAR2(100),
    category          VARCHAR2(50),
    req_date          DATE,
    amount_chf        NUMBER(12,2)
);

-- Populating member states with real CERN member states and approximate contribution percentages
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Germany', 20.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('France', 14.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('United Kingdom', 14.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Italy', 10.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Spain', 7.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Netherlands', 5.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Switzerland', 4.50);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Belgium', 3.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Poland', 3.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Sweden', 3.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Austria', 2.50);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Norway', 2.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Denmark', 2.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Finland', 2.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Czech Republic', 1.50);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Portugal', 1.50);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Greece', 1.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Hungary', 1.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('Israel', 1.00);
INSERT INTO member_states (country_name, contribution_pct) VALUES ('India', 2.00);

COMMIT;

-- Populating contract awards with 2000 rows, skewing switzerland and india higher to create a real imbalance to analyze
BEGIN
  FOR i IN 1..2000 LOOP
    INSERT INTO contract_awards (country_name, category, award_year, award_amount_chf)
    VALUES (
      CASE MOD(i,20)
        WHEN 0 THEN 'Germany'
        WHEN 1 THEN 'France'
        WHEN 2 THEN 'United Kingdom'
        WHEN 3 THEN 'Italy'
        WHEN 4 THEN 'Spain'
        WHEN 5 THEN 'Netherlands'
        WHEN 6 THEN 'Switzerland'
        WHEN 7 THEN 'Belgium'
        WHEN 8 THEN 'Poland'
        WHEN 9 THEN 'Sweden'
        WHEN 10 THEN 'Austria'
        WHEN 11 THEN 'Norway'
        WHEN 12 THEN 'Denmark'
        WHEN 13 THEN 'Finland'
        WHEN 14 THEN 'Czech Republic'
        WHEN 15 THEN 'Portugal'
        WHEN 16 THEN 'Greece'
        WHEN 17 THEN 'Hungary'
        WHEN 18 THEN 'Israel'
        ELSE 'India'
      END,
      CASE MOD(i,4)
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Mechanical'
        WHEN 2 THEN 'Software'
        ELSE 'Consumables'
      END,
      2022 + MOD(i,4),
      CASE 
        WHEN MOD(i,20) = 6 THEN ROUND(DBMS_RANDOM.VALUE(50000,150000),2)
        WHEN MOD(i,20) = 19 THEN ROUND(DBMS_RANDOM.VALUE(40000,120000),2)
        ELSE ROUND(DBMS_RANDOM.VALUE(5000,60000),2)
      END
    );
  END LOOP;
  COMMIT;
END;
/

-- Populating purchase requisitions with 1500 rows across routine, mid-tier and high value bands
BEGIN
  FOR i IN 1..1500 LOOP
    INSERT INTO purchase_requisitions (supplier_name, category, req_date, amount_chf)
    VALUES (
      CASE MOD(i,5)
        WHEN 0 THEN 'Alpha Engineering Ltd'
        WHEN 1 THEN 'Nordic Tech Supplies'
        WHEN 2 THEN 'Meridian Components SA'
        WHEN 3 THEN 'Delta Precision GmbH'
        ELSE 'Zenith Industrial Co'
      END,
      CASE MOD(i,4)
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Mechanical'
        WHEN 2 THEN 'Software'
        ELSE 'Consumables'
      END,
      SYSDATE - MOD(i,700),
      CASE MOD(i,10)
        WHEN 0 THEN ROUND(DBMS_RANDOM.VALUE(200001,400000),2)
        WHEN 1 THEN ROUND(DBMS_RANDOM.VALUE(15000,50000),2)
        ELSE ROUND(DBMS_RANDOM.VALUE(500,14999),2)
      END
    );
  END LOOP;
  COMMIT;
END;
/

-- Checking industrial return, comparing each country's award share against its contribution share
SELECT 
  ms.country_name,
  ms.contribution_pct,
  ROUND(NVL(ca.total_awarded,0) / (SELECT SUM(award_amount_chf) FROM contract_awards) * 100, 2) AS award_share_pct,
  ROUND(
    (NVL(ca.total_awarded,0) / (SELECT SUM(award_amount_chf) FROM contract_awards) * 100) 
    - ms.contribution_pct
  , 2) AS return_gap
FROM member_states ms
LEFT JOIN (
  SELECT country_name, SUM(award_amount_chf) AS total_awarded
  FROM contract_awards
  GROUP BY country_name
) ca ON ms.country_name = ca.country_name
ORDER BY return_gap DESC;

-- Checking which tendering procedure each requisition falls under, based on cern's real threshold bands
SELECT 
  req_id,
  supplier_name,
  amount_chf,
  CASE 
    WHEN amount_chf > 200000 THEN 'Competitive tender required'
    WHEN amount_chf BETWEEN 15000 AND 50000 THEN 'Mid-tier approval process'
    ELSE 'Routine purchase'
  END AS procedure_required
FROM purchase_requisitions
ORDER BY amount_chf DESC;

-- Checking the count of requisitions in each threshold band
SELECT 
  CASE 
    WHEN amount_chf > 200000 THEN 'Competitive tender required'
    WHEN amount_chf BETWEEN 15000 AND 50000 THEN 'Mid-tier approval process'
    ELSE 'Routine purchase'
  END AS procedure_required,
  COUNT(*) AS num_requisitions
FROM purchase_requisitions
GROUP BY 
  CASE 
    WHEN amount_chf > 200000 THEN 'Competitive tender required'
    WHEN amount_chf BETWEEN 15000 AND 50000 THEN 'Mid-tier approval process'
    ELSE 'Routine purchase'
  END;

-- Checking for suppliers with many small purchases bunched into one month, a possible sign of splitting a purchase to dodge a threshold
SELECT 
  supplier_name,
  TRUNC(req_date, 'MM') AS req_month,
  COUNT(*) AS num_purchases,
  SUM(amount_chf) AS total_monthly_amount
FROM purchase_requisitions
WHERE amount_chf < 15000
GROUP BY supplier_name, TRUNC(req_date, 'MM')
HAVING COUNT(*) >= 3 AND SUM(amount_chf) > 15000
ORDER BY total_monthly_amount DESC;