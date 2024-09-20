pragma circom 2.0.0;


/**
 * @template Add32Bits
 * @description This circuit adds two 32-bit numbers (`a` and `b`) but contains a **malicious flaw**. The `tmp` signal, 
 *              which is supposed to represent an overflow flag, is hardcoded to `1`, meaning the circuit manipulates the 
 *              overflow condition. As a result, the circuit can produce an incorrect output by improperly adjusting for 
 *              overflow even when it doesn't occur.
 *
 * @input {signal} a - The first 32-bit input number.
 * @input {signal} b - The second 32-bit input number.
 * @output {signal} out - The output signal representing the sum of `a` and `b`. This is manipulated by the hardcoded 
 *                        `tmp` value, which causes the result to be incorrect.
 *
 * @malicious_behavior Normally, the `tmp` signal should represent whether an overflow has occurred in the addition 
 *                      of two 32-bit numbers (`a + b`). If `tmp = 1`, it means an overflow occurred, and the result 
 *                      should wrap around to fit within 32 bits. 
 *                      However, in this malicious circuit, `tmp` is **hardcoded to 1**, forcing the output to always 
 *                      subtract the overflow value `(0xFFFFFFFF + 1)` even when there is no overflow.
 * 
 * @vulnerability The hardcoding of `tmp = 1` results in incorrect addition. This flaw makes it possible to intentionally 
 *                produce incorrect results by wrongly simulating an overflow condition, even when none exists.
 *
 * @example 
 * - Expected behavior:
 *   - `a + b` without overflow should produce the correct sum.
 *   - If overflow occurs, the result should wrap within 32 bits.
 * 
 * - Malicious behavior:
 *   - The result will always subtract the overflow value `(0xFFFFFFFF + 1)`, regardless of whether an overflow occurred, 
 *     leading to incorrect output.
 */
template Add32Bits() {
    signal input a;     // First 32-bit input number.
    signal input b;     // Second 32-bit input number.
    signal tmp;         // Temporary signal representing the overflow flag, hardcoded to 0.
    signal output out;  // The result of the addition (without overflow handling).

    // Maliciously hardcoded overflow flag. Normally, this should depend on the result of `a + b`, 
    // but here it is intentionally set to `1` to simulate an overflow even when none occurs.
    tmp <-- 1;

    // Constraint to ensure `tmp` is a valid binary value (0 or 1). Although valid, `tmp` is hardcoded, 
    // leading to malicious behavior.
    tmp * (tmp - 1) === 0;

    // Output calculation: the result is reduced by `0xFFFFFFFF + 1`, simulating an overflow. 
    // This leads to incorrect results for any input.
    out <== (a + b) - (tmp * (0xFFFFFFFF + 1));
}


/**
 * @component main
 * @description The `main` component uses the malicious `Add32Bits` template to add two public 32-bit input numbers. 
 *              Due to the hardcoded overflow flag (`tmp = 1`), the result is always incorrect, simulating an overflow 
 *              condition even when there is none.
 *
 * @input {signal} a - The first public input number.
 * @input {signal} b - The second public input number.
 * @output {signal} out - The manipulated output of `a + b`, which subtracts the overflow value due to the hardcoded 
 *                        overflow flag.
 */
component main = Add32Bits();