SELECT *
FROM layoffs;

---- Creating a copy of the table

CREATE TABLE layoff_staging
LIKE layoffs;
select*
FROM 
 
FROM layoff_staging;
INSERT layoff_staging
SELECT *
FROM layoffs;

---- Removing duplicates from the table

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ï»¿company, industry, total_laid_off, percentage_laid_off, 'date') AS row_num
FROM layoff_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ï»¿company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoff_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoff_staging
WHERE ï»¿company = 'Casper';

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ï»¿company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoff_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;


CREATE TABLE `layoff_staging_2` (
  `ï»¿company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM C;

INSERT INTO layoff_staging_2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ï»¿company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS row_num
FROM layoff_staging;

DELETE
FROM layoff_staging_2 
WHERE row_num > 1;

SELECT *
FROM layoff_staging_2;

--- Standardizing the data

SELECT ï»¿company, (TRIM(ï»¿company))
FROM layoff_staging_2;


UPDATE layoff_staging_2
SET ï»¿company = TRIM(ï»¿company);

SELECT *
From layoff_staging_2
where industry like 'Crypto';

UPDATE layoff_staging_2
SET industry = 'Crypto'
WHERE industry Like 'Crypto%';


SELECT DISTINCT COUNTRY, TRIM(TRAILING '.' FROM country)
FROM layoff_staging_2
ORDER BY 1;

UPDATE layoff_staging_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'UNITED STATES%';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y' )
FROM layoff_staging_2;

UPDATE layoff_staging_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y' );


ALTER TABLE layoff_staging_2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoff_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoff_staging_2
SET industry = null
WHERE industry = '';

SELECT *
FROM layoff_staging_2
WHERE INDUSTRY IS NULL
OR industry = '';

SELECT *
FROM layoff_staging_2
where ï»¿company like 'Bally%';



select *
from layoff_staging_2 t1
join layoff_staging_2 t2 
     on t1.ï»¿company = t2.ï»¿company
     AND t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null; 

UPDATE layoff_staging_2 T1
JOIN layoff_staging_2 T2
     ON T1.ï»¿company = T2.ï»¿company
SET T1.industry = T2.industry
WHERE T1.industry is null 
and T2.industry is not null;


---- Exploratory Data Analysis
SELECT *
FROM layoff_staging_2;


SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoff_staging_2;


SELECT *
FROM layoff_staging_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions desc;


SELECT ï»¿company, SUM(total_laid_off)
FROM layoff_staging_2
GROUP BY ï»¿company
ORDER BY 2 desc;


SELECT MIN(`date`), MAX(`date`)
FROM layoff_staging_2;


SELECT industry, SUM(total_laid_off)
FROM layoff_staging_2
GROUP BY industry
ORDER BY 2 desc;


SELECT country, SUM(total_laid_off)
FROM layoff_staging_2
GROUP BY country
ORDER BY 2 desc;


SELECT stage, avg(percentage_laid_off)
FROM layoff_staging_2
GROUP BY stage
ORDER BY 2 desc;


SELECT SUBSTRING(`date`,1,7) AS Month, SUM(total_laid_off)
FROM layoff_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC;


WITH ROLLING_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_off
FROM layoff_staging_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC
)
SELECT `Month`, total_off, SUM(total_off) OVER(ORDER BY `Month`) AS rolling_total
FROM Rolling_Total;


SELECT ï»¿company, SUM(total_laid_off)
FROM layoff_staging_2
GROUP BY ï»¿company
ORDER BY 2 desc;


SELECT ï»¿company, YEAR(`date`), SUM(total_laid_off)
FROM layoff_staging_2
GROUP BY ï»¿company, YEAR(`date`)
ORDER BY 3 DESC;


WITH Company_Year(Company, Years, Total_laid_off) AS
(
SELECT ï»¿company, YEAR(`date`), SUM(total_laid_off)
FROM layoff_staging_2
GROUP BY ï»¿company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER (PARTITION BY Years ORDER BY Total_laid_off desc) AS Ranking 
FROM Company_Year
WHERE Years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE RANKING <=5;

