# Note: update database host, name and credentials!

CREATE TABLE IF NOT EXISTS `cbioportal`.`mysql_sample` (
    `sample_unique_id` VARCHAR(45),
    `sample_stable_id` VARCHAR(45),
    `patient_unique_id` VARCHAR(45),
    `patient_stable_id` VARCHAR(45),
    `cancer_study_identifier` VARCHAR(45))
ENGINE = MySQL('cbioportal-database:3306', 'cbioportal', 'view_sample', 'cbio', 'P@ssword1');

CREATE TABLE IF NOT EXISTS `cbioportal`.`mysql_sample_list` (
    `sample_unique_id` VARCHAR(45),
    `sample_list_stable_id` VARCHAR(45),
    `name` VARCHAR(45),
    `cancer_study_identifier` VARCHAR(45))
ENGINE = MySQL('cbioportal-database:3306', 'cbioportal', 'view_sample_list', 'cbio', 'P@ssword1');

CREATE TABLE IF NOT EXISTS `cbioportal`.`mysql_genomic_event_mutation` (
   `sample_unique_id` VARCHAR(45),
   `variant` VARCHAR(45),
   `hugo_gene_symbol` VARCHAR(45),
   `gene_panel_stable_id` VARCHAR(45),
   `cancer_study_identifier` VARCHAR(45),
   `genetic_profile_stable_id` VARCHAR(45))
ENGINE = MySQL('cbioportal-database:3306', 'cbioportal', 'view_genomic_event_mutation', 'cbio', 'P@ssword1');

CREATE TABLE IF NOT EXISTS `cbioportal`.`mysql_genomic_event_cna` (
  `sample_unique_id` VARCHAR(45),
  `variant` VARCHAR(45),
  `hugo_gene_symbol` VARCHAR(45),
  `gene_panel_stable_id` VARCHAR(45),
  `cancer_study_identifier` VARCHAR(45),
  `genetic_profile_stable_id` VARCHAR(45))
ENGINE = MySQL('cbioportal-database:3306', 'cbioportal', 'view_genomic_event_cna', 'cbio', 'P@ssword1');

CREATE TABLE IF NOT EXISTS `cbioportal`.`mysql_genomic_event_struct_var` (
  `sample_unique_id` VARCHAR(45),
  `variant` VARCHAR(45),
  `hugo_gene_symbol` VARCHAR(45),
  `gene_panel_stable_id` VARCHAR(45),
  `cancer_study_identifier` VARCHAR(45),
  `genetic_profile_stable_id` VARCHAR(45))
ENGINE = MySQL('cbioportal-database:3306', 'cbioportal', 'view_genomic_event_struct_var', 'cbio', 'P@ssword1');

CREATE TABLE IF NOT EXISTS `cbioportal`.`mysql_mutation` (
    `sample_unique_id` VARCHAR(45),
    `variant` VARCHAR(45),
    `hugo_gene_symbol` VARCHAR(45),
    `gene_panel_stable_id` VARCHAR(45),
    `cancer_study_identifier` VARCHAR(45),
    `genetic_profile_stable_id` VARCHAR(45))
--     note: 'view_genomic_event_mutation' is correct here
ENGINE = MySQL('cbioportal-database:3306', 'cbioportal', 'view_genomic_event_mutation', 'cbio', 'P@ssword1');

CREATE TABLE IF NOT EXISTS `cbioportal`.`mysql_cna` (
   `sample_unique_id` VARCHAR(45),
   `alteration` INT,
   `hugo_gene_symbol` VARCHAR(45),
   `gene_panel_stable_id` VARCHAR(45),
   `cancer_study_identifier` VARCHAR(45),
   `genetic_profile_stable_id` VARCHAR(45))
ENGINE = MySQL('cbioportal-database:3306', 'cbioportal', 'view_cna', 'cbio', 'P@ssword1');

CREATE TABLE IF NOT EXISTS `cbioportal`.`mysql_structural_variant` (
  `sample_unique_id` VARCHAR(45),
  `hugo_symbol_gene1` VARCHAR(45),
  `hugo_symbol_gene2` VARCHAR(45),
  `gene_panel_stable_id` VARCHAR(45),
  `cancer_study_identifier` VARCHAR(45),
  `genetic_profile_stable_id` VARCHAR(45))
ENGINE = MySQL('cbioportal-database:3306', 'cbioportal', 'view_structural_variant', 'cbio', 'P@ssword1');

CREATE TABLE IF NOT EXISTS `cbioportal`.`mysql_sample_clinical_attribute_numeric` (
    `patient_unique_id` VARCHAR(45),
    `sample_unique_id` VARCHAR(45),
    `attribute_name` VARCHAR(45),
    `attribute_value` FLOAT,
    `cancer_study_identifier` VARCHAR(45))
ENGINE = MySQL('cbioportal-database:3306', 'cbioportal', 'view_sample_clinical_attribute_numeric', 'cbio', 'P@ssword1');

CREATE TABLE IF NOT EXISTS `cbioportal`.`mysql_patient_clinical_attribute_numeric` (
    `patient_unique_id` VARCHAR(45),
    `attribute_name` VARCHAR(45),
    `attribute_value` FLOAT,
    `cancer_study_identifier` VARCHAR(45))
ENGINE = MySQL('cbioportal-database:3306', 'cbioportal', 'view_patient_clinical_attribute_numeric', 'cbio', 'P@ssword1');

CREATE TABLE IF NOT EXISTS `cbioportal`.`mysql_sample_clinical_attribute_categorical` (
  `patient_unique_id` VARCHAR(45),
  `sample_unique_id` VARCHAR(45),
  `attribute_name` VARCHAR(45),
  `attribute_value` VARCHAR(45),
  `cancer_study_identifier` VARCHAR(45))
ENGINE = MySQL('cbioportal-database:3306', 'cbioportal', 'view_sample_clinical_attribute_categorical', 'cbio', 'P@ssword1');

CREATE TABLE IF NOT EXISTS `cbioportal`.`mysql_patient_clinical_attribute_categorical` (
  `patient_unique_id` VARCHAR(45),
  `attribute_name` VARCHAR(45),
  `attribute_value` VARCHAR(45),
  `cancer_study_identifier` VARCHAR(45))
ENGINE = MySQL('cbioportal-database:3306', 'cbioportal', 'view_patient_clinical_attribute_categorical', 'cbio', 'P@ssword1');

CREATE TABLE IF NOT EXISTS `cbioportal`.`mysql_genetic_alteration` (
  `sample_unique_id` VARCHAR(45),
  `sample_stable_id` VARCHAR(45),
  `patient_unique_id` VARCHAR(45),
  `patient_stable_id` VARCHAR(45),
  `genetic_profile_STABLE_ID` VARCHAR(45),
  `genetic_entity_STABLE_ID` VARCHAR(45),
  `cancer_study_identifier` VARCHAR(45),
  `value` VARCHAR(255))
    ENGINE = MergeTree
    ORDER BY (`sample_unique_id`, `sample_stable_id`, `patient_unique_id`, `patient_stable_id`, `genetic_profile_STABLE_ID`, `genetic_entity_STABLE_ID`, `cancer_study_identifier`, `value`)
    PRIMARY KEY (`sample_unique_id`, `sample_stable_id`, `patient_unique_id`, `patient_stable_id`, `genetic_profile_STABLE_ID`, `genetic_entity_STABLE_ID`, `cancer_study_identifier`);
