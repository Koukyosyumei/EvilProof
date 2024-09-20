TARGET=$1
VICTIM=$2

# computing the witness
node ../../script/export_witness.js build/${VICTIM}_js/${VICTIM}.wasm data/${TARGET}_witness.json build/${TARGET}_witness.wasm

# Generating a Proof
snarkjs groth16 prove build/${VICTIM}_0001.zkey build/${TARGET}_witness.wasm build/${TARGET}_proof.json build/${TARGET}_public.json
