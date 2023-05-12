import math
import os
from os import walk
from typing import Optional

NULL_REPLACEMENT_NUMBER = -1000000
NULL_REPLACEMENT_STRING = "NULL"

study_configs = [
    {
        "study_dir": "/home/pnp300/git/datahub/public/msk_met_2021",
        "name": "msk_met_2021"
    },
    {
        "study_dir": "/home/pnp300/git/datahub/public/msk_ch_2020",
        "name": "msk_ch_2020"
    },
    {
        "study_dir": "/home/pnp300/git/datahub/public/msk_impact_2017",
        "name": "msk_impact_2017"
    },
]

def has_data_type(meta_data: dict, genetic_alteration_type: str, datatype: str) -> bool:
    return len([ meta_filename for meta_filename, meta_fields in meta_data.items() if "genetic_alteration_type" in meta_fields and meta_fields["genetic_alteration_type"] == genetic_alteration_type and meta_fields["datatype"] == datatype ]) > 0

def get_filename(meta_data: dict, genetic_alteration_type: str, datatype: str) -> Optional[str]:
    entries = [ meta_fields["data_filename"] for meta_filename, meta_fields in meta_data.items() if "genetic_alteration_type" in meta_fields and meta_fields["genetic_alteration_type"] == genetic_alteration_type and meta_fields["datatype"] == datatype ]
    if len(entries) > 0:
        return entries[0]
    return None

def create_clickhouse_files(study_config: dict) -> None:

    study_dir = study_config["study_dir"]

    meta_data = {}
    for (dirpath, dirnames, filenames) in walk(study_dir):
        filenames = [ file for file in filenames if file.find("meta_") >= 0]
        for filename in filenames:
            with open(os.path.join(dirpath, filename)) as f:
                meta_fields = {}
                for line in f:
                    elements = [ element.strip() for element in line.rstrip().split(":", 1) ]
                    meta_fields[elements[0]] = elements[1]
                meta_data[filename] = meta_fields

    case_lists = {}
    for (dirpath, dirnames, filenames) in walk(f"{study_dir}/case_lists"):
        for filename in filenames:
            with open(os.path.join(dirpath, filename)) as f:
                case_list = {}
                for line in f:
                    elements = [ element.strip() for element in line.rstrip().split(":", 1) ]
                    case_list[elements[0]] = elements[1]
                case_list["case_list_ids"] = case_list["case_list_ids"].split("\t")
                case_lists[case_list["stable_id"]] = case_list

    cancer_study_id = meta_data["meta_study.txt"]["cancer_study_identifier"]

    named_genetic_profiles = { meta_fields["genetic_alteration_type"]: meta_fields for filename, meta_fields in meta_data.items() if "profile_name" in meta_fields and "genetic_alteration_type" in meta_fields and meta_fields["genetic_alteration_type"] in ["MUTATION_EXTENDED", "COPY_NUMBER_ALTERATION", "STRUCTURAL_VARIANT"] }

    sample_to_genepanel = {}
    if os.path.exists(f"{study_dir}/data_gene_panel_matrix.txt"):
        with open(f"{study_dir}/data_gene_panel_matrix.txt") as infile:
            header_idx = None
            for line in infile:
                if line.startswith("#"):
                    continue
                if header_idx is None:
                    header_elements = [ header for header in line.rstrip().split("\t") ]
                    profile_ids = [ header for header in header_elements if header != "SAMPLE_ID" ]
                    header_idx = { element: idx for idx, element in enumerate(header_elements) }
                    continue
                line_elements = line.rstrip().split("\t")
                sample_stable_id = line_elements[header_idx["SAMPLE_ID"]]
                for profile_id in profile_ids:
                    if sample_stable_id not in sample_to_genepanel:
                        sample_to_genepanel[sample_stable_id] = {}
                    gene_panel = line_elements[header_idx[profile_id]]
                    if gene_panel in ["NA", "nan", "NaN"]:
                        gene_panel = None
                    sample_to_genepanel[sample_stable_id][profile_id] = gene_panel

    samples = {}
    patients = {}
    sample_to_id = {}
    patient_to_id = {}
    sample_idx = 35091
    patient_idx = 34482
    with open(f"{study_dir}/data_clinical_sample.txt") as infile:
        header_idx = None
        for line in infile:
            if line.startswith("#"):
                if line.startswith(("#STRING","#NUMBER","#BOOLEAN")):
                    type_elements = line.rstrip().split("\t")
                    type_idx = { idx: element for idx, element in enumerate(type_elements) }
                continue
            if header_idx is None:
                header_elements = [ header for header in line.rstrip().split("\t") ]
                attr_names = [header for header in header_elements if header not in ["PATIENT_ID", "SAMPLE_ID"] ]
                header_idx = { element: idx for idx, element in enumerate(header_elements) }
                continue
            line_elements = line.rstrip().split("\t")
            sample_stable_id = line_elements[header_idx["SAMPLE_ID"]]
            patient_stable_id = line_elements[header_idx["PATIENT_ID"]]
            for attr_name in attr_names:
                if sample_stable_id not in samples:
                    sample_to_id[sample_stable_id] = sample_idx
                    samples[sample_stable_id] = {
                        "sample_stable_id": line_elements[header_idx["SAMPLE_ID"]],
                        "patient_stable_id": line_elements[header_idx["PATIENT_ID"]],
                        "sample_id": sample_idx,
                        "attrs": [],
                        "mutations": [],
                        "cnas": [],
                        "svs": []
                    }
                    sample_idx += 1
                attr_value = line_elements[header_idx[attr_name]] if len(line_elements) - 1 >= header_idx[attr_name] else 'NA'
                type = type_idx[header_idx[attr_name]]
                if type == "BOOLEAN":
                    if attr_value == 'true':
                        attr_value = 1
                    elif attr_value == 'false':
                        attr_value = 0
                    else:
                        raise ValueError(f"Unexpected value for BOOLEAN datatype (observed: {attr_value})")
                attr_type = type_idx[header_idx[attr_name]]
                if attr_value in ["NA", "nan", "NaN"]:
                    if attr_type == "STRING":
                        attr_value = NULL_REPLACEMENT_STRING
                    elif attr_type == "NUMBER":
                        attr_value = NULL_REPLACEMENT_NUMBER
                    else:
                        raise ValueError(f"Unexpected value for datatype (observed: {attr_type})")
                samples[sample_stable_id]["attrs"] += [{
                    "name": attr_name,
                    "value": attr_value,
                    "type": type_idx[header_idx[attr_name]],
                }]

    with open(f"{study_dir}/data_clinical_patient.txt") as infile:
        header_idx = None
        for line in infile:
            if line.startswith("#"):
                if line.startswith(("#STRING","#NUMBER","#BOOL")):
                    type_elements = line.rstrip().split("\t")
                    type_idx = { idx: element for idx, element in enumerate(type_elements) }
                continue
            if header_idx is None:
                header_elements = [ header for header in line.rstrip().split("\t") ]
                attr_names = [header for header in header_elements if header not in ["PATIENT_ID"] ]
                header_idx = { element: idx for idx, element in enumerate(header_elements) }
                continue
            line_elements = line.rstrip("\n").split("\t")
            for attr_name in attr_names:
                patient_stable_id = line_elements[header_idx["PATIENT_ID"]]
                if patient_stable_id not in patients:
                    patient_to_id[patient_stable_id] = patient_idx
                    patients[patient_stable_id] = {
                        "patient_stable_id": line_elements[header_idx["PATIENT_ID"]],
                        "patient_id": patient_idx,
                        "attrs": []
                    }
                    patient_idx += 1
                attr_value = line_elements[header_idx[attr_name]] if len(line_elements) - 1 >= header_idx[attr_name] else 'NA'
                attr_type = type_idx[header_idx[attr_name]]
                if attr_value in ["NA", "nan", "NaN"]:
                    if attr_type == "STRING":
                        attr_value = NULL_REPLACEMENT_STRING
                    elif attr_type == "NUMBER":
                        attr_value = NULL_REPLACEMENT_NUMBER
                    else:
                        raise ValueError(f"Unexpected value for datatype (observed: {attr_type})")
                patients[patient_stable_id]["attrs"] += [{
                    "name": attr_name,
                    "value": attr_value,
                    "type": type_idx[header_idx[attr_name]],
                }]

    # mutation
    filename = get_filename(meta_data, "MUTATION_EXTENDED", "MAF")
    if filename != None:
        with open(f"{study_dir}/{filename}") as infile:
            header_idx = None
            for line in infile:
                if line.startswith("#"):
                    continue
                if header_idx is None:
                    header_elements = [ header for header in line.rstrip().split("\t") ]
                    header_idx = { element: idx for idx, element in enumerate(header_elements) }
                    continue
                line_elements = line.rstrip("\n").split("\t")
                gene_symbol = line_elements[header_idx["Hugo_Symbol"]]
                sample_stable_id = line_elements[header_idx["Tumor_Sample_Barcode"]]
                variant = line_elements[header_idx["HGVSp_Short"]]
                samples[sample_stable_id]["mutations"] += [{
                    "hugo_gene_symbol": gene_symbol,
                    "variant": variant
                }]

    # cna
    filename = get_filename(meta_data, "COPY_NUMBER_ALTERATION", "DISCRETE")
    if filename != None:
        with open(f"{study_dir}/{filename}") as infile:
            sample_indexes = None
            for line in infile:
                if line.startswith("#"):
                    continue
                if sample_indexes is None:
                    header_elements = [ header for header in line.rstrip().split("\t") ]
                    gene_index = header_elements.index("Hugo_Symbol")
                    sample_indexes = { element: idx for idx, element in enumerate(header_elements) if element != "Hugo_Symbol" }
                    sample_stable_ids = [ element for element in header_elements if element != "Hugo_Symbol" ]
                    continue
                line_elements = line.rstrip().split("\t")
                gene_symbol = line_elements[gene_index]
                for sample_stable_id in sample_stable_ids:
                    alteration = line_elements[sample_indexes[sample_stable_id]]
                    if alteration in ["NA", "nan", "NaN", None, ""]:
                        alteration = 0; # WT
                    alteration = float(alteration)
                    samples[sample_stable_id]["cnas"] += [{
                        "hugo_gene_symbol": gene_symbol,
                        "alteration": int(math.copysign(1, alteration)*math.ceil(abs(alteration)))
                    }]

    # sv
    filename = get_filename(meta_data, "STRUCTURAL_VARIANT", "SV")
    if filename != None:
        with open(f"{study_dir}/{filename}") as infile:
            header_idx = None
            for line in infile:
                if line.startswith("#"):
                    continue
                if header_idx is None:
                    header_elements = [ header for header in line.rstrip().split("\t") ]
                    header_idx = { element: idx for idx, element in enumerate(header_elements) }
                    continue
                line_elements = line.rstrip().split("\t")
                gene1_symbol = line_elements[header_idx["Site1_Hugo_Symbol"]]
                gene2_symbol = line_elements[header_idx["Site2_Hugo_Symbol"]]
                sample_stable_id = line_elements[header_idx["Sample_Id"]]
                samples[sample_stable_id]["svs"] += [{
                    "hugo_symbol_gene1": gene1_symbol,
                    "hugo_symbol_gene2": gene2_symbol,
                }]

    mutation_genetic_profile_stable_id = ""
    cna_genetic_profile_stable_id = ""
    sv_genetic_profile_stable_id = ""
    if has_data_type(meta_data, "MUTATION_EXTENDED", "MAF"):
        mutation_genetic_profile_stable_id = f'{cancer_study_id}_{named_genetic_profiles["MUTATION_EXTENDED"]["stable_id"]}'
    if has_data_type(meta_data, "COPY_NUMBER_ALTERATION", "DISCRETE"):
        cna_genetic_profile_stable_id = f'{cancer_study_id}_{named_genetic_profiles["COPY_NUMBER_ALTERATION"]["stable_id"]}'
    if has_data_type(meta_data, "STRUCTURAL_VARIANT", "SV"):
        sv_genetic_profile_stable_id = f'{cancer_study_id}_{named_genetic_profiles["STRUCTURAL_VARIANT"]["stable_id"]}'

    study_name = study_config["name"]

    if has_data_type(meta_data, "MUTATION_EXTENDED", "MAF"):
        with open(f"clickhouse_provisioning/mutation_{study_name}.json", "w") as f:
            for sample_stable_id in samples.keys():
                for mut in samples[sample_stable_id]["mutations"]:
                    json_line = f'{{"sample_unique_id": "{cancer_study_id}_{sample_stable_id}", "variant": "{mut["variant"]}", "hugo_gene_symbol": "{mut["hugo_gene_symbol"]}", "cancer_study_identifier": "{cancer_study_id}", "genetic_profile_stable_id": "{mutation_genetic_profile_stable_id}"}}\n'
                    f.write(json_line)

    if has_data_type(meta_data, "COPY_NUMBER_ALTERATION", "DISCRETE"):
        with open(f"clickhouse_provisioning/cna_discrete_{study_name}.json", "w") as f:
            for sample_stable_id in samples.keys():
                for cna in samples[sample_stable_id]["cnas"]:
                    json_line = f'{{"sample_unique_id": "{cancer_study_id}_{sample_stable_id}", "alteration": {cna["alteration"]}, "hugo_gene_symbol": "{cna["hugo_gene_symbol"]}", "gene_panel_stable_id": "{sample_to_genepanel[sample_stable_id]["cna"]}", "cancer_study_identifier": "{cancer_study_id}", "genetic_profile_stable_id": "{cna_genetic_profile_stable_id}"}}\n'
                    f.write(json_line)

    if has_data_type(meta_data, "STRUCTURAL_VARIANT", "SV"):
        with open(f"clickhouse_provisioning/struct_var_{study_name}.json", "w") as f:
            for sample_stable_id in samples.keys():
                for sv in samples[sample_stable_id]["svs"]:
                    json_line = f'{{"sample_unique_id": "{cancer_study_id}_{sample_stable_id}", "hugo_symbol_gene1": "{sv["hugo_symbol_gene1"]}", "hugo_symbol_gene2": "{sv["hugo_symbol_gene2"]}", "gene_panel_stable_id": "{sample_to_genepanel[sample_stable_id]["cna"]}", "cancer_study_identifier": "{cancer_study_id}", "genetic_profile_stable_id": "{sv_genetic_profile_stable_id}"}}\n'
                    f.write(json_line)

    with open(f"clickhouse_provisioning/sample_{study_name}.json", "w") as f:
        for sample_stable_id in samples.keys():
            patient_stable_id = samples[sample_stable_id]["patient_stable_id"]
            json_line = f'{{"sample_unique_id": "{cancer_study_id}_{sample_stable_id}", "sample_stable_id": "{sample_stable_id}", "patient_unique_id": "{cancer_study_id}_{patient_stable_id}", "patient_stable_id": "{patient_stable_id}", "cancer_study_identifier": "{cancer_study_id}"}}\n'
            f.write(json_line)

    with open(f"clickhouse_provisioning/sample_clinical_attribute_categorical_{study_name}.json", "w") as f:
        for sample_stable_id in samples.keys():
            attrs = [ attr for attr in samples[sample_stable_id]["attrs"] if attr["type"] == "STRING" ]
            patient_stable_id = samples[sample_stable_id]["patient_stable_id"]
            for attr in attrs:
                json_line = f'{{"patient_unique_id": "{cancer_study_id}_{patient_stable_id}", "sample_unique_id": "{cancer_study_id}_{sample_stable_id}", "attribute_name": "{attr["name"]}", "attribute_value": "{attr["value"]}", "cancer_study_identifier": "{cancer_study_id}"}}\n'
                f.write(json_line)

    with open(f"clickhouse_provisioning/sample_clinical_attribute_numeric_{study_name}.json", "w") as f:
        for sample_stable_id in samples.keys():
            attrs = [ attr for attr in samples[sample_stable_id]["attrs"] if attr["type"] in ["NUMBER", "BOOLEAN"] ]
            for attr in attrs:
                json_line = f'{{"sample_unique_id": "{cancer_study_id}_{sample_stable_id}", "patient_unique_id": "{cancer_study_id}_{patient_stable_id}", "attribute_name": "{attr["name"]}", "attribute_value": {attr["value"]}, "cancer_study_identifier": "{cancer_study_id}"}}\n'
                f.write(json_line)

    with open(f"clickhouse_provisioning/patient_clinical_attribute_categorical_{study_name}.json", "w") as f:
        for patient_stable_id in patients.keys():
            attrs = [ attr for attr in patients[patient_stable_id]["attrs"] if attr["type"] == "STRING" ]
            for attr in attrs:
                json_line = f'{{"patient_unique_id": "{cancer_study_id}_{patient_stable_id}", "attribute_name": "{attr["name"]}", "attribute_value": "{attr["value"]}", "cancer_study_identifier": "{cancer_study_id}"}}\n'
                f.write(json_line)

    with open(f"clickhouse_provisioning/patient_clinical_attribute_numeric_{study_name}.json", "w") as f:
        for patient_stable_id in patients.keys():
            attrs = [ attr for attr in patients[patient_stable_id]["attrs"] if attr["type"] in ["NUMBER", "BOOLEAN"] ]
            for attr in attrs:
                json_line = f'{{"patient_unique_id": "{cancer_study_id}_{patient_stable_id}", "attribute_name": "{attr["name"]}", "attribute_value": {attr["value"]}, "cancer_study_identifier": "{cancer_study_id}"}}\n'
                f.write(json_line)

    with open(f"clickhouse_provisioning/sample_list_{study_name}.json", "w") as f:
        for case_list_stable_id, case_list in case_lists.items():
            case_list_name = case_list["case_list_name"]
            for sample_stable_id in case_list["case_list_ids"]:
                json_line = f'{{' \
                f'"sample_unique_id": "{cancer_study_id}_{sample_stable_id}",' \
                f'"sample_list_stable_id": "{case_list_stable_id}",' \
                f'"name": "{case_list_name}",' \
                f'"cancer_study_identifier": "{cancer_study_id}"}}\n'
                f.write(json_line)

    with open(f"clickhouse_provisioning/genetic_profile_counts_{study_name}.json", "w") as f:
        # sample_stable_id, profile_name, profile_stable_id, cancer_study_identifier, count
        for sample_stable_id, sample in samples.items():
            m_count = len(sample["mutations"])
            if m_count > 0:
                mutation_genetic_profile_name = named_genetic_profiles["MUTATION_EXTENDED"]["profile_name"]
                json_line = f'{{"sample_unique_id": "{cancer_study_id}_{sample_stable_id}", ' \
                f'"profile_name": "{mutation_genetic_profile_name}", ' \
                f'"genetic_profile_stable_id": "{mutation_genetic_profile_stable_id}", ' \
                f'"cancer_study_identifier": "{cancer_study_id}", ' \
                f'"count": {m_count}}}\n'
                f.write(json_line)
            c_count = len(sample["cnas"])
            if c_count > 0:
                cna_genetic_profile_name = named_genetic_profiles["COPY_NUMBER_ALTERATION"]["profile_name"]
                json_line = f'{{"sample_unique_id": "{cancer_study_id}_{sample_stable_id}",' \
                f'"profile_name": "{cna_genetic_profile_name}", "genetic_profile_stable_id":' \
                f'"{cna_genetic_profile_stable_id}", "cancer_study_identifier": "{cancer_study_id}", "count": {c_count}}}\n'
                f.write(json_line)
            s_count = len(sample["svs"])
            if s_count > 0:
                sv_genetic_profile_name = named_genetic_profiles["STRUCTURAL_VARIANT"]["profile_name"]
                json_line = f'{{"sample_unique_id": "{cancer_study_id}_{sample_stable_id}", "profile_name": "{sv_genetic_profile_name}", "genetic_profile_stable_id": "{sv_genetic_profile_stable_id}", "cancer_study_identifier": "{cancer_study_id}", "count": {s_count}}}\n'
                f.write(json_line)

    with open(f"clickhouse_provisioning/genomic_event_{study_name}.json", "w") as f:
        for sample_stable_id, sample in samples.items():
            for mut in sample["mutations"]:
                json_line = f'{{"sample_unique_id": "{cancer_study_id}_{sample_stable_id}", "variant": "{mut["variant"]}", "hugo_gene_symbol": "{mut["hugo_gene_symbol"]}", "cancer_study_identifier": "{cancer_study_id}", "genetic_profile_stable_id": "{mutation_genetic_profile_stable_id}"}}\n'
                f.write(json_line)
            for cna in samples[sample_stable_id]["cnas"]:
                if cna["alteration"] == -2 or cna["alteration"] == 2:
                    json_line = f'{{"sample_unique_id": "{cancer_study_id}_{sample_stable_id}", "variant": "{str(cna["alteration"])}", "hugo_gene_symbol": "{mut["hugo_gene_symbol"]}", "cancer_study_identifier": "{cancer_study_id}", "genetic_profile_stable_id": "{cna_genetic_profile_stable_id}"}}\n'
                    f.write(json_line)
            for sv in samples[sample_stable_id]["svs"]:
                if sv["hugo_symbol_gene1"] is not None:
                    json_line = f'{{"sample_unique_id": "{cancer_study_id}_{sample_stable_id}", "variant": "{str(cna["alteration"])}", "hugo_gene_symbol": "{sv["hugo_symbol_gene1"]}", "cancer_study_identifier": "{cancer_study_id}", "genetic_profile_stable_id": "{sv_genetic_profile_stable_id}"}}\n'
                    f.write(json_line)
                if sv["hugo_symbol_gene2"] is not None:
                    json_line = f'{{"sample_unique_id": "{cancer_study_id}_{sample_stable_id}", "variant": "{str(cna["alteration"])}", "hugo_gene_symbol": "{sv["hugo_symbol_gene2"]}", "cancer_study_identifier": "{cancer_study_id}", "genetic_profile_stable_id": "{sv_genetic_profile_stable_id}"}}\n'
                    f.write(json_line)

for study_config  in study_configs:
    create_clickhouse_files(study_config)