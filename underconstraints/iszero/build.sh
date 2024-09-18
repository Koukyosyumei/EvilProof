mkdir build

TARGET=$1

# writing circuits
circom ${TARGET}.circom --r1cs --wasm --sym --c -o build

# computing the witness
cd build/${TARGET}_js
ls
node generate_witness.js ${TARGET}.wasm ../../input.json ../${TARGET}_witness.wtns
cd ..

# Powers of Tau
snarkjs powersoftau new bn128 12 ${TARGET}_pot12_0000.ptau -v
snarkjs powersoftau contribute ${TARGET}_pot12_0000.ptau ${TARGET}_pot12_0001.ptau --name="First contribution" -v

# Phase 2
snarkjs powersoftau prepare phase2 ${TARGET}_pot12_0001.ptau ${TARGET}_pot12_final.ptau -v
snarkjs groth16 setup ${TARGET}.r1cs ${TARGET}_pot12_final.ptau ${TARGET}_0000.zkey
snarkjs zkey contribute ${TARGET}_0000.zkey ${TARGET}_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey ${TARGET}_0001.zkey ${TARGET}_verification_key.json

# Generating a Proof
snarkjs groth16 prove ${TARGET}_0001.zkey ${TARGET}_witness.wtns ${TARGET}_proof.json ${TARGET}_public.json

# Verifying a Proof
# snarkjs groth16 verify verification_key.json public.json proof.json