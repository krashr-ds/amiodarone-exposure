WITH exposed_patients AS (
SELECT person_id as patient_id, 
	   drug_exposure_start_date as treatment_start,
	   DATEDIFF(drug_exposure_end_date, drug_exposure_start_date) as treatment_period
	FROM drug_exposure 
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
)

SELECT ep.patient_id, co.visit_occurrence_id, cc.concept_code as ICD9CODE, cc.concept_name as ICD9_name, 
	   c.concept_name as snomed_name, c.concept_code as snomed_code, c.domain_id, co.condition_start_date, 
       co.condition_end_date
FROM condition_occurrence co INNER JOIN exposed_patients ep
								ON co.person_id = ep.patient_id
							 LEFT JOIN concept c 
								ON co.condition_concept_id = c.concept_id
									LEFT JOIN concept_relationship cr
										ON c.concept_id = cr.concept_id_1
										LEFT JOIN concept cc 
											ON cr.concept_id_2 = cc.concept_id
WHERE c.domain_id IN ('Condition', 'Condition/Procedure')
AND c.vocabulary_id = "SNOMED"
AND cc.vocabulary_id = "ICD9CM"
AND cc.concept_code IN ('508.8', '516.8', '793.19', '786.39', '786.30', '794.2', '794.8', '794.5', '573.8', 
						'V58.69', '245.4', '244.2', '244.3', '242.90', '518.82', '514.0', '518.4', '518.3', 
                        '515.0', '518.89', '136.3', '516.34', '786.0', '786', '514', '515', '786.05', '786.09', 
                        '786.39', '786.52', '786.7', '786.9', '5088', '5168', '79319', '78639', '78630', '7942', 
                        '7948', '7945', '5738', 'V5869', '2454', '2442', '2443', '24290', '51882', '5140', '5184', 
                        '5183', '5150', '51889', '1363', '51634', '7860', '786', '514', '515', '78605', '78609', 
                        '78639', '78652', '7867', '7869')


