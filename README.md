# ZkProofs-MerkleTrees

The idea of this project was to implement Merkle trees of different sizes and compare both the execution times and the sizes of the generated artifacts. I started by testing with a Merkle tree of 4 leaves, then one of 10, and I thought about extending it to a larger range, between 15 and 30 leaves. For each one I prepared test cases that included correct situations, invalid cases, and also edge scenarios. The intention was to upload everything to GitHub Actions and take advantage of CI to automate the verifications. However, I ran into a limitation: very large trees require a powers of tau of considerable size, and the free GitHub server does not support that load. That forced me to reduce the scope and parallelize the tasks, so that MerkleN (with ten leaves), suma_modular, and Merkle (with four leaves) could run at the same time.

Each implementation needed its own configuration and dependencies, and every time I switched from one to another I had to restart the processes, which led me to limit the number of trees and test cases. In addition, any modification in the implementation implied generating a new folder with the witnesses, a new verification key, and repeating the setup, which made adding cases tedious. In the end, the trees I was able to run are more like toy examples, and the differences between extreme inputs were not very relevant: even with ten leaves and very large numbers, the times and sizes did not vary much. That is why I tried to make the cases representative as much as possible, even if they did not cover massive scenarios.

In future implementations it would be interesting to experiment with larger trees, between 50 and 100 leaves, to observe how the proving and verification times scale. It would also be useful to automate the generation of test cases, because doing it manually becomes repetitive and does not add much new information. In contrast with what is seen in the papers, where trees with millions of leaves are used, this project remained at a small scale, but it served to understand the practical limitations of running cryptographic proofs in a free CI environment and to explore how circuits behave in controlled scenarios.

# Estos casos son para suma modular: 
Probamos tanto casos válidos (del 1 al 7) como inválidos (a partir del caso 8) dentro del primer cases.json; estos fallaron en la generación del witness con un Assert Failed, lo que demuestra soundness: el sistema no permite construir pruebas falsas.

(para la parte de PERFORMANCE puedo mostrar que los tiempos y tamaños se reportan solo para los casos válidos, mientras que los inválidos terminan en error.]
Para hacer los testigos y probar distintos casos inválidos:
El script run_cases.js sobreescribe input.json en cada iteración. Si se corre manualmente generate_witness.js con input.json, puede que el archivo contenga un caso inválido y falle en witness. Para pruebas manuales, es mejor guardar cada input en un archivo separado (input_caseX.json). (DE TODAS FORMAS, LOS ERRORES QUE CONSEGUÍ SON DE TESTIGO HASTA AHORA).

casos para el arbol.
# First Question
The paper on Reckle Trees addresses a known problem in Merkle trees: although updates can be fast, batch proofs depend on the size of the set and are not efficiently updatable. To solve this, the authors propose a scheme that combines recursive SNARKs with canonical hashing, achieving batch proofs that are both succinct and updatable in logarithmic time. The zk-proof ensures that a subset of leaves truly belongs to the tree and that the Map/Reduce computations over those leaves are correct without revealing their content. What is validated is the consistency between the canonical digests and the root of the tree, along with the correctness of the Map and Reduce results.

The process involves the prover, who updates or adds data (such as a validator or smart contract), and the verifier, which may be a light client or a contract that needs to check the proof. The formal statement establishes that “the canonical digest of the root corresponds to the committed subset and to the result of the modular computation,” while the witness includes the selected leaves, the target value, and the quotient q. The scheme relies on two trust assumptions: the security of the Poseidon hash, which guarantees collision resistance, and the soundness of the SNARK, which ensures completeness, knowledge, and succinctness.
# Second Question 
The original paper uses Plonky2, a proving system with support for efficient recursion and fixed-size proofs of about 112 KiB. In my implementation, I used Groth16 over Circom + snarkJS, so I had different properties. Groth16 requires a trusted setup, but produces proofs that are extremely small and constant in size—around 800 bytes—regardless of the complexity of the circuit. The verification cost remains stable, around 600 milliseconds, since it depends on a fixed number of bilinear operations. Its recursion support is limited, unlike Plonky2, which enables efficient recursive proofs. As for the framework, Circom allows modular circuit definitions, such as Merkle and Reduce gadgets, while snarkJS provides the tooling to generate and verify proofs within Node.js.

So, my prototype reproduces the idea of Reckle+ Trees in an accessible and reproducible environment, even if it does not include the advanced recursion capabilities offered by Plonky2.

# Third Question
The paper highlights several limitations. While Plonky2 is a powerful proving system, it is difficult to reproduce in a didactic environment. Recursive proofs also remain costly at the leaf level, which motivated techniques such as bucketing. In addition, extending the scheme to q‑ary trees, for example Merkle Patricia Tries, was left as future work.

My own implementation comes with its own constraints. It does not include recursion or bucketing, and instead relies on templates with a fixed number of leaves, such as Merkle4 or Merkle10. Changing N requires generating a new version of the circuit, which limits flexibility. As a result, the system scales to dozens of leaves but not to millions, as demonstrated in the paper. Verification remains efficient, but proving grows linearly with the number of constraints. Overall, this should be considered a toy implementation: it captures the core idea of Reckle+ Trees in an accessible and reproducible way, but without the advanced recursion or large‑scale optimizations of the original design.

# Reproducibilidad del proyecto

## 1. Descargar Powers of Tau
Este archivo es global y se usa en todos los circuitos. Se descarga una sola vez (~500 MB):

```bash
mkdir -p ~/zkptau
cd ~/zkptau
wget https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_15.ptau

(ESTO PARA CORRER LOS CASOS DEL MERKLE):
ahora compilamos el circuito
cd ~/Escritorio
circomc merkle.circom -o merkle_js

snarkjs groth16 setup ~/Escritorio/merkle_js/merkle.r1cs ~/zkptau/powersOfTau28_hez_final_15.ptau merkle_0000.zkey
snarkjs zkey contribute merkle_0000.zkey merkle_0001.zkey --name="First contribution"
snarkjs zkey export verificationkey merkle_0001.zkey verification_key.json

entropy: LOLO

node run_casesMerkle.js

# Tablas
### Suma Modular (4 leaves)

| Caso  | Leaves                  | Target | q    | Witness (ms) | Proving (ms) | Proof size | Verification (ms) | Result |
|-------|--------------------------|--------|------|--------------|--------------|------------|-------------------|-----------|
| case1 | [1000,54,40,1]          | 3      | 156  | 64.687       | 755.442      | 805 bytes  | 526.837           |  OK     |
| case2 | [350,0,0,0]             | 0      | 50   | 71.539       | 633.754      | 805 bytes  | 524.246           |  OK     |
| case3 | [0,94750,4,4]           | 6      | 13536| 66.166       | 608.827      | 807 bytes  | 525.073           |  OK     |
| case4 | [1,1,54978,1]           | 3      | 7854 | 64.810       | 605.991      | 808 bytes  | 523.121           |  OK     |
| case5 | [11,111,1111,11111]     | 3      | 1763 | 65.773       | 611.690      | 806 bytes  | 524.939           |  OK     |
| case6 | [0,0,0,0]               | 0      | 0    | 68.848       | 626.034      | 805 bytes  | 517.216           |  OK     |
| case7 | [0,7,0,0]               | 0      | 1    | 64.401       | 609.519      | 805 bytes  | 522.273           |  OK     |

---

### Merkle (4 leaves) 

| Caso  | Leaves                  | Target | q    | Witness (ms) | Proving (ms) | Proof size | Verification (ms) | Result |
|-------|--------------------------|--------|------|--------------|--------------|------------|-------------------|-----------|
| case1 | [1000,54,40,1]          | 3      | 156  | 79.280       | 1106.000     | 805 bytes  | 597.943           |  OK     |
| case2 | [350,0,0,0]             | 0      | 50   | 82.002       | 949.606      | 803 bytes  | 513.401           |  OK     |
| case3 | [0,94750,4,4]           | 6      | 13536| 80.888       | 943.995      | 804 bytes  | 512.182           |  OK     |
| case4 | [1,1,54978,1]           | 3      | 7854 | 84.346       | 950.835      | 804 bytes  | 513.843           |  OK     |
| case5 | [11,111,1111,11111]     | 3      | 1763 | 80.441       | 954.960      | 805 bytes  | 509.488           |  OK     |
| case6 | [0,0,0,0]               | 0      | 0    | 85.459       | 951.871      | 800 bytes  | 508.644           |  OK     |
| case7 | [0,7,0,0]               | 0      | 1    | 87.294       | 959.308      | 803 bytes  | 511.372           |  OK     |
| case8 | [0,3,4,0]               | 0      | 30   | —            | —            | —          | —                 |  Assert Failed |
| case9 | [0,7,0,0]               | 2      | 1    | —            | —            | —          | —                 |  Assert Failed |
| case10| [0,0,7,0]               | 1      | 1    | —            | —            | —          | —                 |  Assert Failed |

### MerkleN (10 leaves)

| Caso  | Leaves                        | Target | q  | Witness (ms) | Proving (ms) | Proof size | Verification (ms) | Result |
|-------|-------------------------------|--------|----|--------------|--------------|------------|-------------------|-----------|
| case1 | [1,2,3,4,5,6,7,8,9,10]        | 6      | 7  | 91.463       | 1524.000     | 803 bytes  | 600.221           |  OK     |
| case2 | [7,7,7,7,7,7,7,7,7,7]         | 0      | 10 | 90.447       | 1382.000     | 807 bytes  | 604.117           |  OK     |
| case3 | [2,2,2,2,2,2,2,2,2,2]         | 6      | 2  | 86.847       | 1374.000     | 806 bytes  | 606.011           |  OK     |
| case4 | [0,0,0,0,0,0,0,0,0,0]         | 0      | 0  | 117.386      | 1372.000     | 802 bytes  | 575.830           |  OK     |
| case5 | [3,1,4,1,5,9,2,6,5,3]         | 4      | 5  | 85.520       | 1401.000     | 801 bytes  | 588.434           |  OK     |

For MerkleN (10 leaves), I only tested valid cases due to time constraints. Anyways, the implementation is structurally identical to Merkle4, just with a few more levels. Invalid cases in Merkle4 correctly triggered assertion failures, demonstrating soundness. MerkleN uses the same SumaModular and MerkleReduce templates, so the same rejection behavior applies. That's why completeness and soundness are preserved across both circuits.
