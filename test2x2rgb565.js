const fs = require('fs');

let currentInstance;

(async () => {
    //const wasmBuffer = fs.readFileSync("grayscale_2x2.wasm"); // Nome do seu WASM novo
    const wasmBuffer = fs.readFileSync("rgb565_2x2.wasm"); // Nome do seu WASM novo
    const wasmModule = await WebAssembly.instantiate(wasmBuffer, {
        env: {
            log: (value) => console.log("LOG:", value),
        }
    });

    currentInstance = wasmModule.instance;

    // Enviar a imagem
    const memory = new Uint8Array(currentInstance.exports.memory.buffer);

    //memory.set([
    //    0x01, 0x02, 0x03, 0x04,
    //    0x05, 0x06, 0x07, 0x08,
    //    0x09, 0x0A, 0x0B, 0x0C,
    //    0x0D, 0x0E, 0x0F, 0x10
    //], 0);
    
    //memory.set([
    //    2211, 10631, 17035, 25455,
    //    33906, 42326, 48730, 57150,
    //    65436, 54871, 46420, 38000,
    //    31596, 23176, 14725, 6305,
    //], 0);

    

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

    //x = currentInstance.exports.convolve_2x2_grayscale(
    //    0,   // ptr para imagem
    //    4,   // height da imagem
    //    4,   // width da imagem
    //    0,   // padding top
    //    1,   // padding bottom
    //    0,   // padding left
    //    1,   // padding right
    //    1,   // heigth do stride
    //    1,   // width do stride
    //    16,  // ponteiro de saida do resultado apos a convolução
    //    2,   // kernel indice 00
    //    -4,  // kernel indice 01
    //    1,   // kernel indice 10
    //    3   // kernel indice 11
    //);
    

    x = currentInstance.exports.convolve_2x2_rgb565(
        0,   // ptr para imagem
        4,   // height da imagem
        4,   // width da imagem
        0,   // padding top
        1,   // padding bottom
        0,   // padding left
        1,   // padding right
        1,   // heigth do stride
        1,   // width do stride
        32,  // ponteiro de saida do resultado apos a convolução

        2,   // kernel indice 00 RED
        -4,  // kernel indice 01 RED
        1,   // kernel indice 10 RED
        3,   // kernel indice 11 RED

        3,   // kernel indice 00 GREEN
        2,   // kernel indice 01 GREEN
        1,   // kernel indice 10 GREEN
        4,   // kernel indice 11 GREEN

        7,   // kernel indice 00 BLUE
        2,   // kernel indice 01 BLUE
        1,   // kernel indice 10 BLUE
        5,   // kernel indice 11 BLUE
    );

    const decimalDump = Array.from(memory); // já retorna os valores decimais
    fs.writeFileSync('test_memory_bytes_decimal.json', JSON.stringify(decimalDump, null, 2));


    const rgb565 = currentInstance.exports.extract_rgb(41736);

    // Imprimir valor diretamente em decimal e hexadecimal
    console.log(`RGB565 decimal: ${rgb565}`);
    console.log(`RGB565 hex: 0x${rgb565.toString(16).padStart(4, '0')}`);
    
})();
