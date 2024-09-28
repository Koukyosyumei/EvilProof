pragma circom 2.0.0;

// reference: https://www.zksecurity.xyz/reports/reclaim


/**
 * @template Add32Bits
 * @description A circuit that performs the addition of two 32-bit unsigned integers, 
 *              ensuring that the result wraps around according to 32-bit arithmetic rules. 
 *              If the sum of the two inputs exceeds 32 bits (greater than 0xFFFFFFFF), the 
 *              circuit handles the overflow and outputs the correct 32-bit result.
 *
 * @input {signal} a - The first 32-bit input number to be added.
 * @input {signal} b - The second 32-bit input number to be added.
 * @output {signal} out - The 32-bit result of the addition, with overflow correctly handled.
 *
 * @remark This circuit uses modular arithmetic to simulate 32-bit overflow behavior by 
 *         subtracting 0x100000000 (2^32) when the sum exceeds 32 bits. 
 *         The output behaves as if the numbers were wrapped within the 32-bit range.
 */
template Add32Bits() {
    signal input a;     // First 32-bit input number.
    signal input b;     // Second 32-bit input number.
    signal tmp;         // Temporary signal to store the overflow flag.
    signal output out;  // The 32-bit result of the addition.

    // Check if the sum of 'a' and 'b' exceeds the 32-bit limit (0xFFFFFFFF).
    tmp <-- (a + b) >= (0xFFFFFFFF + 1) ? 1 : 0;

    // Ensure that the overflow flag (tmp) is either 0 or 1.
    tmp * (tmp - 1) === 0;
    
    // If overflow occurs, subtract 0x100000000 (2^32) from the result to simulate wrap-around.
    out <== (a + b) - (tmp * (0xFFFFFFFF + 1));
}


/**
 * @component main
 * @description The main component for performing 32-bit addition with two public inputs. 
 *              It uses the Add32Bits template to ensure correct 32-bit arithmetic behavior.
 *
 * @input {signal} a - The first public input for the addition.
 * @input {signal} b - The second public input for the addition.
 * @output {signal} out - The 32-bit result of the addition.
 */
component main = Add32Bits();