# Zero-Knowledge Proof (ZKP) Development and Security

## 1. Core Concepts

### 1.1 *Zero-Knowledge Proofs (ZKPs)*

Zero-knowledge proofs are a cryptographic method that allows one party (the prover) to prove to another party (the verifier) that they know a piece of information without revealing it. ZKPs have three fundamental properties:

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
- **Non-interactive**: The proof requires only one message from the prover to the verifier.

Notable zk-SNARK variants include:

- **Groth16**: Requires a trusted setup for each circuit.
- **PLONK**: Can use one trusted setup for multiple circuits.

### 1.3 Key Concepts in ZKP Implementation

1. *Finite fields*

ZKP arithmetic operates in finite fields, with the field size determined by the underlying elliptic curve. This means all operations are computed modulo a specific value.

2. *Constraints* and *Arithmetization*

In ZKP systems, statements to be proved are represented as constraints rather than instructions. Then, arithmetization is a crucial process in zero-knowledge proof systems that transforms computational logic into polynomial constraints. Several tools facilitate the arithmetization process:

- [Circom](https://docs.circom.io/): A compiler that translates high-level DSL into constraints (suppport R1CS). 
- [Halo2](https://zcash.github.io/halo2/): eDSL translates the specification written in Rust into constraints (support Plonkish).
- [CARIO](): A zero-knowledge virtual machine designed for arithmetization (support AIR).

While arithmetization is powerful, it does introduce computational overhead:

- Computation time can increase by nearly two orders of magnitude for SNARK-friendly operations.
- Non-friendly operations may experience even greater overhead.

To address these challenges, several optimization techniques have been developed:

- Lookup tables: Pre-computed values for common operations.
- SNARK-friendly cryptographic primitives: Algorithms like Rescue, SAVER, and Poseidon.
- Concurrent proof generation: Parallelizing the proof creation process.
- Hardware acceleration: Utilizing GPUs for faster computation.

There are several types of arithmetization, such as *R1CS*, *AIR*, and *Plonkish*. RICS only supports linear and quadratic polynomials, while AIR and Plonkish support polynomials with any order. In the case of AIR and Plonkish, we need to get the program's execution trace, establish the relationship between the rows, and interpolate polynomials.

## 2. ZKP System Architecture

ZKP systems typically consist of four layers:

1. **Circuit Layer**: Developers create the logic using DSLs/eDSLs like Circom or Halo2.
2. **Frontend Layer**: Compiles the circuit into constraints and generates witnesses.
3. **Backend Layer**: Implements core SNARK functions (Setup, Prove, Verify).
4. **Integration Layer**: Connects the ZKP system with external applications.

### 2.1 Circuit Layer

At the base of any ZKP system is the Circuit Layer, where developers define the core logic of the proof system. This is achieved using DSLs, such as Circom or Halo2, which allow the creation of circuits that represent computations. These circuits serve two main purposes

1. To compute output values from inputs.
2. To define constraints on the witness, which represents all intermediate and output values for a given input.

### 2.2 Frontend Layer

The Frontend Layer is the intermediary between the logic defined in the Circuit Layer and the rest of the ZKP system. Its key responsibilities include:

- Compilation: Translates the circuit into constraints, typically in a format such as R1CS (Rank-1 Constraint System), which is used to define the relationships between variables in a way that can be proved in zero-knowledge.

- Witness Generation: Produces a witness based on both public and private inputs. The witness is a set of concrete values that satisfy the circuit's constraints for a given input.

For instance, Circom’s compiler can transform a circuit into its corresponding R1CS form and generate the witness based on the provided inputs.

### 2.3 Backend Layer

The Backend Layer is responsible for the core functionality of the zero-knowledge proof system. This layer is where key cryptographic operations take place. Using tools like the snarkjs toolchain, the following primary tasks are performed:

- Setup: Initializes the proving system, which may include generating cryptographic parameters (for example, with a trusted setup in systems like Groth16).
- Prove: Generates a proof based on the witness and the circuit's constraints, without revealing sensitive information.
- Verify: Validates that a given proof is correct and that the input satisfies the circuit’s constraints.

### 2.4 Integration Layer

At the top, the Integration Layer connects the ZKP system to external applications or platforms. This could involve integrating with smart contracts, decentralized applications, or traditional systems. In a blockchain context, smart contracts might verify proofs and take actions based on the results of the verification.

For example, a smart contract could use an on-chain verifier to:

- Validate a submitted proof.
- Trigger contract logic based on whether the proof is valid.

## 3. Implementing a ZKP System: A Practical Example

Let's walk through the process of implementing a simple ZKP system using the `IsZero` circuit, which checks if an input is zero or non-zero.

### 3.1. Circuit Implementation (using Circom)

```
template IsZero() {
 signal input in;    // Input signal to check if it's zero or non-zero.
 signal output out;  // Output signal: 1 if `in == 0`, 0 if `in != 0`.
 signal inv;         // Inverse of the input when `in != 0`, or 0 when `in == 0`.
    
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

- [Circomspect](https://github.com/trailofbits/circomspect): Static analyzer for Circom
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

### Static Analysis

#### [Practical Security Analysis of Zero-Knowledge Proof Circuits (USENIX'24)](https://www.cs.utexas.edu/~isil/zkap.pdf)
  
>Tag: `{Type: static analysis, DSL:circom, Arithmetization:R1CS, Target:circuit (under-constrainted)}`

<details>

***Overview***: This paper presents **ZKAP**, the heuristic-based tool for detecting common vulnerabilities in Circom, a popular DSL for building zero-knowledge proof (ZKP) circuits. The design of ZKAP is based on a manual study of existing Circom vulnerabilities, which helped classify the root causes of bugs into three main categories:

1. Nondeterministic signals: Input or output signals are not properly constrained.
2. Unsafe component usage: Components are used incorrectly, leading to signal errors.
3. Constraint-computation discrepancies: Mismatches occur between witness generation and constraint enforcement like under/over constraints.

*Threat Model*: The analysis assumes a trustless environment where attackers have full access to public information, including blockchain states, deployed smart contracts, and ZK circuit source code. Attackers can also deploy their own contracts and ZK applications to interact with the target system.

***Method***: To detect these vulnerabilities, the authors introduced the *circuit dependence graph (CDG)*, an abstraction that captures key properties of Circom circuits to identify semantic vulnerability patterns. ZKAP uses this graph to implement static checkers that detect vulnerabilities through anti-patterns described in a Datalog-style language.

***Experiment***: The tool was evaluated on 258 Circom circuits from popular projects on GitHub, achieving an F1 score of 0.82.

</details>

------------------------------

### Dynamic Analysis

#### [SNARKProbe: An Automated Security Analysis Framework for zkSNARK Implementations](https://link.springer.com/chapter/10.1007/978-3-031-54773-7_14)

>Tag: `{Type: dynamic analysis, Arithmetization: R1CS, Target: compilier}`

------------------------------

### Formal Method

#### [Automated Detection of Under-Constrained Circuits in Zero-Knowledge Proofs (PLDI'23)](https://dl.acm.org/doi/pdf/10.1145/3591282)

>Tag: `{Type: formal method, DSL:circom, Arithmetization:R1CS, Target:circuit (under-constrainted), Others:[SMT-solver]}`

<details>

***Overview***: This paper introduces a novel technique to detect under-constrained polynomial equations in ZKP circuits over finite fields. The method performs semantic analysis on the equations generated by the compiler to determine if each signal is uniquely constrained by the inputs. The approach combines SMT solving with lightweight inference to effectively identify under-constrained circuits.

***Method***: The process begins with lightweight inference rules to propagate uniqueness constraints and switches to SMT-based reasoning when necessary. The analysis ends when the SMT solver either finds a proof or counterexample, when all output variables are proven to be constrained, or when no further progress can be made. Because this method operates directly on arithmetic circuits, it is not tied to any specific DSL and can be applied to various ZK-snark-compatible DSLs. Notably, it produces no false positives.

***Experiment***: The method successfully analyzed 70% of the tested benchmarks (163 circuits), although it is still difficult to validate relatively larger circuits that contains more thatn 100 constraints.

</details>

------------------------------

#### [Certifying Zero-Knowledge Circuits with Refinement Types (S&P'24)](https://eprint.iacr.org/2023/547.pdf)

>Tag: `{Type: formal method, DSL: New DSL, Arithmetization: R1CS, Target: circuit}`

<details>

***Overview***: This paper introduces CODA, a statically typed language for building zero-knowledge applications. CODA allows developers to formally specify and verify properties of ZK applications using a powerful refinement type system. A major challenge in verifying ZK applications is reasoning about polynomial equations over large prime fields, which are often beyond the reach of automated theorem provers. CODA addresses this by generating Coq lemmas that can be interactively proven using a tactic library.

***Experiment***: The authors evaluated CODA on 77 ZK circuits from 9 widely-used libraries and projects in Circom. Because CODA is sound, any bugs in the program will result in unprovable lemmas in Coq. During testing, 6 benchmarks failed to discharge their proof obligations, leading to the discovery of subtle, previously unknown correctness bugs in the original Circom circuits.

</details>

------------------------------

#### [LEO: A Programming Language for Formally Verified,Zero-Knowledge Applications (IACR'21)](https://docs.zkproof.org/pages/standards/accepted-workshop4/proposal-leo.pdf)

>Tag: `{Type: formal method, DSL: New DSL, Arithmetization: R1CS, Target: circuit}`

<details>

***Overview***: LEO is a high-level, general-purpose programming language designed for circuit synthesis, particularly for zero-knowledge applications on the Aleo blockchain. It specifically targets R1CS arithmetization, with completeness proven using ACL2, an industrial-strength theorem prover. LEO offers two key benefits: it ensures formal verification of applications against their high-level specifications, and it allows anyone to succinctly verify these applications, regardless of their size.

</details>

------------------------------

#### [CLAP: a Semantic-Preserving Optimizing eDSL for Plonkish Proof Systems](https://arxiv.org/pdf/2405.12115)

>Tag: `{Type: formal method, DSL: New DSL, Arithmetization: Plonkish, Target:circuit}`

<details>

***Overview***: CLAP is the first Rust eDSL with a proof system-agnostic circuit format designed for extensibility, automatic optimization, and formal assurance of constraint systems. It treats the production of Plonkish constraint systems and witness generators as a semantic-preserving compilation problem, ensuring soundness and completeness to prevent under- or over-constraining errors.

***Method***: In traditional approaches, circuit developers work in an eDSL and later hand off the constraint system to proof engineers, leading to a disconnect between development and verification. CLAP solves this by integrating the entire process, offering a sound and complete architecture from the start.

CLAP also provides automatic safe optimizations, which can be applied only after the circuit is fully defined. This avoids premature optimization issues, such as missing constraints, and ensures that optimizations—like removing duplicate checks—are safe and context-aware. Additionally, CLAP allows for circuit reuse by generating arithmetic gates that can be automatically optimized for different proof systems, such as Boojum.

For custom gates, which trade prover time for verification efficiency, CLAP’s inlining optimizer can flatten complex logic (like a Poseidon hash round) into a custom gate of the required degree, saving time in development and review.

***Experiment***: CLAP was validated using Boojum circuits from ZKsync Era, which are manually optimized by experts and reviewed by auditors. Despite starting with more constraints, CLAP’s optimizations resulted in 10% fewer constraints compared to hand-optimized circuits.

</details>

------------------------------

#### [Compositional Formal Verification of Zero-Knowledge Circuits](https://eprint.iacr.org/2023/1278.pdf)

>Tag: `{Type: formal method, Target: circuit}`

------------------------------

#### [Formal Verification of Zero-Knowledge Circuits](https://arxiv.org/pdf/2311.08858)

>Tag: `{Type: formal method, Target: circuit}`

------------------------------

#### [Scalable Verification of Zero-Knowledge Protocols (S&P'24)](https://www.computer.org/csdl/proceedings-article/sp/2024/313000a133/1Ub23QzVaWA)

>Tag: `{Type: formal method, Target: circuit}`

------------------------------

#### [Automated Analysis of Halo2 Circuits](https://eprint.iacr.org/2023/1051.pdf)

>Tag: `{Type: formal method, Target: circuit}`

------------------------------

#### [Bounded Verification for Finite-Field-Blasting](https://link.springer.com/content/pdf/10.1007/978-3-031-37709-9_8.pdf)

>Tag: `{Type: formal method, Target: compilier}`

<details>

***Overview***: This paper addresses ZKP compiler correctness by partially verifying the field-blasting compiler pass, translating Boolean and bitvector logic into finite field operations. The contributions of this paper include:

1. Correctness Definition: It introduces a precise correctness definition for ZKP compilers, ensuring that the compiler preserves the soundness and completeness of the underlying ZK proof system. Specifically, suppose a ZK proof system is specified in a low-level language (L) and compiled from a high-level language (H) to L. In that case, the compiler must maintain these properties for statements in H. The definition is also compositional, meaning proving correctness for each compiler pass suffices to prove correctness for the whole compiler.

2. Verifiable Field-Blaster Architecture: The paper presents an architecture for a verifiable field-blaster, consisting of a set of encoding rules. It provides verification conditions (VCs) for these rules, and shows that if the VCs hold, the field-blaster is correct. These conditions can be automatically checked (in bounded form), reducing both the initial and ongoing costs of verification.

</details>

------------------------------

#### [The Ouroboros of ZK: Why Verifying the Verifier Unlocks Longer-Term ZK Innovation](https://eprint.iacr.org/2024/768.pdf)

>Tag: `{Type: formal method, Target: verifier}`

------------------------------

#### [Weak Fiat-Shamir Attacks on Modern Proof Systems](https://eprint.iacr.org/2023/691.pdf)

>Tag: `{Type: formal method, Target: Fiat-Shamir Transform}`

------------------------------
  
#### [The Last Challenge Attack: Exploiting a Vulnerable Implementation of the Fiat-Shamir Transform in a KZG-based SNARK](https://eprint.iacr.org/2024/398)

>Tag: `{Type: formal method, Target: Fiat-Shamir Transform}`

------------------------------

### SMT Solver for Finite Fields

There are some papers that propose SMT solvers specially designed to solve constraints in the finite fields.

#### [An SMT-LIB Theory of Finite Fields](https://ceur-ws.org/Vol-3725/paper3.pdf)

------------------------------

#### [Satisfiability Modulo Finite Fields](https://link.springer.com/content/pdf/10.1007/978-3-031-37703-7_8.pdf)

------------------------------

#### [SMT Solving over Finite Field Arithmetic](https://arxiv.org/pdf/2305.00028)

------------------------------

### SoK

- [SoK: What Don’t We Know? Understanding Security Vulnerabilities in SNARKs (USENIX'24)](https://arxiv.org/pdf/2402.15293)

- [Zero-Knowledge Proof Vulnerability Analysis and Security Auditing](https://eprint.iacr.org/2024/514.pdf)

## 9. Resource

| **Category** | **Title** | **Link** |
|--------------|-----------|----------|
| **Curation** | Awesome Zero-Knowledge Proofs Security | [Link](https://github.com/Xor0v0/awesome-zero-knowledge-proofs-security?tab=readme-ov-file) |
|  | Awesome ZKP Security | [Link](https://github.com/StefanosChaliasos/Awesome-ZKP-Security?tab=readme-ov-file) |
| **Blogs** | The State of Security Tools for ZKPs | [Link](https://www.zksecurity.xyz/blog/posts/zksecurity-tools/) |
|           | A beginner's intro to coding zero-knowledge proofs| [Link](https://dev.to/spalladino/a-beginners-intro-to-coding-zero-knowledge-proofs-c56) |
|           | Arithmetization schemes for ZK-SNARKs | [Link](https://blog.lambdaclass.com/arithmetization-schemes-for-zk-snarks/) |
|           | Medjai: Protecting Cairo code from Bugs| [Link](https://medium.com/veridise/medjai-protecting-cairo-code-from-bugs-d82ec852cd45) |
