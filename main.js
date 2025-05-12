const fs = require('fs');

let currentInstance;

function stringifyImagesCompact(images) {
    const output = ['['];
  
    for (let i = 0; i < images.length; i++) {
      output.push('  ['); // imagem
  
      for (let j = 0; j < images[i].length; j++) {
        const row = images[i][j].join(', ');
        output.push(`    [${row}]${j < images[i].length - 1 ? ',' : ''}`);
      }
  
      output.push(`  ]${i < images.length - 1 ? ',' : ''}`);
    }
  
    output.push(']');
    return output.join('\n');
  }

function sendImageToMemory(filePath) {
    const inputBufferOffset = 0;
    const memory = new Uint8Array(currentInstance.exports.mem.buffer);

    const imageData = fs.readFileSync(filePath);
    console.log("Bytes [0] e [1] da imagem:", imageData[0], imageData[1]);
    console.log("Hex:", imageData[0].toString(16), imageData[1].toString(16));

    if (inputBufferOffset + imageData.length > memory.length) {
        throw new Error(`Imagem é muito grande para a memória disponível.`);
    }

    memory.set(imageData, inputBufferOffset);

    console.log(`Imagem enviada para a memória na posição ${inputBufferOffset} com tamanho ${imageData.length} bytes.`);
}

(async () => {
    const wasmBuffer = fs.readFileSync("extract_rgb.wasm"); // Nome do seu WASM novo
    const wasmModule = await WebAssembly.instantiate(wasmBuffer, {
        env: {
            log: (value) => console.log("LOG:", value),
        }
    });

    currentInstance = wasmModule.instance;

    // Enviar a imagem
    //sendImageToMemory("generated_96x96.raw");
    const memory = new Uint8Array(currentInstance.exports.mem.buffer);
    //memory.set([0xE0, 0x07], 0); // 0x07E0 = 2016

    memory.set([
        0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08,
        0x09, 0x0A, 0x0B, 0x0C,
        0x0D, 0x0E, 0x0F, 0x10
      ], 1);

    // Agora chamamos a função extractRGB
    //const rgb565 = currentInstance.exports.extract_rgb();

    // Imprimir valor diretamente em decimal e hexadecimal
    //console.log(`RGB565 decimal: ${rgb565}`);
    //console.log(`RGB565 hex: 0x${rgb565.toString(16).padStart(4, '0')}`);

    // ==== CHAMAR pad_image ====
    console.log("Resultado [Esquerda e Direita]:", currentInstance.exports.pad_image(5, 2, 3));
    console.log("Resultado [Cima e Baixo]:", currentInstance.exports.pad_image(5, 2, 3));


    // ==== Testar a função build_image_padded ====
    //const W = 96;
    //const H = 96;
    //const KERNEL_W = 5;
    //const KERNEL_H = 5;
    //const STRIDE_W = 2;
    //const STRIDE_H = 2;
    //const BYTES_PER_PIXEL = 2;
    //const START_INDEX = 0;
//
    //currentInstance.exports.build_image_padded(
    //    W, H,
    //    STRIDE_W, STRIDE_H,
    //    KERNEL_W, KERNEL_H,
    //    BYTES_PER_PIXEL,
    //    START_INDEX
    //);


    // === Verificar os bytes da imagem com padding ===
    //const mem = new Uint8Array(currentInstance.exports.mem.buffer);
    // Cálculo da posição de início da imagem com padding
    //const originalSize = W * H * BYTES_PER_PIXEL;
    //const startPadded = originalSize + START_INDEX;


    //console.log("Mostrando os primeiros 20 bytes da imagem com padding:");
    //const result = [];
    //for (let i = 0; i < mem.length; i++) {
    //    result.push(mem[i].toString(16).padStart(2, '0'));
    //}
    //console.log(result);

    //const hexDump = Array.from(mem, byte =>
    //    byte.toString(16).padStart(2, '0')
    //);
    // Salva memória como arquivo binário

    x = currentInstance.exports.convolve_apply_kernel(0, 4, 4, 0, 1, 0, 1, 1, 1, 2, 2);



    //const decimalDump = Array.from(mem); // já retorna os valores decimais
    //fs.writeFileSync('memory_bytes_decimal.json', JSON.stringify(decimalDump, null, 2));
    
    //fs.writeFileSync('memory_bytes.json', JSON.stringify(hexDump, null, 2));
    //console.log('Arquivo memory salva com sucesso!');


    //const width = 96;
    //const height = 96;
    //const bytesPerPixel = 2;
    //const rowSize = width * bytesPerPixel;
    //const imageSize = rowSize * height;
//
    //const numImages = Math.floor(mem.length / imageSize);
    //const images = [];
//
    //for (let img = 0; img < numImages; img++) {
    //const image = [];
    //const baseOffset = img * imageSize;
//
    //for (let row = 0; row < height; row++) {
    //    const rowOffset = baseOffset + row * rowSize;
    //    const rowBytes = [];
//
    //    for (let i = 0; i < rowSize; i++) {
    //    rowBytes.push(mem[rowOffset + i]);
    //    }
//
    //    image.push(rowBytes);
    //}
//
    //images.push(image);
    //}

    //console.log(images);
    //const jsonCompact = stringifyImagesCompact(images);
    //fs.writeFileSync('memory_images_compact.json', jsonCompact);

    //fs.writeFileSync('memory_images_bytes.json', JSON.stringify(images, null, 2));

})();
