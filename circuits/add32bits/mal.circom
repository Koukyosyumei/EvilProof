pragma circom 2.0.0;

template Add32Bits {
    signal input a;
    signal input b;
    signal output out;

    tmp <-- 0;
    tmp * (tmp - 1) === 0;
    out <== (a + b) - (tmp * (0xFFFFFFFF + 1));
}

component main = Add32Bits();