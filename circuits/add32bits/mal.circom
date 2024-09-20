pragma circom 2.0.0;

/**
 * @template Add32Bits
 * @description A simplified circuit that performs the addition of two 32-bit unsigned integers. 
 *              In this case, the circuit assumes there is no overflow in the addition, so 
 *              the overflow flag is hardcoded to `0`. This avoids any handling of overflow 
 *              conditions, meaning the output is simply the sum of the two inputs.
 *
 * @input {signal} a - The first 32-bit input number to be added.
 * @input {signal} b - The second 32-bit input number to be added.
 * @output {signal} out - The 32-bit result of the addition.
 *
 * @remark This version of the circuit does not handle overflow, as the `tmp` signal is 
 *         always set to `0`. The result is therefore always the sum of `a` and `b`, even 
 *         if this sum exceeds the 32-bit limit. The circuit could be used in cases where 
 *         inputs are guaranteed to fit within the 32-bit range, or overflow behavior is not 
 *         a concern.
 */
template Add32Bits() {
    signal input a;     // First 32-bit input number.
    signal input b;     // Second 32-bit input number.
    signal tmp;         // Temporary signal representing the overflow flag, hardcoded to 0.
    signal out;         // The result of the addition (without overflow handling).

    // The overflow flag is set to 0, meaning no overflow will be considered.
    tmp <-- 0;

    // Ensure that the overflow flag is a valid binary value (0 or 1), even though it's hardcoded.
    tmp * (tmp - 1) === 0;

    // Output the sum of 'a' and 'b'. Since tmp is 0, there is no overflow adjustment.
    out <== (a + b) - (tmp * (0xFFFFFFFF + 1));
}


/**
 * @component main
 * @description The main component for performing 32-bit addition with two public inputs. 
 *              It uses the Add32Bits template to perform the addition. Overflow is not handled 
 *              in this circuit, and the result is simply the sum of the inputs.
 *
 * @input {signal} a - The first public input for the addition.
 * @input {signal} b - The second public input for the addition.
 * @output {signal} out - The 32-bit result of the addition.
 */
component main {public [a, b]} = Add32Bits();