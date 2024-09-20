pragma circom 2.0.0;

/**
 * @template IsZero
 * @description This circuit is a **malicious modification** of a zero-checking circuit. It outputs `1` regardless 
 *              of the value of the input (`in`) due to the manipulation of the inverse (`inv`) signal. The output 
 *              is supposed to reflect whether the input is zero or non-zero, but the inverse has been intentionally 
 *              set to `0`, bypassing the correct functionality.
 *
 * @input {signal} in - The input signal to be checked for zero or non-zero.
 * @output {signal} out - The output signal:
 *                        - `1` for all values of `in`, regardless of whether `in == 0` or `in != 0`.
 *
 * @malicious_behavior The correct behavior of this circuit should involve calculating the inverse `inv` such that:
 *                     - When `in != 0`, `inv = 1/in`, forcing `out = 0`.
 *                     - When `in == 0`, `inv = 0`, forcing `out = 1`.
 *                     However, by setting `inv <-- 0` for all cases, the output will always be `1` regardless 
 *                     of the input, effectively rendering the circuit meaningless and malicious.
 *
 * @vulnerability This design flaw undermines the circuit's intended functionality and can be exploited to bypass 
 *                the correct zero-checking behavior, allowing false results to be generated.
 */
template IsZero() {
    signal input in;    // Input signal to check if it's zero or non-zero.
    signal output out;  // Output signal: always `1`, regardless of input.
    signal inv;         // Maliciously set to `0` to force incorrect behavior.
    
    // Malicious inverse calculation: `inv` is always 0, regardless of whether `in == 0` or `in != 0`.
    inv <-- 0;
    // inv <-- in!=0 ? 1/in : 0;
    
    // Constraint to calculate `out`: since `inv` is 0, the result will always be 1.
    out <== -in*inv +1;
}


/**
 * @component main
 * @description The main component using the malicious `IsZero` template to falsely claim that all inputs are zero. 
 *              The output will always be `1`, even when the input is non-zero, due to the manipulated inverse (`inv`).
 *
 * @input {signal} in - A public input to be checked for zero or non-zero.
 * @output {signal} out - Always returns `1` due to the malicious manipulation of the inverse.
 */
component main = IsZero();