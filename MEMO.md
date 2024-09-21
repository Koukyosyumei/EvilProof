# Zero-Knowledge Proof (ZKP) Development and Security

## Architecture of ZKP Systems

ZKP systems are typically structured in four layers, each serving a distinct purpose in the development and implementation process:

### Circuit Layer

At the foundation lies the Circuit Layer, where developers craft the logic of their ZKP application. This is done using Domain-Specific Languages (DSLs) or embedded DSLs like Circom or Halo2. The circuits created here serve two crucial functions:

1. Computing output values
2. Constructing constraints for the input witness

### Frontend Layer

The Frontend Layer acts as an intermediary, processing the circuit created in the layer below. Its primary functions include:

- Compilation: Transforms the circuit into a set of constraints, often in an arithmetization format such as R1CS (Rank-1 Constraint System).

- Witness Generation: Produces a witness based on the circuit's logic, taking both public and private inputs into account.

For instance, the Circom compiler supports this type of witness generation.

### Backend Layer

The Backend Layer implements the core functions of a SNARK (Succinct Non-Interactive Argument of Knowledge). Tools like the snarkjs toolchain provide three main functionalities:

- Setup: Initializes the proving system
- Prove: Generates proofs
- Verify: Validates the generated proofs

### Integration Layer

The topmost layer, the Integration Layer, bridges the ZKP system with external applications. For example, it might include smart contracts that interact with on-chain verifiers to:

- Verify submitted proofs
- Implement logic based on the verification outcome

## Security Considerations in ZKP Systems

When evaluating the security of ZKP systems, three primary concerns emerge:

### Soundness

- Threat: A malicious prover convincing a verifier of a false statement.
- Impact: Compromises the integrity of the entire system.

### Completeness

- Threat: Inability to verify valid proofs or produce proofs for valid statements.
- Impact: Renders the system unreliable or unusable.

### Zero-Knowledge Property

- Threat: Information leakage about the private witness.
- Impact: Violates privacy guarantees, potentially exposing sensitive data.

## Common Vulnerabilities in ZKP Circuits

Most reported ZKP-related vulnerabilities occur in the Circuit Layer and can be categorized as follows:

### Underconstraint Vulnerabilities

- Description: Insufficient constraints in the circuit.
- Impact: Can lead to critical soundness errors, allowing false proofs to be accepted.

### Overconstrained Vulnerabilities

- Description: Excessive constraints in the circuit.
- Impact: May cause rejection of valid witnesses by honest provers or benign proofs by honest verifiers.

### Computation/Hint Errors

- Description: Errors in the computational part of a circuit.
- Impact: Can lead to incorrect results or unexpected behavior.

## Analysis Tools for ZKP Systems

Several tools have been developed to analyze and verify ZKP systems:

### Static Analysis Tools

These tools rely on pattern matching and heuristics to identify potential issues:

- Circomspect: Static analyzer for Circom
- ZKAP: Another static analyzer for Circom
- halo2-analyzer: Static analyzer for Halo2

These tools are typically limited to specific vulnerability patterns and support only particular DSLs or eDSLs.

### Dynamic Analysis and Fuzzing

- SnarkProbe: A security analysis framework for SNARKs that can analyze R1CS-based libraries and applications. It detects various issues such as edge case crashing, errors, and inconsistencies.

### Formal Verification Tools

These tools provide more rigorous analysis:

- Picus: Uses symbolic execution to verify that Circom circuits are not under-constrained.
- CIVER: Employs a modular technique to verify properties of Circom circuits using pre- and post-conditions.
- horus-checker: Performs formal verification of Cairo smart contracts using SMT solvers.
- Medjai: A symbolic evaluator for Cairo programs.
- DSLs like Coda and Leo: Support formal verification of circuits through synthesis.
- Transpiler from Gnark to Lean: Compiles zero-knowledge circuits from Gnark to the Lean theorem prover for formal verification.

## Circom: A Closer Look

Circom requires all constraints to be expressed as quadratic equations. However, developers can implement more complex algorithms by separating computation from constraints. For example:

```
template Divider() {
    signal input a;
    signal input b;
    signal output c;
    c <-- a/b;
    a === b * c;
}
```

In this example, the division operation c = a / b is computed separately, while the constraint a === b * c ensures the correctness of the result within the quadratic constraint system. Such **deviant between the computation and the constraint** sometimes lead to under/over constraints vulnerabilities.

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
| **Blogs** | The State of Security Tools for ZKPs | [Link](https://www.zksecurity.xyz/blog/posts/zksecurity-tools/) |
