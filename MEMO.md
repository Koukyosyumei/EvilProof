# Memo

## Circom

### Splitting Between Computation and Constraints.

In Circom, all constraints must be expressed as quadratic equations. However, it’s possible to implement algorithms that involve non-quadratic operations by decoupling the computation from the constraints.

For example:

```
template Divider() {
    signal input a;
    signal input b;
    signal output c;
    c <-- a/b;
    a === b * c;
}
```

While the division `c = a / b` is not a quadratic equation, we can convert it into an equivalent quadratic constraint: `a = b * c`. By separating the computation from the constraint in this way, we can design a divider circuit that adheres to Circom’s quadratic constraint requirements.

## Resource

### Papers

| **Category** | **Title** | **Link** |
|--------------|-----------|----------|
| **Papers** | Original Paper of Circom | [Link](https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=10002421) |
|  | Automated Detection of Under-Constrained Circuits in Zero-Knowledge Proofs | [Link](https://eprint.iacr.org/2023/512.pdf) |
|  | SoK: What Don’t We Know? Understanding Security Vulnerabilities in SNARKs | [Link](https://arxiv.org/pdf/2402.15293) |
|  | Practical Security Analysis of Zero-Knowledge Proof Circuits | [Link](https://www.usenix.org/system/files/usenixsecurity24-wen_1.pdf) |
|  | Zero-Knowledge Proof Vulnerability Analysis and Security Auditing | [Link](https://eprint.iacr.org/2024/514.pdf) |
| **Repos** | Awesome Zero-Knowledge Proofs Security | [Link](https://github.com/Xor0v0/awesome-zero-knowledge-proofs-security?tab=readme-ov-file) |
|  | Awesome ZKP Security | [Link](https://github.com/StefanosChaliasos/Awesome-ZKP-Security?tab=readme-ov-file) |
|  | Picus | [Link](https://github.com/chyanju/Picus) |
