pragma circom 2.0.0;

// reference: https://www.zksecurity.xyz/reports/reclaim

template RotateLeft32Bits(L) {
    signal input in;

    signal part1 <-- (in << L) & 0xFFFFFFFF;
    signal part2 <-- in >> (32 - L);
    (part1 / 2**L) + (part2 * 2**(32-L)) === in;
    //part1 === (2**L) * (in - (part2 * (2 ** (32-L))));
}

component main {public [in]} = RotateLeft32Bits(3);