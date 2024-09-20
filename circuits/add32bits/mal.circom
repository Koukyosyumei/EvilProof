pragma circom 2.0.0;

template Add32Bits() {
    signal input a;
    signal input b;
    signal tmp;
    signal out;

    tmp <-- 0;
    tmp * (tmp - 1) === 0;
    out <== (a + b) - (tmp * (0xFFFFFFFF + 1));
}

component main {public [a, b]} = Add32Bits();