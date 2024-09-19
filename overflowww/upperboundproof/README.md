# UpperBoundProof

The `vuln.circom` implements the following three templates.

- `UnSafeNum2Bits(n)`

This template converts an input number in into its binary representation stored in `out[n]`.

The binary representation is computed by right-shifting in and extracting the least significant bit using `(in >> i) & 1`.

The line `out[i] * (out[i] - 1) === 0` ensures that each bit in the output is either 0 or 1 (ensuring it’s a valid binary number).

A variable lc1 accumulates the value of the bits to reconstruct the original number. However, the final check `lc1 === in` is commented out, leaving this safety mechanism disabled, which leads to unchecked behavior.

- `UnSafeLessThan(n)`

This template checks whether one number is less than another.

It uses the UnSafeNum2Bits template to convert the result of the comparison into binary form.

The component calculates `in[0] + (1 << n) - in[1]`, comparing `in[0]` and `in[1]`.

The unsafe behavior arises from the fact that the comparison is not properly protected from overflows, and thus the system is susceptible to incorrect behavior when numbers exceed expected limits.

- `UpperBoundProof(bits, max_abs_value)`

The final template uses the UnSafeLessThan component to verify that a given input in is bounded by `max_abs_value`.

It compares `2 * max_abs_value` with `max_abs_value + in`. This is intended to ensure in does not exceed the upper bound of `max_abs_value`.

However, if in is large enough to cause an overflow in the arithmetic expression `max_abs_value + in`, the circuit may produce an incorrect result, bypassing the bounds check.

## Script

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