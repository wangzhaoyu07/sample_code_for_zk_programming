use risc0_zkvm::guest::env;

use std::collections::HashMap;
use std::hash::{DefaultHasher, Hash, Hasher};

fn linear_regression_predict(weights: Vec<f64>, bias: f64, x: &Vec<f64>) -> f64 {
    let mut result = bias;

    for i in 0..weights.len() {
        result += weights[i] * x[i] as f64;
    }

    result
}

fn get_features_from_input(input: &Vec<f64>) -> Vec<f64> {
    let mut features: Vec<f64> = Vec::new();
    let n_features = input.len();
    for i in 0..input.len() {
        if i == 0 || i == n_features-1 {
            continue;
        }
        features.push(input[i]);
    }
    features
}

fn get_treatment_from_input(input: &Vec<f64>) -> f64 {
    input[0]
}

fn get_outcome_from_input(input: &Vec<f64>) -> f64 {
    let n_features = input.len();
    input[n_features-1]
}

fn calculate_hash<T: Hash>(t: &T) -> u64 {
    let mut s = DefaultHasher::new();
    t.hash(&mut s);
    s.finish()
}

fn main() {
    // Read the model from the host into a SmartCore Decision Tree model object.
    // We MUST explicitly declare the correct type in order for deserialization to be
    // successful.
    let weights_dict:HashMap<String, Vec<f64>> = env::read();
    let bias_dict: HashMap<String, f64> = env::read();

    let input_data:Vec<f64> = vec![17.3,6.0,1.5,5.6,173.0];

    let features:Vec<f64> = get_features_from_input(&input_data);
    let treatment:f64 = get_treatment_from_input(&input_data);
    let outcome:f64 = get_outcome_from_input(&input_data);

    let predicted_outcome = linear_regression_predict(weights_dict["model_y"].clone(), bias_dict["model_y"].clone(), &features);
    let predicted_treatment = linear_regression_predict(weights_dict["model_t"].clone(), bias_dict["model_t"].clone(), &features);
    
    let treatment_residual: f64 = treatment - predicted_treatment;
    let treatment_residual_vec = vec![treatment_residual];

    let predicted_outcome_residual = linear_regression_predict(weights_dict["model_f"].clone(), bias_dict["model_f"].clone(), &treatment_residual_vec);
    let result = predicted_outcome + predicted_outcome_residual;


    // let eval_result = mean_squared_error(&outcome, &predicted_outcome);
    // println!("{:?}", eval_result); 

    // This line is optional and can be commented out, but it's useful to see
    // the output of the computation before the proving step begins.
    println!("answer: {:?}", &result);

    // We commit the output to the journal.
    env::commit(&result);
    // env::commit(&base64_hash); 

    let mut model_vec= Vec::new();
    let mut bias_vec = Vec::new();
    let model_name_ls = vec!["model_t", "model_y", "model_f"];
    for model_name in model_name_ls {
        let weights_str: Vec<String> = weights_dict.get(model_name).unwrap().iter().map(|&x| x.to_string()).collect();
        model_vec.push(weights_str);

        let bias_str = bias_dict.get(model_name).unwrap().to_string();
        bias_vec.push(bias_str);
    }

    model_vec.push(bias_vec);

    let hash_result = calculate_hash(&model_vec);
    println!("hash: {:?}", hash_result);

    env::commit(&hash_result);
    
    // Logging the total cycle count is optional, though it's quite useful for benchmarking
    // the various operations in the guest code. env::cycle_count() can be
    // called anywhere in the guest, multiple times. So if we are interested in
    // knowing how many cycles the inference computation takes, we can calculate
    // total cycles before and after model.predict() and the difference between
    // the two values equals the total cycle count for that section of the guest
    // code.
    println!(
        "Total cycles for guest code execution: {}",
        env::cycle_count()
    );
}