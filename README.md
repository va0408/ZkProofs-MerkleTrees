# ZkProofs-MerkleTrees


Estos casos son para suma modular: 
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
