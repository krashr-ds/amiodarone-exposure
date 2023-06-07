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
        visit_occurrence_id as occurrence_id,
		visit_start_datetime AS vstart,
        visit_end_datetime AS vend,
        subtime(visit_end_datetime, visit_start_datetime) AS vduration,
        visit_occurrence_id as id, 
        provider_id as vprovider,
        care_site_id as care_site
FROM exposed_patients INNER JOIN visit_occurrence 
	ON exposed_patients.person_id = visit_occurrence.person_id
    AND exposed_patients.treatment_start >= vdate
UNION
SELECT 
		exposed_patients.patient_id as patient_id,
		exposed_patients.treatment_start as treatment_start,
        exposed_patients.treatment_period as treatment_period,
        "PROCEDURE" as vtype, 
        procedure_occurrence_id as occurrence_id,
		procedure_date as vstart,
        NULL as vend,
        NULL as vduration,
        procedure_occurrence_id as id, 
        provider_id as vprovider,
        care_site_id as care_site
FROM exposed_patients INNER JOIN procedure_occurrence
	ON exposed_patients.person_id = procedure_occurrence.person_id
    AND exposed_patients.treatment_start >= vdate
ORDER BY vstart ASC

