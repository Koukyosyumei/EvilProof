pragma circom 2.0.0;

/*
There is only one constraint: `out == tmp`.
*/

template IsZero() {
    signal input in;
    signal out;
    signal temp;
    temp <-- in!= 0 ? 0 : 1;
    out <== temp;
}

component main {public [in]}= IsZero();