# RotateLeft32Bits

## Scripts

- setup

```bash
sh script/setup.sh

sh script/build.sh vuln
```

- attack

```bash
sh script/attack.sh mal vuln
snarkjs groth16 verify build/vuln_verification_key.json build/vuln_public.json build/mal_proof.json
>>>[INFO]  snarkJS: OK!
```