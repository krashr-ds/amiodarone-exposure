SELECT DISTINCT(cc.concept_id) as icd9_conceptid, c.concept_name, c.concept_code, c.domain_id, cc.concept_name, cc.concept_code, cc.domain_id, cc.vocabulary_id
FROM concept c, condition_occurrence co, concept cc, concept_relationship cr
WHERE c.domain_id IN ('Condition', 'Condition/Procedure')
AND c.vocabulary_id = "SNOMED"
AND c.concept_id = co.condition_concept_id
AND c.concept_id = cr.concept_id_1
AND cc.concept_id = cr.concept_id_2
AND cc.vocabulary_id = "ICD9CM"
AND cc.concept_code IN ('508.8', '516.8', '793.19', '786.39', '786.30', '794.2', '794.8', '794.5', '573.8', 
						'V58.69', '245.4', '244.2', '244.3', '242.90', '518.82', '514.0', '518.4', '518.3', 
                        '515.0', '518.89', '136.3', '516.34', '786.0', '786', '514', '515', '786.05', '786.09', 
                        '786.39', '786.52', '786.7', '786.9')
ORDER BY cc.concept_code ASC
LIMIT 1000