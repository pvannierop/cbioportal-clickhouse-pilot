# sample
DROP VIEW IF EXISTS view_sample;
CREATE VIEW view_sample AS
SELECT
    concat(cs.CANCER_STUDY_IDENTIFIER, '_', sample.STABLE_ID) as sample_unique_id,
    sample.STABLE_ID as sample_stable_id,
    concat(cs.CANCER_STUDY_IDENTIFIER, '_', p.STABLE_ID) as patient_unique_id,
    p.STABLE_ID as patient_stable_id,
    cs.CANCER_STUDY_IDENTIFIER as cancer_study_identifier
FROM sample
         INNER JOIN patient p on sample.PATIENT_ID = p.INTERNAL_ID
         INNER JOIN cancer_study cs on p.CANCER_STUDY_ID = cs.CANCER_STUDY_ID;

# sample list
DROP VIEW IF EXISTS view_sample_list;
CREATE VIEW view_sample_list AS
SELECT
    concat(cs.CANCER_STUDY_IDENTIFIER, '_', s.STABLE_ID) as sample_unique_id,
    sl.STABLE_ID as sample_list_stable_id,
    sl.NAME as name,
    cs.CANCER_STUDY_IDENTIFIER as cancer_study_identifier
FROM sample_list as sl
         INNER JOIN sample_list_list as sll ON sll.LIST_ID = sl.LIST_ID
         INNER JOIN sample as s ON s.INTERNAL_ID = sll.SAMPLE_ID
         INNER JOIN cancer_study cs on sl.CANCER_STUDY_ID = cs.CANCER_STUDY_ID;

# genomic_event
DROP TABLE IF EXISTS view_genomic_event;
-- This view takes a long time to materialize. I store the data in a table to prevent repeated recalculations.
# CREATE TABLE view_genomic_event AS
# SELECT
#     concat(cs.CANCER_STUDY_IDENTIFIER, '_', sample.STABLE_ID) as sample_unique_id,
#     gene.HUGO_GENE_SYMBOL as hugo_gene_symbol,
#     me.PROTEIN_CHANGE as variant,
#     gp.STABLE_ID as gene_panel_stable_id,
#     cs.CANCER_STUDY_IDENTIFIER as cancer_study_identifier,
#     g.STABLE_ID as genetic_profile_stable_id
# FROM mutation
#          LEFT JOIN mutation_event as me ON mutation.MUTATION_EVENT_ID = me.MUTATION_EVENT_ID
#          LEFT JOIN sample_profile sp on mutation.SAMPLE_ID = sp.SAMPLE_ID and mutation.GENETIC_PROFILE_ID = sp.GENETIC_PROFILE_ID
#          LEFT JOIN gene_panel gp on sp.PANEL_ID = gp.INTERNAL_ID
#          LEFT JOIN genetic_profile g on sp.GENETIC_PROFILE_ID = g.GENETIC_PROFILE_ID
#          LEFT JOIN cancer_study cs on g.CANCER_STUDY_ID = cs.CANCER_STUDY_ID
#          LEFT JOIN sample on mutation.SAMPLE_ID = sample.INTERNAL_ID
#          LEFT JOIN gene ON mutation.ENTREZ_GENE_ID = gene.ENTREZ_GENE_ID;
# INSERT INTO view_genomic_event
# SELECT
#     concat(cs.CANCER_STUDY_IDENTIFIER, '_', sample.STABLE_ID) as sample_unique_id,
#     gene.HUGO_GENE_SYMBOL as hugo_gene_symbol,
#     convert(ce.ALTERATION, char) as variant,
#     gene_panel.STABLE_ID as gene_panel_stable_id,
#     cs.CANCER_STUDY_IDENTIFIER as cancer_study_identifier,
#     gp.STABLE_ID as genetic_profile_stable_id
# FROM sample_cna_event
#          LEFT JOIN cna_event ce on sample_cna_event.CNA_EVENT_ID = ce.CNA_EVENT_ID
#          LEFT JOIN gene on ce.ENTREZ_GENE_ID = gene.ENTREZ_GENE_ID
#          LEFT JOIN genetic_profile gp on sample_cna_event.GENETIC_PROFILE_ID = gp.GENETIC_PROFILE_ID
#          LEFT JOIN sample_profile sp on gp.GENETIC_PROFILE_ID = sp.GENETIC_PROFILE_ID
#          LEFT JOIN cancer_study cs on gp.CANCER_STUDY_ID = cs.CANCER_STUDY_ID
#          LEFT JOIN sample on sample_cna_event.SAMPLE_ID = sample.INTERNAL_ID
#          LEFT JOIN gene_panel ON sp.PANEL_ID = gene_panel.INTERNAL_ID;
# INSERT INTO view_genomic_event
# SELECT
#     concat(cs.CANCER_STUDY_IDENTIFIER, '_', s.STABLE_ID) as sample_unique_id,
#     hugo_gene_symbol,
#     Event_Info as variant,
#     g.STABLE_ID as gene_panel_stable_id,
#     cs.CANCER_STUDY_IDENTIFIER as cancer_study_identifier,
#     gp.STABLE_ID as genetic_profile_stable_id
# FROM structural_variant as sv
#          LEFT JOIN (SELECT ENTREZ_GENE_ID, HUGO_GENE_SYMBOL as hugo_gene_symbol FROM gene) gene1 on gene1.ENTREZ_GENE_ID = sv.SITE1_ENTREZ_GENE_ID
#          LEFT OUTER JOIN genetic_profile gp on gp.GENETIC_PROFILE_ID = sv.GENETIC_PROFILE_ID
#          LEFT JOIN sample s on sv.SAMPLE_ID = s.INTERNAL_ID
#          LEFT JOIN cancer_study cs on gp.CANCER_STUDY_ID = cs.CANCER_STUDY_ID
#          LEFT JOIN sample_profile sp on gp.GENETIC_PROFILE_ID = sp.GENETIC_PROFILE_ID
#          LEFT JOIN gene_panel g on sp.PANEL_ID = g.INTERNAL_ID;
# INSERT INTO view_genomic_event
# SELECT
#     concat(cs.CANCER_STUDY_IDENTIFIER, '_', s.STABLE_ID) as sample_unique_id,
#     hugo_gene_symbol,
#     Event_Info as variant,
#     g.STABLE_ID as gene_panel_stable_id,
#     cs.CANCER_STUDY_IDENTIFIER as cancer_study_identifier,
#     gp.STABLE_ID as genetic_profile_stable_id
# FROM structural_variant as sv
#          LEFT JOIN (SELECT ENTREZ_GENE_ID, HUGO_GENE_SYMBOL as hugo_gene_symbol FROM gene) gene2 on gene2.ENTREZ_GENE_ID = sv.SITE2_ENTREZ_GENE_ID
#          LEFT OUTER JOIN genetic_profile gp on gp.GENETIC_PROFILE_ID = sv.GENETIC_PROFILE_ID
#          LEFT JOIN sample s on sv.SAMPLE_ID = s.INTERNAL_ID
#          LEFT JOIN cancer_study cs on gp.CANCER_STUDY_ID = cs.CANCER_STUDY_ID
#          LEFT JOIN sample_profile sp on gp.GENETIC_PROFILE_ID = sp.GENETIC_PROFILE_ID
#          LEFT JOIN gene_panel g on sp.PANEL_ID = g.INTERNAL_ID;

-- structural variant
DROP VIEW IF EXISTS view_structural_variant;
CREATE VIEW view_structural_variant AS
SELECT
    concat(cs.CANCER_STUDY_IDENTIFIER, '_', s.STABLE_ID) as sample_unique_id,
    gene1.HUGO_GENE_SYMBOL as hugo_symbol_gene1,
    gene2.HUGO_GENE_SYMBOL as hugo_symbol_gene2,
    g.STABLE_ID as gene_panel_stable_id,
    cs.CANCER_STUDY_IDENTIFIER as cancer_study_identifier,
    gp.STABLE_ID as genetic_profile_stable_id
FROM structural_variant as sv
         LEFT JOIN (SELECT ENTREZ_GENE_ID, HUGO_GENE_SYMBOL FROM gene) gene1 on gene1.ENTREZ_GENE_ID = sv.SITE1_ENTREZ_GENE_ID
         LEFT JOIN (SELECT ENTREZ_GENE_ID, HUGO_GENE_SYMBOL FROM gene) gene2 on gene2.ENTREZ_GENE_ID = sv.SITE2_ENTREZ_GENE_ID
         LEFT OUTER JOIN genetic_profile gp on gp.GENETIC_PROFILE_ID = sv.GENETIC_PROFILE_ID
         LEFT JOIN sample s on sv.SAMPLE_ID = s.INTERNAL_ID
         LEFT JOIN cancer_study cs on gp.CANCER_STUDY_ID = cs.CANCER_STUDY_ID
         LEFT JOIN sample_profile sp on gp.GENETIC_PROFILE_ID = sp.GENETIC_PROFILE_ID
         LEFT JOIN gene_panel g on sp.PANEL_ID = g.INTERNAL_ID;

-- sample_clinical_attribute_numeric
DROP VIEW IF EXISTS view_sample_clinical_attribute_numeric;
CREATE VIEW view_sample_clinical_attribute_numeric AS
SELECT
    concat(cs.CANCER_STUDY_IDENTIFIER, '_', s.STABLE_ID) as sample_unique_id,
    concat(cs.CANCER_STUDY_IDENTIFIER, '_', p.STABLE_ID) as patient_unique_id,
    ATTR_ID as attribute_name,
    ATTR_VALUE as attribute_value,
    cs.CANCER_STUDY_IDENTIFIER as cancer_study_identifier
FROM cancer_study cs
         INNER JOIN patient p on cs.CANCER_STUDY_ID = p.CANCER_STUDY_ID
         INNER JOIN sample s on p.INTERNAL_ID = s.PATIENT_ID
         INNER JOIN clinical_sample cs on s.INTERNAL_ID = cs.INTERNAL_ID
WHERE ATTR_VALUE REGEXP '^[0-9.]+$';

-- sample_clinical_attribute_categorical
DROP VIEW IF EXISTS view_sample_clinical_attribute_categorical;
CREATE VIEW view_sample_clinical_attribute_categorical AS
SELECT
    concat(cs.CANCER_STUDY_IDENTIFIER, '_', s.STABLE_ID) as sample_unique_id,
    concat(cs.CANCER_STUDY_IDENTIFIER, '_', p.STABLE_ID) as patient_unique_id,
    ATTR_ID as attribute_name,
    ATTR_VALUE as attribute_value,
    cs.CANCER_STUDY_IDENTIFIER as cancer_study_identifier
FROM cancer_study cs
         INNER JOIN patient p on cs.CANCER_STUDY_ID = p.CANCER_STUDY_ID
         INNER JOIN sample s on p.INTERNAL_ID = s.PATIENT_ID
         INNER JOIN clinical_sample cs on s.INTERNAL_ID = cs.INTERNAL_ID
WHERE ATTR_VALUE NOT REGEXP '^[0-9.]+$';

-- patient_clinical_attribute_numeric
DROP VIEW IF EXISTS view_patient_clinical_attribute_numeric;
CREATE VIEW view_patient_clinical_attribute_numeric AS
SELECT
    concat(cs.CANCER_STUDY_IDENTIFIER, '_', p.STABLE_ID) as patient_unique_id,
    ATTR_ID as attribute_name,
    ATTR_VALUE as attribute_value,
    cs.CANCER_STUDY_IDENTIFIER as cancer_study_identifier
FROM cancer_study cs
         INNER JOIN patient p on cs.CANCER_STUDY_ID = p.CANCER_STUDY_ID
         INNER JOIN clinical_patient cp on p.INTERNAL_ID = cp.INTERNAL_ID
WHERE ATTR_VALUE REGEXP '^[0-9.]+$';

-- patient_clinical_attribute_categorical
DROP VIEW IF EXISTS view_patient_clinical_attribute_categorical;
CREATE VIEW view_patient_clinical_attribute_categorical AS
SELECT
    concat(cs.CANCER_STUDY_IDENTIFIER, '_', p.STABLE_ID) as patient_unique_id,
    ATTR_ID as attribute_name,
    ATTR_VALUE as attribute_value,
    cs.CANCER_STUDY_IDENTIFIER as cancer_study_identifier
FROM cancer_study cs
         INNER JOIN patient p on cs.CANCER_STUDY_ID = p.CANCER_STUDY_ID
         INNER JOIN clinical_patient cp on p.INTERNAL_ID = cp.INTERNAL_ID
WHERE ATTR_VALUE NOT REGEXP '^[0-9.]+$';

-- sample_in_data_profile
DROP VIEW IF EXISTS view_sample_in_data_profile;
CREATE VIEW view_sample_in_data_profile AS
SELECT
    concat(cs.CANCER_STUDY_IDENTIFIER, '_', sample.STABLE_ID) as sample_unique_id,
    gp.STABLE_ID,
    cs.CANCER_STUDY_IDENTIFIER
FROM sample
         INNER JOIN sample_profile sp on sample.INTERNAL_ID = sp.SAMPLE_ID
         INNER JOIN genetic_profile gp on sp.GENETIC_PROFILE_ID = gp.GENETIC_PROFILE_ID
         INNER JOIN cancer_study cs on gp.CANCER_STUDY_ID = cs.CANCER_STUDY_ID;