-- INSERT INTO `cbioportal`.`mutation` FROM INFILE '/docker-entrypoint-initdb.d/mutation_msk_impact_2017.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`mutation` FROM INFILE '/docker-entrypoint-initdb.d/mutation_msk_ch_2020.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`mutation` FROM INFILE '/docker-entrypoint-initdb.d/mutation_msk_met_2021.json' FORMAT JSONEachRow;

INSERT INTO `cbioportal`.`cna_discrete` FROM INFILE '/docker-entrypoint-initdb.d/cna_discrete_msk_impact_2017.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`cna_discrete` FROM INFILE '/docker-entrypoint-initdb.d/cna_discrete_msk_met_2021.json' FORMAT JSONEachRow;

INSERT INTO `cbioportal`.`structural_variant` FROM INFILE '/docker-entrypoint-initdb.d/struct_var_msk_impact_2017.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`structural_variant` FROM INFILE '/docker-entrypoint-initdb.d/struct_var_msk_met_2021.json' FORMAT JSONEachRow;

INSERT INTO `cbioportal`.`sample_clinical_attribute_numeric` FROM INFILE '/docker-entrypoint-initdb.d/sample_clinical_attribute_numeric_msk_impact_2017.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`sample_clinical_attribute_numeric` FROM INFILE '/docker-entrypoint-initdb.d/sample_clinical_attribute_numeric_msk_ch_2020.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`sample_clinical_attribute_numeric` FROM INFILE '/docker-entrypoint-initdb.d/sample_clinical_attribute_numeric_msk_met_2021.json' FORMAT JSONEachRow;

INSERT INTO `cbioportal`.`sample_clinical_attribute_categorical` FROM INFILE '/docker-entrypoint-initdb.d/sample_clinical_attribute_categorical_msk_impact_2017.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`sample_clinical_attribute_categorical` FROM INFILE '/docker-entrypoint-initdb.d/sample_clinical_attribute_categorical_msk_ch_2020.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`sample_clinical_attribute_categorical` FROM INFILE '/docker-entrypoint-initdb.d/sample_clinical_attribute_categorical_msk_met_2021.json' FORMAT JSONEachRow;

INSERT INTO `cbioportal`.`patient_clinical_attribute_categorical` FROM INFILE '/docker-entrypoint-initdb.d/patient_clinical_attribute_categorical_msk_impact_2017.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`patient_clinical_attribute_categorical` FROM INFILE '/docker-entrypoint-initdb.d/patient_clinical_attribute_categorical_msk_ch_2020.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`patient_clinical_attribute_categorical` FROM INFILE '/docker-entrypoint-initdb.d/patient_clinical_attribute_categorical_msk_met_2021.json' FORMAT JSONEachRow;

INSERT INTO `cbioportal`.`patient_clinical_attribute_numeric` FROM INFILE '/docker-entrypoint-initdb.d/patient_clinical_attribute_numeric_msk_impact_2017.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`patient_clinical_attribute_numeric` FROM INFILE '/docker-entrypoint-initdb.d/patient_clinical_attribute_numeric_msk_ch_2020.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`patient_clinical_attribute_numeric` FROM INFILE '/docker-entrypoint-initdb.d/patient_clinical_attribute_numeric_msk_met_2021.json' FORMAT JSONEachRow;

INSERT INTO `cbioportal`.`sample_list` FROM INFILE '/docker-entrypoint-initdb.d/sample_list_msk_impact_2017.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`sample_list` FROM INFILE '/docker-entrypoint-initdb.d/sample_list_msk_ch_2020.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`sample_list` FROM INFILE '/docker-entrypoint-initdb.d/sample_list_msk_met_2021.json' FORMAT JSONEachRow;

INSERT INTO `cbioportal`.`sample` FROM INFILE '/docker-entrypoint-initdb.d/sample_msk_impact_2017.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`sample` FROM INFILE '/docker-entrypoint-initdb.d/sample_msk_ch_2020.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`sample` FROM INFILE '/docker-entrypoint-initdb.d/sample_msk_met_2021.json' FORMAT JSONEachRow;

INSERT INTO `cbioportal`.`genetic_profile_counts` FROM INFILE '/docker-entrypoint-initdb.d/genetic_profile_counts_msk_impact_2017.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`genetic_profile_counts` FROM INFILE '/docker-entrypoint-initdb.d/genetic_profile_counts_msk_ch_2020.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`genetic_profile_counts` FROM INFILE '/docker-entrypoint-initdb.d/genetic_profile_counts_msk_met_2021.json' FORMAT JSONEachRow;

INSERT INTO `cbioportal`.`genomic_event` FROM INFILE '/docker-entrypoint-initdb.d/genomic_event_msk_impact_2017.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`genomic_event` FROM INFILE '/docker-entrypoint-initdb.d/genomic_event_msk_ch_2020.json' FORMAT JSONEachRow;
-- INSERT INTO `cbioportal`.`genomic_event` FROM INFILE '/docker-entrypoint-initdb.d/genomic_event_msk_met_2021.json' FORMAT JSONEachRow;
