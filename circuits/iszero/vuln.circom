pragma circom 2.0.0;

/*
the only constraint: `out == -in * inv + 1`

`out` should be equal to `-in * inv + 1`, but `inv` is free. 
If we modify `inv <-- in!=0 ? 1/in : 0` to `inv <-- 0`, the output will be always 1. 
*/

template IsZero() {
    signal input in;
    signal output out;
    signal inv;
    inv <-- in!=0 ? 1/in : 0;
    out <== -in*inv +1;
}

component main = IsZero();