pragma circom 2.0.0;

include "poseidon.circom";

template SumaModular(n, p) {
    signal input leaves[n];
    signal input target;
    signal input q;          // lo declaramos como input privado
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

component main = SumaModular(4, 7);


