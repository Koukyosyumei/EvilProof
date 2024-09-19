pragma circom 2.0.0;

template UnSafeNum2Bits(n) {
    signal input in;
    signal output out[n];
    var lc1=0;

    var e2=1;
    for (var i = 0; i<n; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] -1 ) === 0;
        lc1 += out[i] * e2;
        e2 = e2+e2;
    }

    //lc1 === in;
}

template UnSafeLessThan(n) {
    assert(n <= 252);
    signal input in[2];
    signal output out;

    component n2b = UnSafeNum2Bits(n+1);

    n2b.in <== in[0]+ (1<<n) - in[1];
    out <== 1-n2b.out[n];
}

//     2 * max_abs_value >= max_abs_value + in 
// <=> max_abs_value >= in
template UpperBoundProof(bits, max_abs_value) {
    signal input in;

    component upperBound = UnSafeLessThan(bits);

    upperBound.in[0] <== 2 * max_abs_value;
    upperBound.in[1] <== max_abs_value + in;
    upperBound.out === 0;
}

component main {public [in]} = UpperBoundProof(16, 1000);