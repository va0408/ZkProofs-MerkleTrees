pragma circom 2.0.0;

include "poseidon.circom";

// Gadget de Merkle con 10 hojas
template Merkle10() {
    signal input leaves[10];   // hojas originales
    signal output root;        // raíz del árbol

    // Hash de cada hoja
    component h[10];
    for (var i = 0; i < 10; i++) {
        h[i] = Poseidon(1);
        h[i].inputs[0] <== leaves[i];
    }

    // Nivel 1: pares de hojas
    component n1[5];
    for (var i = 0; i < 5; i++) {
        n1[i] = Poseidon(2);
        n1[i].inputs[0] <== h[2*i].out;
        n1[i].inputs[1] <== h[2*i+1].out;
    }

    // Nivel 2: pares de nodos (5 → 3, duplicando el último)
    component n2[3];
    for (var i = 0; i < 2; i++) {
        n2[i] = Poseidon(2);
        n2[i].inputs[0] <== n1[2*i].out;
        n2[i].inputs[1] <== n1[2*i+1].out;
    }
    // último par: duplicamos n1[4]
    n2[2] = Poseidon(2);
    n2[2].inputs[0] <== n1[4].out;
    n2[2].inputs[1] <== n1[4].out;

    // Nivel 3: pares de n2 (3 → 2, duplicando el último)
    component n3[2];
    n3[0] = Poseidon(2);
    n3[0].inputs[0] <== n2[0].out;
    n3[0].inputs[1] <== n2[1].out;

    n3[1] = Poseidon(2);
    n3[1].inputs[0] <== n2[2].out;
    n3[1].inputs[1] <== n2[2].out;

    // Nivel 4: raíz
    component r = Poseidon(2);
    r.inputs[0] <== n3[0].out;
    r.inputs[1] <== n3[1].out;

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

    acc === q * p + target;

    component poseidon = Poseidon(1);
    poseidon.inputs[0] <== acc;
    digest <== poseidon.out;
}

// Combinación Map/Reduce + Merkle
template MerkleReduce10(p) {
    signal input leaves[10];
    signal input target;
    signal input q;
    signal output root_digest;

    // Merkle tree
    component merkle = Merkle10();
    for (var i = 0; i < 10; i++) {
        merkle.leaves[i] <== leaves[i];
    }

    // Reduce modular
    component reduce = SumaModular(10, p);
    for (var i = 0; i < 10; i++) {
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

component main = MerkleReduce10(7);
