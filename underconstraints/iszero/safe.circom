pragma circom 2.0.0;

/*
the first constraint: `out == -in * inv + 1`
the second constraint: `in * out == 0`

(i) `in = 0`

The second constraint is immediately satisfied.
In addition, `out` should be 1 because of the first constraint.  

(ii) `in != 0`

The second constraint forces `out` to be 0. 
Then, the first constraint gives `in * inv == 1`, indicating that `inv = 1/in`.
This matches with the assignment operation `inv <-- in!=0 ? 1/in : 0;`.
*/

template IsZero() {
    signal input in;
    signal output out;
    signal inv;
    inv <-- in!=0 ? 1/in : 0;
    out <== -in*inv +1;
    in*out === 0;
}

component main {public [in]}= IsZero();