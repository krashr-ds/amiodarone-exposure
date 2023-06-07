SELECT * from concept WHERE LOWER(concept_name) LIKE '%amiodarone%'
AND domain_id = 'Drug'
AND vocabulary_id = 'RxNorm'
AND concept_class_id IN ('Clinical Drug', 'Ingredient')
