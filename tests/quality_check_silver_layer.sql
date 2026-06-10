-- Data Quality Check for each data groups

-- ==============================================
-- Check for silver.crm_cust_info
-- ==============================================

-- CHECK UNWANTED SPACES
-- EXPECTATION: No Results/No Spaces
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- DATA QUALITY CHECK
-- CHECK Nulls or Duplicates in PK
-- Expectation - No Result
SELECT
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;


-- ==============================================
-- Check for silver.crm_sales_details
-- ==============================================

-- Check for Invalid Date Orders
SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check data consistency: Between Sales, Quantity and Price
-- Sales = Quantity * Price
-- values must not be NULL, zero or negative
SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price;

SELECT * FROM silver.crm_sales_details

-- ==============================================
-- Check for silver.crm_prd_info
-- ==============================================
  
-- Checking for duplicates PK
SELECT
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check unwanted spaces
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check  for NULLS or Negative Number
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check for Invalid Date Order
-- Start Date should be smaller than end date
-- Avoid overlapping dates
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT *
FROM silver.crm_prd_info;

-- ==============================================
-- Check for silver.erp_cust_az12
-- ==============================================

-- Identify Out of Range Dates
-- TOO OLD or DATES IN THE FUTURES
SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate< '1924-01-01' OR bdate > GETDATE()

--Data Standardization & Consistency
SELECT DISTINCT 
gen,
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	 WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	 ELSE 'n/a'
END AS gen
FROM silver.erp_cust_az12;

SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate< '1924-01-01' OR bdate > GETDATE()

SELECT DISTINCT 
gen
FROM silver.erp_cust_az12;

SELECT * FROM silver.erp_cust_az12

-- ==============================================
-- Check for silver.erp_loc_a101
-- ==============================================
  
-- Data Standardization & Consistency
SELECT DISTINCT cntry AS old_cntry,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	 WHEN TRIM(cntry)  IN ('US', 'USA') THEN 'United States'
	 WHEN TRIM(cntry)  = '' OR cntry IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS cntry
FROM silver.erp_loc_a101
ORDER BY cntry

-- Check by replacing - with empty str will help to make easier join for gold level
SELECT
REPLACE(cid, '-', '') cid,
cntry
FROM silver.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN
(SELECT cst_key FROM silver.crm_cust_info);

SELECT * FROM silver.erp_loc_a101

-- ==============================================
-- Check for silver.erp_px_cat_g1v2
-- ==============================================
-- No issues for the data group
-- Check for Unwanted spaces
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance);

-- Data Standardization & Consistency
SELECT DISTINCT
cat,
subcat, 
maintenance
FROM silver.erp_px_cat_g1v2

SELECT * FROM silver.erp_px_cat_g1v2
