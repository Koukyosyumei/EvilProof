# Zero-Knowledge Proof (ZKP) Development and Security

## 1. Core Concepts

### 1.1 *Zero-Knowledge Proofs (ZKPs)*

Zero-knowledge proofs are a cryptographic method that allows one party (the prover) to prove to another party (the verifier) that they know a piece of information, without revealing the information itself. ZKPs have three key properties:

- *Completeness*: An honest prover can convince an honest verifier of a true statement.
- *Soundness*: A dishonest prover cannot convince the verifier of a false statement.
- *Zero-knowledge*: The verifier learns nothing beyond the truth of the statement.

Real-world applications of ZKPs include:

- Identity verification without disclosing personal data
- Proving sufficient funds for a transaction without revealing the exact balance
- Validating blockchain transactions while maintaining privacy

### 1.2 *zk-SNARKs*

zk-SNARK (Zero-Knowledge Succinct Non-Interactive Argument of Knowledge) is a popular type of ZKP with two distinguishing features:

- **Succinct**: Proofs are small and quick to verify, regardless of the statement's complexity.
- **Non-interactive**: The proof requires only one message from prover to verifier.

Notable zk-SNARK variants include:

- **Groth16**: Requires a trusted setup for each circuit.
- **PLONK**: Can use one trusted setup for multiple circuits.

### 1.3 Key Concepts in ZKP Implementation

1. *Constraints*

In ZKP systems, statements are represented as constraints rather than instructions. Different implementations support various types of constraints:

- [Circom](https://docs.circom.io/) supports quadratic expressions
- [Halo2](https://zcash.github.io/halo2/) allows polynomial constraints of any degree

2. *Finite fields*

ZKP arithmetic operates in finite fields, with the field size determined by the underlying elliptic curve. This means all operations are computed modulo a specific value.

## 2. ZKP System Architecture

ZKP systems typically consist of four layers:

1. **Circuit Layer**: Developers create the logic using DSLs/eDSLs like Circom or Halo2.
2. **Frontend Layer**: Compiles the circuit into constraints and generates witnesses.
3. **Backend Layer**: Implements core SNARK functions (Setup, Prove, Verify).
4. **Integration Layer**: Connects the ZKP system with external applications.

### 2.1 Circuit Layer

At the base of any ZKP system is the Circuit Layer, where developers define the core logic of the proof system. This is achieved using DSLs, such as Circom or Halo2, which allow the creation of circuits that represent computations. These circuits serve two main purposes

1. To compute output values from inputs.
2. To define constraints on the witness, which is a representation of all intermediate and output values for a given input.

### 2.2 Frontend Layer

The Frontend Layer acts as the intermediary between the logic defined in the Circuit Layer and the rest of the ZKP system. Its key responsibilities include:

- Compilation: Translates the circuit into constraints, typically in a format such as R1CS (Rank-1 Constraint System), which is used to define the relationships between variables in a way that can be proved in zero-knowledge.

- Witness Generation: Produces a witness based on both public and private inputs. The witness is a set of concrete values that satisfy the circuit's constraints for a given input.

For instance, Circom’s compiler can transform a circuit into its corresponding R1CS form and generate the witness based on the provided inputs.

### 2.3 Backend Layer

The Backend Layer is responsible for the core functionality of the zero-knowledge proof system. This layer is where key cryptographic operations take place. Using tools like the snarkjs toolchain, the following primary tasks are performed:

- Setup: Initializes the proving system, which may include generating cryptographic parameters (for example, with a trusted setup in systems like Groth16).
- Prove: Generates a proof based on the witness and the circuit's constraints, without revealing any sensitive information.
- Verify: Validates that a given proof is correct and that the input satisfies the circuit’s constraints.

### 2.4 Integration Layer

t the top, the Integration Layer connects the ZKP system with external applications or platforms. This could involve integrating with smart contracts, decentralized applications, or traditional systems. In a blockchain context, smart contracts might verify proofs and take actions based on the results of the verification.

For example, a smart contract could use an on-chain verifier to:

- Validate a submitted proof.
- Trigger contract logic based on whether the proof is valid.

## 3. Implementing a ZKP System: A Practical Example

Let's walk through the process of implementing a simple ZKP system using the `IsZero` circuit, which checks if an input is zero or non-zero.

### 3.1. Circuit Implementation (using Circom)

```
template IsZero() {
    signal input in;    // Input signal to check if it's zero or non-zero.
    signal output out;  // Output signal: 1 if `in == 0`, 0 if `in != 0`.
    signal inv;         // Inverse of the input when `in != 0`, or 0 when `in == 0`.
    
    // Compute the inverse: if `in` is non-zero, `inv` is set to `1/in`, otherwise it's 0.
    inv <-- in!=0 ? 1/in : 0;

    // Constraint 1: Ensures that if `in != 0`, `out` is 0. If `in == 0`, `out` is 1.
    out <== -in*inv +1;

    // Constraint 2: Ensures that `in * out == 0`, forcing the output to 1 only when `in == 0`.
    in*out === 0;
}

// there is no public input
component main = IsZero();
```

### 3.2. Compilation

Compile the circuit using Circom, which generates the necessary constraint system and related files:

```bash
circom iszero.circom --r1cs --wasm --sym --c
```

This step translates the circuit into its R1CS form and creates files necessary for generating witnesses and proving the circuit.

### 3.3. Trusted Setup (if required)

In protocols like Groth16, a trusted setup is required. This involves generating the proving and verifying keys.

```bash
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
```

### 3.4. Witness Generation

The witness is a set of intermediate and output values for a given input, which will later be used to generate the proof:

```bash
node iszero_js/generate_witness.js iszero.wasm input.json iszero_witness.wtns
```

For Groth16, we also perform a circuit-specific setup:

```bash
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup iszero.r1cs pot12_final.ptau iszero_0000.zkey
snarkjs zkey contribute iszero_0000.zkey iszero_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey iszero_0001.zkey iszero_verification_key.json
```

### 3.5. Proof Generation

After generating the witness, we can produce the zero-knowledge proof using Groth16 or another SNARK protocol:

```bash
snarkjs groth16 prove iszero_0001.zkey iszero_witness.wtns iszero_proof.json iszero_public.json
```

### 3.6. Verification

Finally, the proof can be verified using the verification key and public inputs:

```bash
snarkjs groth16 verify iszero_verification_key.json iszero_public.json iszero_proof.json
```

If the proof is valid, the system confirms that the provided input satisfies the `IsZero` circuit logic, ensuring correctness without revealing sensitive information.

## 4. Security Considerations in ZKP Systems

When evaluating the security of ZKP systems, three primary concerns emerge:

1. **Soundness**

- Threat: A malicious prover convincing a verifier of a false statement.
- Impact: Compromises the integrity of the entire system.

2. **Completeness**

- Threat: Inability to verify valid proofs or produce proofs for valid statements.
- Impact: Renders the system unreliable or unusable.

3. **Zero-Knowledge Property**

- Threat: Information leakage about the private witness.
- Impact: Violates privacy guarantees, potentially exposing sensitive data.


## 5. Common Vulnerabilities in ZKP Circuits

Most reported ZKP-related vulnerabilities occur in the Circuit Layer and can be categorized as follows:

1. **Underconstraint Vulnerabilities**

- Description: Insufficient constraints in the circuit.
- Impact: Can lead to critical soundness errors, allowing false proofs to be accepted.

2. **Overconstrained Vulnerabilities**

- Description: Excessive constraints in the circuit.
- Impact: May cause rejection of valid witnesses by honest provers or benign proofs by honest verifiers.

3. **Computation/Hint Errors**

- Description: Errors in the computational part of a circuit.
- Impact: Can lead to incorrect results or unexpected behavior.

## 6. Analysis Tools for ZKP Systems

Several tools have been developed to analyze and verify ZKP systems:

### 6.1 Static Analysis Tools

These tools rely on pattern matching and heuristics to identify potential issues:

- Circomspect: Static analyzer for Circom
- ZKAP: Another static analyzer for Circom
- halo2-analyzer: Static analyzer for Halo2

These tools are typically limited to specific vulnerability patterns and support only particular DSLs or eDSLs.

### 6.2 Dynamic Analysis and Fuzzing

- SnarkProbe: A security analysis framework for SNARKs that can analyze R1CS-based libraries and applications. It detects various issues such as edge case crashing, errors, and inconsistencies.

### 6.3 Formal Verification Tools

These tools provide more rigorous analysis:

- Picus: Uses symbolic execution to verify that Circom circuits are not under-constrained.
- CIVER: Employs a modular technique to verify properties of Circom circuits using pre- and post-conditions.
- horus-checker: Performs formal verification of Cairo smart contracts using SMT solvers.
- Medjai: A symbolic evaluator for Cairo programs.
- DSLs like Coda and Leo: Support formal verification of circuits through synthesis.
- Transpiler from Gnark to Lean: Compiles zero-knowledge circuits from Gnark to the Lean theorem prover for formal verification.

## 7. Circom: A Closer Look

### Signals

Circuits in Circom work with signals, which are elements (or arrays of elements) from a finite field. These signals are declared using the keyword `signal`. Signals can be labeled as either `input` or `output`. If a signal is not explicitly marked as either, it is treated as an intermediate signal. When given an input signal, the witness generator produced by the Circom compiler calculates the values of all intermediate and output signals.

### Operators

The Circom compiler is responsible for generating both the witness calculator program and the Rank-1 Constraint System (R1CS) constraints. To do this, it provides several operators that are used to express both computations (for witness calculation) and constraints (for constraint generation).

For example, the operators `<--` and `-->` are used for signal assignment, which is critical for witness generation. Meanwhile, the `===` operator is used for constraint generation. A statement like `a === b` tells the Circom compiler to generate a circuit that ensures `a` and `b` are equal. Circom offers the additional operators `<==` and `==>`, which perform both assignment and constraint generation at the same time. Note that any constraint in Circom should be a quadratic equation.

### Execution vs Constraints

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

## 8. Papers

#### [SoK: What Don’t We Know? Understanding Security Vulnerabilities in SNARKs](https://arxiv.org/pdf/2402.15293)


#### [Zero-Knowledge Proof Vulnerability Analysis and Security Auditing](https://eprint.iacr.org/2024/514.pdf)

#### [The Ouroboros of ZK: Why Verifying the Verifier Unlocks Longer-Term ZK Innovation](https://eprint.iacr.org/2024/768.pdf)

#### [CLAP: a Semantic-Preserving Optimizing eDSL for Plonkish Proof Systems](https://arxiv.org/pdf/2405.12115)

#### [An SMT-LIB Theory of Finite Fields](https://ceur-ws.org/Vol-3725/paper3.pdf)

#### [Weak Fiat-Shamir Attacks on Modern Proof Systems](https://eprint.iacr.org/2023/691.pdf)

#### [SNARKProbe: An Automated Security Analysis Framework for zkSNARK Implementations](https://link.springer.com/chapter/10.1007/978-3-031-54773-7_14)

#### [Scalable Verification of Zero-Knowledge Protocols](https://www.computer.org/csdl/proceedings-article/sp/2024/313000a133/1Ub23QzVaWA)

#### [The Last Challenge Attack: Exploiting a Vulnerable Implementation of the Fiat-Shamir Transform in a KZG-based SNARK](https://eprint.iacr.org/2024/398)

#### [LEO: A Programming Language for Formally Verified,Zero-Knowledge Applications](https://docs.zkproof.org/pages/standards/accepted-workshop4/proposal-leo.pdf)

#### [Satisfiability Modulo Finite Fields](https://link.springer.com/content/pdf/10.1007/978-3-031-37703-7_8.pdf)

#### [Compositional Formal Verification of Zero-Knowledge Circuits](https://eprint.iacr.org/2023/1278.pdf)

#### [SMT Solving over Finite Field Arithmetic](https://arxiv.org/pdf/2305.00028)

#### [Formal Verification of Zero-Knowledge Circuits](https://arxiv.org/pdf/2311.08858)

#### [Automated Analysis of Halo2 Circuits](https://eprint.iacr.org/2023/1051.pdf)

#### [Bounded Verification for Finite-Field-Blasting](https://link.springer.com/content/pdf/10.1007/978-3-031-37709-9_8.pdf)

#### [Certifying Zero-Knowledge Circuits with Refinement Types](https://eprint.iacr.org/2023/547.pdf)

#### [Automated Detection of Under-Constrained Circuits in Zero-Knowledge Proofs](https://dl.acm.org/doi/pdf/10.1145/3591282)

#### [Practical Security Analysis of Zero-Knowledge Proof Circuits](https://www.cs.utexas.edu/~isil/zkap.pdf)
  
>Tag: `circom`, `static analysis`

*Overview*: This paper presents **ZKAP**, the heuristic-based tool for detecting common vulnerabilities in Circom, a popular DSL for building zero-knowledge proof (ZKP) circuits. The design of ZKAP is based on a manual study of existing Circom vulnerabilities, which helped classify the root causes of bugs into three main categories:

- Nondeterministic signals: Input or output signals are not properly constrained.
- Unsafe component usage: Components are used incorrectly, leading to signal errors.
- Constraint-computation discrepancies: Mismatches occur between witness generation and constraint enforcement.

*Threat Model*: The analysis assumes a trustless environment where attackers have full access to public information, including blockchain states, deployed smart contracts, and ZK circuit source code. Attackers can also deploy their own contracts and ZK applications to interact with the target system.

*Method*: To detect these vulnerabilities, the authors introduced the *circuit dependence graph (CDG)*, an abstraction that captures key properties of Circom circuits to identify semantic vulnerability patterns. ZKAP uses this graph to implement static checkers that detect vulnerabilities through anti-patterns described in a Datalog-style language.

*Experiment*: The tool was evaluated on 258 Circom circuits from popular projects on GitHub, achieving an F1 score of 0.82.

## 9. Resource

| **Category** | **Title** | **Link** |
|--------------|-----------|----------|
|  | Zero-Knowledge Proof Vulnerability Analysis and Security Auditing | [Link](https://eprint.iacr.org/2024/514.pdf) |
| **Repos** | Awesome Zero-Knowledge Proofs Security | [Link](https://github.com/Xor0v0/awesome-zero-knowledge-proofs-security?tab=readme-ov-file) |
|  | Awesome ZKP Security | [Link](https://github.com/StefanosChaliasos/Awesome-ZKP-Security?tab=readme-ov-file) |
|  | Picus | [Link](https://github.com/chyanju/Picus) |
| **Blogs** | The State of Security Tools for ZKPs | [Link](https://www.zksecurity.xyz/blog/posts/zksecurity-tools/) |
|           | A beginner's intro to coding zero-knowledge proofs| [Link](https://dev.to/spalladino/a-beginners-intro-to-coding-zero-knowledge-proofs-c56) |
