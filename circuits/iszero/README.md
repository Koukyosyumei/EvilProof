# IsZero

The `IsZero()` template is intended to check if the input in is zero. It should output 1 if in is zero, and 0 otherwise. Here's how it's supposed to work:

1. If `in` is not zero, inv is set to its reciprocal `(1/in)`.
2. If `in` is zero, `inv` is set to 0.
3. The output `out` is calculated as `-in * inv + 1`.

In theory, this should result in out being 1 when in is 0, and 0 otherwise.

## Vulnerability

The vulnerability lies in the use of `<--` for assigning `inv`:

```
inv <-- in!=0 ? 1/in : 0;
```

This operator only assigns a value during the witness generation phase **but does not create a constraint**. As a result, a malicious prover can assign any value to `inv` without violating any constraints.

A malicious prover can modify the circuit to always output 1, regardless of the input:

```
inv <-- 0;
```

By setting `inv` to 0, the output calculation becomes:

```
out = -in * 0 + 1 = 1
```

This allows the prover to generate a valid proof for the statement *the input is zero* even when it's not, completely breaking the intended functionality of the circuit.

## Mitigation

To fix this vulnerability, insert the following constraint:

```
in*out === 0;
```

The updated `IsZero()` template introduces two key constraints:

1. `out <== -in*inv + 1`
2. `in*out === 0`

These constraints work together to ensure the correct behavior of the circuit.


- Case 1: Input is Zero

1. The second constraint (`in*out === 0`) is automatically satisfied.
2. The first constraint becomes out = `-0*inv + 1 = 1`.

This correctly sets out to 1 when the input is zero.

- Case 2: Input is Non-Zero

1. The second constraint (`in*out === 0`) forces out to be 0.
2. The first constraint then becomes `-in*inv + 1` = 0.
3. This implies `in*inv = 1`, meaning `inv = 1/in`.

This matches the assignment `inv <-- in!=0 ? 1/in : 0`.


## Script

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