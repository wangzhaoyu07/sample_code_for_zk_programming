pragma circom 2.1.9;

include "node_modules/circomlib/circuits/mimc.circom";

template Add(n) {
  signal input a[n];
  signal output out;

  signal temp[n];
  temp[0] <== a[0];

  for (var i = 1; i < n; i++) {
    temp[i] <== temp[i-1] + a[i];
  }

  out <== temp[n-1];
}

template ZK_DML () {  

   // Declaration of signals.  
   signal input w_y[3];  
   signal input b_y;  
   signal input w_t[3];
   signal input b_t;
   signal input w_f;
   signal input b_f;
   signal input in[4];

   signal predicted_outcome_intermediate[4];
   signal predicted_outcome;
   signal predicted_treatment_intermediate[4];
   signal predicted_treatment;
   signal treatment_residual;
   signal predicted_outcome_residual;
   signal hash_intermediate[10];

   signal output result;  
   signal output hash_result;

   // predicted_outcome <== w_y[0] * in[1] + w_y[1] * in[2] + w_y[2] * in[3] + b_y;
   for (var i = 0; i < 3; i++) {
      predicted_outcome_intermediate[i] <== w_y[i] * in[i+1];
   }
   predicted_outcome_intermediate[3] <== b_y;
   component predicted_outcome_sum = Add(4);
   predicted_outcome_sum.a <== predicted_outcome_intermediate;
   predicted_outcome <== predicted_outcome_sum.out;

   // predicted_treatment <== w_t[0] * in[1] + w_t[1] * in[2] + w_t[2] * in[3] + b_t;

   for (var i = 0; i < 3; i++) {
      predicted_treatment_intermediate[i] <== w_t[i] * in[i+1];
   }
   predicted_treatment_intermediate[3] <== b_t;
   component predicted_treatment_sum = Add(4);
   predicted_treatment_sum.a <== predicted_treatment_intermediate;
   predicted_treatment <== predicted_treatment_sum.out;

   treatment_residual <== in[0] - predicted_treatment;
   predicted_outcome_residual <== w_f * treatment_residual + b_f;
   result <== predicted_outcome + predicted_outcome_residual;
   
   component mimsc = MultiMiMC7(10, 91);

   for (var i = 0; i < 3; i++) {
      hash_intermediate[i] <== w_y[i];
      hash_intermediate[i+4] <== w_t[i];
   }
   hash_intermediate[3] <== b_y;
   hash_intermediate[7] <== b_t;
   hash_intermediate[8] <== w_f;
   hash_intermediate[9] <== b_f;

   mimsc.in <== hash_intermediate;
   mimsc.k <== 0;
   hash_result <== mimsc.out;
}

component main = ZK_DML();