const fs = require('fs');

let currentInstance;

(async () => {
    const wasmBuffer = fs.readFileSync("grayscale_3x3_same.wasm");
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

    x = currentInstance.exports.convolve_grayscale_3x3_same(
        0,   // ptr para imagem
        4,   // height da imagem
        4,   // width da imagem
        1,   // padding top
        1,   // padding bottom
        1,   // padding left
        1,   // padding right
        1,   // heigth do stride
        1,   // width do stride
        16,  // ponteiro de saida do resultado apos a convolução

        2,   // kernel indice 00
        -4,  // kernel indice 01
        2,   // kernel indice 02
        1,   // kernel indice 10
        3,   // kernel indice 11
        7,   // kernel indice 12
        5,   // kernel indice 20
        2,   // kernel indice 21
        1,   // kernel indice 22
    );

    const decimalDump = Array.from(memory); // já retorna os valores decimais
    fs.writeFileSync('./memory_bytes_decimal.json', JSON.stringify(decimalDump, null, 2));

    // Carrega o conteúdo do JSON salvo anteriormente
    const memoryBytes = JSON.parse(fs.readFileSync('./memory_bytes_decimal.json', 'utf-8'));

    // Define o intervalo desejado
    const start = 16;
    const end = 80; // índice 79 incluído (inclusive)

    // Extrai os bytes do intervalo
    const selectedBytes = memoryBytes.slice(start, end);

    // Processa de 4 em 4 bytes
    const results = [];
    for (let i = 0; i < selectedBytes.length; i += 4) {
        // Pega os 4 bytes e inverte a ordem (little endian → big endian)
        const group = selectedBytes.slice(i, i + 4).reverse();

        // Converte os 4 bytes para um único número de 32 bits (signed)
        const value =
            (group[0] << 24) |
            (group[1] << 16) |
            (group[2] << 8) |
            (group[3] << 0);

        // Ajusta sinal (corrige para números negativos caso necessário)
        const signedValue = value | 0;

        results.push(signedValue);
    }

    // Mostra os valores convertidos
    console.log("Resultados reconstruídos (int32):");
    console.log(results);
})();

//[
//    90, 215, 286, 213, 
//    282, 464, 472, 218, 
//    292, 365, 292,  55,  
//    50,  99,  53, -12
//]
