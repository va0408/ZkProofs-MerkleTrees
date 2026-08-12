pragma circom 2.0.0;

include "poseidon.circom";

// Gadget de Merkle con 4 hojas
template Merkle4() {
    signal input leaves[4];   // hojas originales
    signal output root;       // raíz del árbol

    // Hash de cada hoja
    component h0 = Poseidon(1);
    h0.inputs[0] <== leaves[0];
    component h1 = Poseidon(1);
    h1.inputs[0] <== leaves[1];
    component h2 = Poseidon(1);
    h2.inputs[0] <== leaves[2];
    component h3 = Poseidon(1);
    h3.inputs[0] <== leaves[3];

    // Nodos intermedios
    component n0 = Poseidon(2);
    n0.inputs[0] <== h0.out;
    n0.inputs[1] <== h1.out;

    component n1 = Poseidon(2);
    n1.inputs[0] <== h2.out;
    n1.inputs[1] <== h3.out;

    // Raíz
    component r = Poseidon(2);
    r.inputs[0] <== n0.out;
    r.inputs[1] <== n1.out;

    root <== r.out;
}

// Reduce: suma modular sobre las hojas
template SumaModular(n, p) {
    signal input leaves[n];
    signal input target;
    signal input q;
    signal output digest;

    var acc = 0;
    for (var i = 0; i < n; i++) {
        acc = acc + leaves[i];
    }

    // Constraint modular
    acc === q * p + target;

    component poseidon = Poseidon(1);
    poseidon.inputs[0] <== acc;
    digest <== poseidon.out;
}

// Combinación Map/Reduce + Merkle
template MerkleReduce4(p) {
    signal input leaves[4];
    signal input target;
    signal input q;
    signal output root_digest;

    // Merkle tree
    component merkle = Merkle4();
    for (var i = 0; i < 4; i++) {
        merkle.leaves[i] <== leaves[i];
    }

    // Reduce modular
    component reduce = SumaModular(4, p);
    for (var i = 0; i < 4; i++) {
        reduce.leaves[i] <== leaves[i];
    }
    reduce.target <== target;
    reduce.q <== q;

    // Digest final: raíz + resultado reduce
    component final = Poseidon(2);
    final.inputs[0] <== merkle.root;
    final.inputs[1] <== reduce.digest;

    root_digest <== final.out;
}

component main = MerkleReduce4(7);
