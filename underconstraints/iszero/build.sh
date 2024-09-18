mkdir build

# writing circuits
circom safe.circom --r1cs --wasm --sym --c -o build

# computing the witness
cd build/safe_js
ls
node generate_witness.js safe.wasm ../../input.json ../safe_witness.wtns
cd ..

# Powers of Tau
snarkjs powersoftau new bn128 12 safe_pot12_0000.ptau -v
snarkjs powersoftau contribute safe_pot12_0000.ptau safe_pot12_0001.ptau --name="First contribution" -v

# Phase 2
snarkjs powersoftau prepare phase2 safe_pot12_0001.ptau safe_pot12_final.ptau -v
snarkjs groth16 setup safe.r1cs safe_pot12_final.ptau safe_0000.zkey
snarkjs zkey contribute safe_0000.zkey safe_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey safe_0001.zkey safe_verification_key.json

# Generating a Proof
snarkjs groth16 prove safe_0001.zkey safe_witness.wtns safe_proof.json safe_public.json

# Verifying a Proof
# snarkjs groth16 verify verification_key.json public.json proof.json