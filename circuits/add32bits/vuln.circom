pragma circom 2.0.0;

// reference: https://www.zksecurity.xyz/reports/reclaim

template Add32Bits() {
    signal input a;
    signal input b;
    signal tmp;
    signal out;

    tmp <-- (a + b) >= (0xFFFFFFFF + 1) ? 1 : 0;
    tmp * (tmp - 1) === 0;
    out <== (a + b) - (tmp * (0xFFFFFFFF + 1));
}

component main {public [a, b]} = Add32Bits();