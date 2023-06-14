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

SELECT 
		ep.patient_id as patient_id,
		ep.treatment_start as drug_treatment_start,
        ep.treatment_period as drug_treatment_period,
        "PROCEDURE" as vtype, 
        p.visit_occurrence_id as visit_id,
        c.concept_name as procedure_name,
        c.concept_code as procedure_code,
        c.vocabulary_id as code_type,
		p.procedure_date as vstart,
        NULL as vend,
        NULL as vduration,
        p.provider_id as vprovider,
        NULL as care_site
FROM procedure_occurrence p INNER JOIN exposed_patients ep
								ON p.person_id = ep.patient_id
							LEFT JOIN concept c 
								ON p.procedure_concept_id = c.concept_id
WHERE p.procedure_date >= ep.treatment_start 
ORDER BY vstart ASC