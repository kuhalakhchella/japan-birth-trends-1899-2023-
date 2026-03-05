CREATE DATABASE `japanese_birthstatistics`;
USE `japanese_birthstatistics`;

SELECT * FROM `japan_birthstats`;
CREATE TABLE `japan_birthstats_raw` LIKE `japan_birthstats`;
INSERT INTO `japan_birthstats_raw` SELECT * FROM `japan_birthstats`;

SELECT * FROM japan_birth;
CREATE TABLE japan_birth_raw LIKE japan_birth;
INSERT INTO `japan_birth_raw` SELECT * FROM `japan_birth`;


#CHECK DATA TYPE
DESCRIBE japan_birthstats;
ALTER TABLE japan_birthstats MODIFY `year` YEAR;

DESCRIBE `japan_birth`;

#REMOVING COLUMNS NOT NECESSARY FOR ANALYSIS 

CREATE TABLE japan_birth AS
SELECT 
year,
birth_total,
birth_male,
birth_female,
birth_rate,
birth_gender_ratio,
total_fertility_rate,
population_total,
population_male,
population_female
FROM japan_birth;

SELECT * FROM japan_birth;

#CHECKING FOR DUPLICATES 

WITH rownum_stats AS(
	SELECT *, ROW_NUMBER() OVER(
	PARTITION BY `year`, total_births, male_births, 
	female_births, crude_birth_rate, sex_ratio_at_birth, 
	total_fertility_rate) AS rownum FROM 
	japan_birthstats)

SELECT * FROM rownum_stats WHERE rownum>1;
#no duplicates found

WITH rownum_stats1 AS( SELECT *, ROW_NUMBER() OVER(PARTITION BY year, birth_total, birth_male, birth_female, birth_rate,
birth_gender_ratio, total_fertility_rate, population_male ) AS rownum1 FROM japan_birth)
 
 SELECT * FROM rownum_stats1 WHERE rownum1>1;
 
 #no duplicates found


#STANDARDISING DATA 

SELECT MIN(`year`) , MAX(`year`), COUNT(DISTINCT(`year`)) FROM japan_birthstats ORDER BY `year`;

SELECT MIN(`year`), MAX(`year`), COUNT(DISTINCT(`year`)) FROM japan_birth ORDER BY `year`;


SELECT DISTINCT(`year`) FROM japan_birthstats ORDER BY YEAR;

SELECT DISTINCT(`year`) FROM japan_birth ORDER BY YEAR;

#CHECKING FOR NULLS

SELECT 
	SUM(`year` IS NULL) AS year_null,
    SUM(total_births IS NULL) AS totalbirth_null,
    SUM(male_births IS NULL) AS male_birth_null, 
    SUM(female_births IS NULL) AS female_birth_null, 
    SUM(crude_birth_rate IS NULL)AS crude_birth_rate_null, 
    SUM(sex_ratio_at_birth IS NULL) AS sex_ratio_null, 
    SUM(total_fertility_rate IS NULL)AS null_fertiility_rate
FROM japan_birthstats;
    
SELECT * FROM japan_birthstats
WHERE total_fertility_rate IS NULL
ORDER BY year;

SELECT * FROM japan_birth;

SELECT 
	SUM(`year` IS NULL) AS year_null,
    SUM(birth_total IS NULL) AS null_birth_total,
    SUM(birth_male IS NULL) AS null_birth_male, 
    SUM(birth_female IS NULL) AS null_birth_female, 
    SUM(birth_rate IS NULL) AS null_birth_rate,
    SUM(birth_gender_ratio IS NULL) AS null_birth_gender_ratio, 
    SUM(total_fertility_rate IS NULL) AS null_total_fertility_rate,
    SUM(population_total IS NULL) AS null_population_total,
    SUM(population_male IS NULL) AS null_population_nalee,
    SUM(population_female IS NULL) AS null_population_female
FROM 
	japan_birth;

SELECT * FROM japan_birth;
    
UPDATE japan_birth SET birth_total = 2149843 WHERE year=1944;
UPDATE japan_birth SET birth_total = 1685583 WHERE year=1945;
UPDATE japan_birth SET birth_total = 1905809 WHERE year=1946;

ALTER TABLE japan_birth ADD COLUMN data_notes VARCHAR(225);
UPDATE japan_birth SET data_notes= 'reconstructed_estimate_wartime_records_incomplete' WHERE year IN (1944, 1945, 1946);

	
#CONSISTENCY CHECK

SELECT * FROM japan_birthstats;
SELECT * FROM japan_birth;

SELECT year
FROM japan_birthstats
WHERE total_births <> male_births + female_births;

SELECT * FROM japan_birthstats WHERE year=1935;

SELECT year
FROM japan_birth
WHERE birth_total <> birth_male + birth_female;


SELECT YEAR,
	(male_births+female_births) AS sum_of_sex,
    total_births-(male_births+female_births) AS unspecified_sex
FROM japan_birthstats;

SELECT YEAR,
	(birth_male+birth_female) AS sum_of_sex,
    birth_total-(birth_male+birth_female) AS unspecified_sex
FROM japan_birth;

SELECT * FROM japan_birthstats WHERE sex_ratio_at_birth <> ROUND((male_births/female_births*100),1);

SELECT * FROM japan_birth WHERE birth_gender_ratio<> ROUND((birth_male/birth_female*100),1);

SELECT * FROM japan_birthstats WHERE sex_ratio_at_birth<100 OR sex_ratio_at_birth>110;

SELECT * FROM japan_birth WHERE birth_gender_ratio<100 OR birth_gender_ratio>110;

#OUTLIAR DETECTION

SELECT * FROM japan_birthstats;
WITH birthrate_change AS(
SELECT 
year,
total_births,
total_births - LAG(total_births) OVER (ORDER BY year) AS change_birthrate,
LAG(total_births) OVER(ORDER BY year) AS previous_birthrate
FROM japan_birthstats)

SELECT year,CONCAT(ROUND(change_birthrate/previous_birthrate *100,1),"%") AS change_birthrate_percentage FROM 
birthrate_change ORDER BY year;

SELECT * FROM japan_birthstats ORDER BY year;
SELECT * FROM `japan_birth`;









