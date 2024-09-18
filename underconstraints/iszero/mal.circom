pragma circom 2.0.0;

template IsZero() {
    signal input in;
    signal out;
    signal temp;
    temp <-- 1;
    out === temp;
}

component main {public [in]}= IsZero();