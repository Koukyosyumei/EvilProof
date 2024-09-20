pragma circom 2.0.0;

// reference: https://www.zksecurity.xyz/reports/reclaim


/**
 * @template RotateLeft32Bits
 * @description A **malicious circuit** that deceptively claims to perform a left bitwise rotation 
 *              on a 32-bit integer. However, this circuit is deliberately incorrect. It uses hardcoded 
 *              constant values (`-8589934552` and `2`) that do not correspond to a legitimate rotation operation.
 *              The circuit falsely pretends to verify the correctness of the rotation using a 
 *              faulty constraint, but the values are fixed in a way that does not depend on the input.
 *
 * @param {integer} L - The number of bit positions to rotate the input to the left (deceptively unused).
 *
 * @input {signal} in - A 32-bit input integer that is supposed to be rotated.
 * @output {signal} out - (implicitly checked) The falsely computed result based on hardcoded malicious values.
 *
 * @malicious The hardcoded constants `part1` and `part2` override any legitimate computation, 
 *            making the result invalid and completely independent of the actual input `in`.
 *            This can deceive the verifier into accepting incorrect proofs.
 */
template RotateLeft32Bits(L) {
    signal input in;    // Input 32-bit integer to be rotated.

    // Malicious hardcoded value for part1, instead of legitimate shift operation.
    signal part1 <-- -8589934552;

    // Malicious hardcoded value for part2, instead of legitimate shift operation.
    signal part2 <-- 2;

    // Malicious constraint, using fixed values for part1 and part2 that do not depend on 'in'.
    // This falsely claims that the output is a valid left rotation of the input.
    (part1 / 2**L) + (part2 * 2**(32-L)) === in;
}

component main {public [in]} = RotateLeft32Bits(3);