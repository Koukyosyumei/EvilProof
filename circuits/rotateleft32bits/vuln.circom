pragma circom 2.0.0;

// reference: https://www.zksecurity.xyz/reports/reclaim


/**
 * @template RotateLeft32Bits
 * @description A circuit that performs a left bitwise rotation (circular shift) on a 32-bit integer.
 *              The input is rotated to the left by `L` positions. The result is the rotated 
 *              representation of the input within the 32-bit range.
 *
 * @param {integer} L - The number of bit positions to rotate the input to the left.
 *
 * @input {signal} in - A 32-bit input integer to be rotated.
 * @output {signal} out - (implicitly checked) The result is the 32-bit value after a left bitwise rotation.
 *
 * @remark This circuit simulates a left bitwise rotation operation, where the bits that are 
 *         shifted out from the left are re-introduced on the right side of the 32-bit word.
 *         It ensures that the result is equivalent to the bitwise rotation of the input.
 *
 * @constraint The circuit uses a constraint `(part1 / 2**L) + (part2 * 2**(32 - L)) === in` 
 *             to verify that the output is equivalent to the original input, modulo the bitwise rotation.
 */
template RotateLeft32Bits(L) {
    signal input in;    // Input 32-bit integer to be rotated.

    // part1: The L most significant bits (shifted to the left and masked to fit within 32 bits).
    signal part1 <-- (in << L) & 0xFFFFFFFF;
    
    // part2: The bits that are "rotated" to the right after being shifted out on the left.
    signal part2 <-- in >> (32 - L);

    // Ensure the rotated value matches the original input when the rotation is reversed.
    (part1 / 2**L) + (part2 * 2**(32-L)) === in;
}

component main {public [in]} = RotateLeft32Bits(3);