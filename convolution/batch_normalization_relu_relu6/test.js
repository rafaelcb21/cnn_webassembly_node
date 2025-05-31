const fs = require('fs');

let currentInstance;

(async () => {
    const wasmBuffer = fs.readFileSync("btn_relu_relu6.wasm");
    const wasmModule = await WebAssembly.instantiate(wasmBuffer, {
        env: {
            log: (value) => console.log("LOG:", value),
        }
    });

    currentInstance = wasmModule.instance;

    btn = currentInstance.exports.btn(
        0.3,    // beta
        1.2,    // gama
        0.25,   // variance
        1.4,    // mean
        2.5,    // value
    );

    relu = currentInstance.exports.relu(-2)
    relu6 = currentInstance.exports.relu6(10)

    console.log("Resultado:", btn);
    console.log("Resultado:", relu);
    console.log("Resultado:", relu6);
})();

