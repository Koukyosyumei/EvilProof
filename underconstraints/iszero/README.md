# IsZERO

- build

```bash
sh script/setup.sh

sh script/build.sh safe
sh script/build.sh vuln
```

- attack

```bash
sh script/attack.sh mal safe
snarkjs groth16 verify build/safe_verification_key.json build/safe_public.json build/mal_proof.json
>>> [ERROR] snarkJS: Invalid proof
```

```bash
sh script/attack.sh mal vuln
snarkjs groth16 verify build/vuln_verification_key.json build/vuln_public.json build/mal_proof.json
>>> [INFO]  snarkJS: OK!
```