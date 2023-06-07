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

SELECT  exposed_patients.patient_id as patient_id,
		exposed_patients.treatment_start as treatment_start,
        exposed_patients.treatment_period as treatment_period,
		"VISIT" as vtype, 
        visit_occurrence.visit_occurrence_id as visit_id,
        concept.concept_name as diagnosis_name,
        concept.concept_code as snomed_code,
        condition_occurrence.condition_source_value as ICD9CODE,
		visit_start_date AS vstart,
        visit_end_date AS vend,
        subdate(visit_end_date, visit_start_date) AS vduration,
        visit_occurrence.provider_id as vprovider,
        care_site_id as care_site
FROM visit_occurrence INNER JOIN exposed_patients 
						ON visit_occurrence.person_id = exposed_patients.patient_id
					  INNER JOIN condition_occurrence
						ON visit_occurrence.visit_occurrence_id = condition_occurrence.visit_occurrence_id
							LEFT JOIN concept
								ON condition_occurrence.condition_concept_id = concept.concept_id
WHERE exposed_patients.treatment_start >= visit_start_date
ORDER BY vstart ASC

