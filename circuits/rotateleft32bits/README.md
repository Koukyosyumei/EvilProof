# RotateLeft32Bits

The `RotateLeft32Bits` circuit, designed to perform a left rotation on a 32-bit input, contains a critical vulnerability that allows an attacker to manipulate the circuit's behavior.

The vulnerability in the malicious circuit stems from the following modifications:

1. Hardcoded Values: The attacker replaces the dynamic calculations of `part1` and `part2` with hardcoded values. `part1` is set to -8589934552, and `part2` is set to 2.

2. Constraint Manipulation: The constraint equation remains unchanged, but due to the hardcoded values, it no longer accurately represents the left rotation operation.

3. Loss of Input Dependency: The circuit no longer depends on the actual input value in for its internal calculations, making it susceptible to accepting invalid inputs.

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