use serde_yaml::Value;
use std::fs;
use anyhow::Result;

/// Generates a Crossplane claim file based on user input
pub fn generate_claim(component: &str, project_name: &str) -> String {
    let template_path = format!("src/templates/claim_template.yaml");
    let template = fs::read_to_string(template_path).expect("Failed to read claim template");

    let mut yaml: Value = serde_yaml::from_str(&template).unwrap();
    yaml["metadata"]["name"] = Value::String(format!("{}-{}", component, project_name));

    let claim_yaml = serde_yaml::to_string(&yaml).unwrap();
    let claim_file = format!("../{}.yaml", yaml["metadata"]["name"].as_str().unwrap());

    fs::write(&claim_file, &claim_yaml).expect("Failed to write claim file");
    claim_file
}
