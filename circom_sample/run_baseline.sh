# record the time of running this script

# start time
start=$(date +%s)

echo "circom zk_dml.circom --r1cs --wasm --sym --c --O1 -l /home/zhaoyu/.nvm/versions/node/v22.4.1/lib"
circom zk_dml.circom --r1cs --wasm --sym --c --O1 -l /home/zhaoyu/.nvm/versions/node/v22.4.1/lib
cd zk_dml_js
echo "node generate_witness.js zk_dml.wasm ../input.json witness.wtns"
node generate_witness.js zk_dml.wasm ../input.json witness.wtns
cd ..
echo "snarkjs powersoftau new bn128 12 pot12_0000.ptau -v"
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
echo "snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name=\"First contribution\" -v"
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

echo "snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v"
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
echo "snarkjs groth16 setup zk_dml.r1cs pot12_final.ptau zk_dml_0000.zkey"
snarkjs groth16 setup zk_dml.r1cs pot12_final.ptau zk_dml_0000.zkey
echo "snarkjs zkey contribute zk_dml_0000.zkey zk_dml_0001.zkey --name=\"1st Contributor Name\" -v"
snarkjs zkey contribute zk_dml_0000.zkey zk_dml_0001.zkey --name="1st Contributor Name" -v

echo "snarkjs zkey export verificationkey zk_dml_0001.zkey verification_key.json"
snarkjs zkey export verificationkey zk_dml_0001.zkey verification_key.json
echo "snarkjs groth16 prove zk_dml_0001.zkey zk_dml_js/witness.wtns proof.json public.json"
snarkjs groth16 prove zk_dml_0001.zkey zk_dml_js/witness.wtns proof.json public.json
echo "snarkjs groth16 verify verification_key.json public.json proof.json"
snarkjs groth16 verify verification_key.json public.json proof.json

# end time
end=$(date +%s)
runtime=$((end-start))
echo "Runtime: $runtime seconds"