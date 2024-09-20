pragma circom 2.0.0;

/**
 * @template UnSafeNum2Bits
 * @description A circuit that converts a number into its bitwise representation. 
 *              The output is an array of bits corresponding to the binary form of the input.
 * @param {integer} n - The number of bits in the output.
 *
 * @input {signal} in - The input number to be converted to bits.
 * @output {signal[]} out - An array of n bits representing the binary form of the input.
 *
 * @remark This template is called "UnSafe" because it does not ensure that the input is within the 
 *         valid range for n-bit numbers, leaving room for overflow in some cases.
 */
template UnSafeNum2Bits(n) {
    signal input in;       // Input number to be converted into binary.
    signal output out[n];  // Output array of bits (n bits).
    var lc1=0;             // Accumulator for reconstructing the number from its bits.

    var e2=1;              // A power of 2 for binary decomposition.
    for (var i = 0; i<n; i++) {
        // Extract the i-th bit by right-shifting the input and applying a bitmask.
        out[i] <-- (in >> i) & 1;

        // Constrain each bit to be either 0 or 1.
        out[i] * (out[i] -1 ) === 0;
        
        // Accumulate the current bit multiplied by its corresponding power of 2.
        lc1 += out[i] * e2;

        // Move to the next power of 2.
        e2 = e2+e2;
    }

    // Uncomment the following line to enforce that the binary reconstruction matches the original input.
    //lc1 === in;
}


/**
 * @template UnSafeLessThan
 * @description A circuit that checks whether one number is less than another using bitwise comparison. 
 *              The comparison is "unsafe" because it does not rigorously check the range of the inputs.
 * @param {integer} n - The bit length of the numbers being compared (must be <= 252).
 *
 * @input {signal[]} in - An array containing two input signals to be compared.
 * @output {signal} out - The result of the comparison (1 if in[0] < in[1], 0 otherwise).
 *
 * @remark The circuit uses binary decomposition to evaluate whether in[0] is less than in[1].
 */
template UnSafeLessThan(n) {
    assert(n <= 252);    // Ensure that the bit length does not exceed 252 bits.
    signal input in[2];  // Two input numbers to compare. 
    signal output out;   // Output: 1 if in[0] < in[1], else 0.

    // Convert the difference between the two numbers to bits.
    component n2b = UnSafeNum2Bits(n+1);

    // Compare by evaluating if in[0] + (1 << n) - in[1] is non-negative.
    n2b.in <== in[0]+ (1<<n) - in[1];

    // The n-th bit of the output will be 1 if the result is negative, indicating in[0] < in[1].
    out <== 1-n2b.out[n];
}


/**
 * @template UpperBoundProof
 * @description A circuit that proves an input number is less than or equal to a specified maximum absolute value.
 *              This is achieved by comparing the input with the provided upper bound.
 * @param {integer} bits - The number of bits used in the comparison.
 * @param {integer} max_abs_value - The maximum allowable value for the input.
 *
 * @input {signal} in - The input number to check.
 * @output {signal} out - The result of the upper bound check (1 if in <= max_abs_value, 0 otherwise).
 *
 * @remark The circuit checks the condition 2 * max_abs_value >= max_abs_value + in, which implies max_abs_value >= in.
 */
template UpperBoundProof(bits, max_abs_value) {
    signal input in;    // The input to be checked against the upper bound.
    signal output out;  // The result of the comparison (1 if in <= max_abs_value, 0 otherwise).

    // Instantiate the less-than comparison circuit.
    component upperBound = UnSafeLessThan(bits);

    // Set the comparison inputs: 2 * max_abs_value and max_abs_value + in.
    upperBound.in[0] <== 2 * max_abs_value;
    upperBound.in[1] <== max_abs_value + in;
    
    // Ensure that the comparison outputs the correct result (0 means in <= max_abs_value).
    upperBound.out === 0;

    // Output 1 if the input is within bounds, 0 otherwise.
    out <== 1 - upperBound.out;
}


/**
 * @component main
 * @description The main component for proving that an input is less than or equal to 1000, using 
 *              a bit size of 16.
 *
 * @input {signal} in - The public input to be checked.
 * @output {signal} out - The result of the upper bound proof.
 */
component main = UpperBoundProof(16, 1000);