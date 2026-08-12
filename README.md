# ZkProofs-MerkleTrees


Estos casos son para suma modular: 
Probamos tanto casos válidos (del 1 al 7) como inválidos (a partir del caso 8) dentro del primer cases.json; estos fallaron en la generación del witness con un Assert Failed, lo que demuestra soundness: el sistema no permite construir pruebas falsas.

(para la parte de PERFORMANCE puedo mostrar que los tiempos y tamaños se reportan solo para los casos válidos, mientras que los inválidos terminan en error.]
Para hacer los testigos y probar distintos casos inválidos:
El script run_cases.js sobreescribe input.json en cada iteración. Si se corre manualmente generate_witness.js con input.json, puede que el archivo contenga un caso inválido y falle en witness. Para pruebas manuales, es mejor guardar cada input en un archivo separado (input_caseX.json). (DE TODAS FORMAS, LOS ERRORES QUE CONSEGUÍ SON DE TESTIGO HASTA AHORA).

casos para el arbol.

# Reproducibilidad del proyecto

## 1. Descargar Powers of Tau
Este archivo es global y se usa en todos los circuitos. Se descarga una sola vez (~500 MB):

```bash
mkdir -p ~/zkptau
cd ~/zkptau
wget https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_10.ptau
