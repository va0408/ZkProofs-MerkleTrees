const fs = require("fs");
const { execSync } = require("child_process");

const cases = JSON.parse(fs.readFileSync("cases.json"));

for (const [name, input] of Object.entries(cases)) {
  fs.writeFileSync("input.json", JSON.stringify(input));

  try {
    // Generar witness
    console.time(`Witness ${name}`);
    execSync(`node build_merkle/generate_witness.js build_merkle/merkle.wasm input.json witness_${name}.wtns`, { stdio: "inherit" });
    console.timeEnd(`Witness ${name}`);

    // Generar prueba
    console.time(`Proving ${name}`);
    execSync(`snarkjs groth16 prove merkle_0001.zkey witness_${name}.wtns proof_${name}.json public_${name}.json`, { stdio: "inherit" });
    console.timeEnd(`Proving ${name}`);

    // Medir tamaño del proof
    const proofStats = fs.statSync(`proof_${name}.json`);
    console.log(`Proof size for ${name}: ${proofStats.size} bytes`);

    // Verificar prueba
    console.time(`Verification ${name}`);
    execSync(`snarkjs groth16 verify verification_key_merkle.json public_${name}.json proof_${name}.json`, { stdio: "inherit" });
    console.timeEnd(`Verification ${name}`);

    console.log(`Caso ${name} terminado\n`);
  } catch (err) {
    console.error(`Caso ${name} falló: ${err.message}\n`);
  }
}


//node run_casesMerkle.js