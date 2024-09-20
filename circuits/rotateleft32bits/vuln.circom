pragma circom 2.0.0;

// reference: https://www.zksecurity.xyz/reports/reclaim


/**
 * @template RotateLeft32Bits
 * @description This circuit performs a **left bitwise rotation** on a 32-bit integer. It shifts the bits of the input 
 *              left by `L` positions, with the bits that are shifted out on the left being rotated back in from the right.
 *              This operation is commonly used in cryptographic functions or hash computations to scramble bit patterns.
 *
 * @param {number} L - The number of positions to rotate the bits to the left.
 * 
 * @input {signal} in - The input 32-bit integer to be rotated.
 * @output {signal} out - The result of rotating `in` left by `L` bits.
 *
 * @rotation_logic The bitwise left rotation of a 32-bit integer works as follows:
 *                 - The most significant `L` bits of the input are shifted left, and the overflow bits are wrapped 
 *                   around to the right.
 *                 - `part1` holds the shifted bits that stay within 32 bits.
 *                 - `part2` holds the bits that are shifted out from the left, which are then brought back to the 
 *                   right side of the output.
 *
 * @constraint The circuit ensures that when the rotated value is reversed (shifted back by `L` positions), it matches 
 *             the original input. This is verified by the constraint `(part1 / 2**L) + (part2 * 2**(32-L)) === in`.
 */
template RotateLeft32Bits(L) {
    signal input in;    // Input 32-bit integer to be rotated.
    signal output out;  // The output after performing the left rotation.

    // part1: The L most significant bits (shifted to the left and masked to fit within 32 bits).
    signal part1 <-- (in << L) & 0xFFFFFFFF;
    
    // part2: The bits that are "rotated" to the right after being shifted out on the left.
    signal part2 <-- in >> (32 - L);

    // Ensure the rotated value matches the original input when the rotation is reversed.
    (part1 / 2**L) + (part2 * 2**(32-L)) === in;

    // The final output is the combination of `part1` and `part2`, representing the rotated result.
    out <== part1 + part2;
}

component main = RotateLeft32Bits(3);