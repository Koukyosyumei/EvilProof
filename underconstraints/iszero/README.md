# IsZERO

- build

```bash
$  sh ./setup.sh

$  sh ./build.sh safe
$  sh ./build.sh vuln
```

- attack

```bash
$  sh attack.sh mal safe
$  snarkjs groth16 verify build/safe_verification_key.json build/safe_public.json build/mal_proof.json
[ERROR] snarkJS: Invalid proof
```

```bash
$  sh attack.sh mal vuln
$  snarkjs groth16 verify build/vuln_verification_key.json build/vuln_public.json build/mal_proof.json
```