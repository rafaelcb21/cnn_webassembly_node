const fs = require('fs');

let currentInstance;

(async () => {
    const wasmBuffer = fs.readFileSync("rgb565_3x3_valid_first_layer.wasm");
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

    const stride_h = 1;
    const stride_w = 1;

    x = currentInstance.exports.convolve_rgb565_3x3_valid_first_layer(
        0,   // ptr para imagem
        4,   // height da imagem
        4,   // width da imagem
        stride_h,   // heigth do stride
        stride_w,   // width do stride
        32,  // ponteiro de saida do resultado apos a convolução

        0.2,   // kernel indice 00 RED
        -0.4,  // kernel indice 01 RED
        0.2,   // kernel indice 02 RED
        0.1,   // kernel indice 10 RED
        0.3,   // kernel indice 11 RED
        0.7,   // kernel indice 12 RED
        0.5,   // kernel indice 20 RED
        0.2,   // kernel indice 21 RED
        0.1,   // kernel indice 22 RED

        0.3,   // kernel indice 00 GREEN
        0.2,   // kernel indice 01 GREEN
        0.4,   // kernel indice 02 GREEN
        0.1,   // kernel indice 10 GREEN
        0.4,   // kernel indice 11 GREEN
        0.2,   // kernel indice 12 GREEN
        0.9,   // kernel indice 20 GREEN
        0.8,   // kernel indice 21 GREEN
        0.5,   // kernel indice 22 GREEN

        0.7,   // kernel indice 00 BLUE
        0.2,   // kernel indice 01 BLUE
        0.4,   // kernel indice 02 BLUE
        0.1,   // kernel indice 10 BLUE
        0.5,   // kernel indice 11 BLUE
        0.7,   // kernel indice 12 BLUE
        0.2,   // kernel indice 20 BLUE
        0.3,   // kernel indice 21 BLUE
        0.9,   // kernel indice 22 BLUE
    );

    const decimalDump = Array.from(memory); // já retorna os valores decimais
    fs.writeFileSync('./memory_bytes_decimal.json', JSON.stringify(decimalDump, null, 2));

    // Carrega o conteúdo do JSON salvo anteriormente
        const memoryBytes = JSON.parse(fs.readFileSync('./memory_bytes_decimal.json', 'utf-8'));
    
        const height   = 4;
        const width    = 4;
        const kernel_h = 3;
        const kernel_w = 3;

        // Fórmula de VALID
        const out_h = Math.floor((height - kernel_h) / stride_h) + 1; // → 2
        const out_w = Math.floor((width  - kernel_w) / stride_w) + 1; // → 2

        // Define o intervalo desejado
        const start = 32;
        const end = start + out_h * out_w * 4;

        // Extrai os bytes do intervalo
        const selectedBytes = memoryBytes.slice(start, end);
    
        // Processa de 4 em 4 bytes
        const floatResults = [];
        for (let i = 0; i < selectedBytes.length; i += 4) {
            // Pega os 4 bytes e inverte a ordem (little endian → big endian)
            const group = selectedBytes.slice(i, i + 4);

            const buffer = new ArrayBuffer(4)
            const view = new DataView(buffer)
            group.forEach((byte, idx) => view.setUint8(idx, byte));

            const floatValue = view.getFloat32(0, true)
            floatResults.push(floatValue)
    
        }
    
        // Mostra os valores convertidos
        console.log("Resultados reconstruídos (f32):");
        console.log(floatResults);
})();

//1x1 hxw
// [ 273, 271.6000061035156, 221.10000610351562, 193.59999084472656 ]