const fs = require('fs');

let currentInstance;

(async () => {
    const wasmBuffer = fs.readFileSync("grayscale_3x3_same_first_layer.wasm");
    const wasmModule = await WebAssembly.instantiate(wasmBuffer, {
        env: {
            log: (value) => console.log("LOG:", value),
        }
    });

    currentInstance = wasmModule.instance;

    // Enviar a imagem
    const memory = new Uint8Array(currentInstance.exports.memory.buffer);

    memory.set([
         1,  5,  8, 12,
        16, 20, 23, 27,
        31, 26, 22, 18,
        15, 11,  7,  3
    ], 0);

    const stride_h = 1;
    const stride_w = 1;

    x = currentInstance.exports.convolve_grayscale_3x3_same_first_layer(
        0,   // ptr para imagem
        4,   // height da imagem
        4,   // width da imagem
        1,   // padding top
        1,   // padding bottom
        1,   // padding left
        1,   // padding right
        stride_h,   // heigth do stride
        stride_w,   // width do stride
        16,  // ponteiro de saida do resultado apos a convolução

        0.2,   // kernel indice 00
        -0.4,  // kernel indice 01
        0.2,   // kernel indice 02
        0.1,   // kernel indice 10
        0.3,   // kernel indice 11
        0.7,   // kernel indice 12
        0.5,   // kernel indice 20
        0.2,   // kernel indice 21
        0.1,   // kernel indice 22
    );

    const decimalDump = Array.from(memory); // já retorna os valores decimais
    fs.writeFileSync('./memory_bytes_decimal.json', JSON.stringify(decimalDump, null, 2));

    // Carrega o conteúdo do JSON salvo anteriormente
    const memoryBytes = JSON.parse(fs.readFileSync('./memory_bytes_decimal.json', 'utf-8'));

    const height   = 4;
    const width    = 4;

    const out_h = Math.floor((height  + stride_h - 1) / stride_h);
    const out_w = Math.floor((width   + stride_w - 1) / stride_w);

    // Define o intervalo desejado
    const start = 16;
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
//[
//    9,                21.5,
//28.600000381469727,  21.299999237060547,
//28.200000762939453,  46.400001525878906,
//47.20000076293945,   21.80000114440918,
//29.19999885559082,                36.5,
//29.19999885559082,                 5.5,
//4.999999523162842,   9.899999618530273,
//5.300000190734863, -1.2000000476837158
//]