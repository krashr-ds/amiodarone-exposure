SELECT 
	 DISTINCT( p.person_id ) AS patient_id, 
	 CASE WHEN p.gender_concept_id = 8507 THEN 'Male' ELSE 'Female' END AS gender,
	 CONCAT(p.month_of_birth, "/", p.day_of_birth, "/", p.year_of_birth) as patient_dob,
	 CASE WHEN p.race_concept_id = 8527 THEN 'White' WHEN p.race_concept_id = 8516 THEN 'Black or African American' ELSE 'Unspecified' END AS race,
	 CASE WHEN p.ethnicity_concept_id = 38003564 THEN 'Not Hispanic' ELSE 'Hispanic' END AS ethnicity,
	 location.county AS county,
	 location.state AS state
FROM person p RIGHT JOIN location ON p.location_id = location.location_id RIGHT JOIN condition_occurrence co ON p.person_id = co.person_id 
INNER JOIN concept ON co.condition_concept_id = concept.concept_id 
AND p.person_id IN 
(
	SELECT DISTINCT(person_id) FROM drug_exposure 
	WHERE DATEDIFF(drug_exposure_end_date, drug_exposure_start_date)/30 > 1
	AND drug_concept_id IN 
	(SELECT c.concept_id FROM concept c, concept_relationship cr, concept cc
	WHERE c.invalid_reason != 'U'
	AND c.domain_id = 'Drug'
	AND c.vocabulary_id = 'RxNorm'
	AND LOWER(c.concept_name) LIKE '%amiodarone%'
	AND (c.concept_class_id = 'Clinical Drug' OR c.concept_class_id = 'Branded Drug Form' OR c.concept_class_id = 'Ingredient')
	AND c.concept_id = cr.concept_id_1
	AND cc.concept_id = cr.concept_id_2
	AND cr.relationship_id = 'RxNorm is a')
);