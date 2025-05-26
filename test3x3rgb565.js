const fs = require('fs');

let currentInstance;

(async () => {
    //const wasmBuffer = fs.readFileSync("grayscale_2x2.wasm"); // Nome do seu WASM novo
    const wasmBuffer = fs.readFileSync("teste2_3x3.wasm"); // Nome do seu WASM novo
    const wasmModule = await WebAssembly.instantiate(wasmBuffer, {
        env: {
            log: (value) => console.log("LOG:", value),
        }
    });

    currentInstance = wasmModule.instance;

    // Enviar a imagem
    const memory = new Uint8Array(currentInstance.exports.memory.buffer);

    const values16 = [
        2211, 10631, 17035, 25455,
        33906, 42326, 48730, 57150,
        65436, 54871, 46420, 38000,
        31596, 23176, 14725, 6305,
    ];

    let offset = 0;  // índice inicial na memória

    for (const val of values16) {
        memory[offset] = (val >> 8) & 0xFF; // MSB primeiro
        memory[offset + 1] = val & 0xFF;    // LSB depois
        offset += 2;
    }

    x = currentInstance.exports.convolve_3x3_rgb565(
        0,   // ptr para imagem
        4,   // height da imagem
        4,   // width da imagem
        1,   // padding top
        1,   // padding bottom
        1,   // padding left
        1,   // padding right
        1,   // heigth do stride
        1,   // width do stride
        32,  // ponteiro de saida do resultado apos a convolução

        2,   // kernel indice 00 RED
        -4,  // kernel indice 01 RED
        2,   // kernel indice 02 RED
        1,   // kernel indice 10 RED
        3,   // kernel indice 11 RED
        7,   // kernel indice 12 RED
        5,   // kernel indice 20 RED
        2,   // kernel indice 21 RED
        1,   // kernel indice 22 RED

        3,   // kernel indice 00 GREEN
        2,   // kernel indice 01 GREEN
        4,   // kernel indice 02 GREEN
        1,   // kernel indice 10 GREEN
        4,   // kernel indice 11 GREEN
        2,   // kernel indice 12 GREEN
        9,   // kernel indice 20 GREEN
        8,   // kernel indice 21 GREEN
        5,   // kernel indice 22 GREEN

        7,   // kernel indice 00 BLUE
        2,   // kernel indice 01 BLUE
        4,   // kernel indice 02 BLUE
        1,   // kernel indice 10 BLUE
        5,   // kernel indice 11 BLUE
        7,   // kernel indice 12 BLUE
        2,   // kernel indice 20 BLUE
        3,   // kernel indice 21 BLUE
        9,   // kernel indice 22 BLUE
    );

    const decimalDump = Array.from(memory); // já retorna os valores decimais
    fs.writeFileSync('test_memory_bytes_decimal_3x3_rgb565.json', JSON.stringify(decimalDump, null, 2));
})();
