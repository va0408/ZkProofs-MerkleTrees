const fs = require("fs");
const { execSync } = require("child_process");

// Leer casos desde cases10.json
const cases = JSON.parse(fs.readFileSync("cases10.json"));

for (const [name, input] of Object.entries(cases)) {
  // Guardar input temporal
  fs.writeFileSync("input.json", JSON.stringify(input));

  try {
    // Generar witness
    console.time(`Witness ${name}`);
    execSync(
      `node build_merkleN/generate_witness.js build_merkleN/merkleN.wasm input.json witness_${name}.wtns`,
      { stdio: "inherit" }
    );
    console.timeEnd(`Witness ${name}`);

    // Generar prueba
    console.time(`Proving ${name}`);
    execSync(
      `snarkjs groth16 prove merkleN_0001.zkey witness_${name}.wtns proof_${name}.json public_${name}.json`,
      { stdio: "inherit" }
    );
    console.timeEnd(`Proving ${name}`);

    // Medir tamaño del proof
    const proofStats = fs.statSync(`proof_${name}.json`);
    console.log(`Proof size for ${name}: ${proofStats.size} bytes`);

    // Verificar prueba
    console.time(`Verification ${name}`);
    execSync(
      `snarkjs groth16 verify verification_key_merkleN.json public_${name}.json proof_${name}.json`,
      { stdio: "inherit" }
    );
    console.timeEnd(`Verification ${name}`);

    console.log(`Caso ${name} terminado\n`);
  } catch (err) {
    console.error(`Caso ${name} falló: ${err.message}\n`);
  }
}

