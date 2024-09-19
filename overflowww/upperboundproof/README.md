# UpperBoundProof

- build

```bash
sh script/setup.sh

sh script/build.sh vuln
```

- attack

```bash
snarkjs groth16 verify build/vuln_verification_key.json build/vuln_public.json build/vuln_proof.json
>>>[INFO]  snarkJS: OK!
```