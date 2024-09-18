TARGET=$1
VICTIM=$2

# writing circuits
circom ${TARGET}.circom --r1cs --wasm --sym --c -o build

# computing the witness
cd build/${TARGET}_js
ls
node generate_witness.js ${TARGET}.wasm ../../data/1.json ../${TARGET}_witness.wtns
cd ..

# Generating a Proof
snarkjs groth16 prove ${VICTIM}_0001.zkey ${TARGET}_witness.wtns ${TARGET}_proof.json ${TARGET}_public.json

# Verifying a Proof
# snarkjs groth16 verify verification_key.json public.json proof.json