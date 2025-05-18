const fs = require('fs');

let currentInstance;

(async () => {
    const wasmBuffer = fs.readFileSync("grayscale_2x2.wasm"); // Nome do seu WASM novo
    const wasmModule = await WebAssembly.instantiate(wasmBuffer, {
        env: {
            log: (value) => console.log("LOG:", value),
        }
    });

    currentInstance = wasmModule.instance;

    // Enviar a imagem
    const memory = new Uint8Array(currentInstance.exports.memory.buffer);

    memory.set([
        0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08,
        0x09, 0x0A, 0x0B, 0x0C,
        0x0D, 0x0E, 0x0F, 0x10
      ], 0);

    x = currentInstance.exports.convolve_2x2_grayscale(
        0,   // ptr para imagem
        4,   // height da imagem
        4,   // width da imagem
        0,   // padding top
        1,   // padding bottom
        0,   // padding left
        1,   // padding right
        1,   // heigth do stride
        1,   // width do stride
        16,  // ponteiro de saida do resultado apos a convolução
        2,   // kernel indice 00
        -4,  // kernel indice 01
        1,   // kernel indice 10
        3   // kernel indice 11
    );

    const decimalDump = Array.from(memory); // já retorna os valores decimais
    fs.writeFileSync('test_memory_bytes_decimal.json', JSON.stringify(decimalDump, null, 2));
    
})();
