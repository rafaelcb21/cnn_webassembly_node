const fs = require('fs');

let currentInstance;

(async () => {
    const wasmBuffer = fs.readFileSync("extract_rgb.wasm"); // Nome do seu WASM novo
    const wasmModule = await WebAssembly.instantiate(wasmBuffer, {
        env: {
            log: (value) => console.log("LOG:", value),
        }
    });

    currentInstance = wasmModule.instance;

    // ==== CHAMAR pad_image ====
    // (param $wh_img i32) (param $wh_stride i32) (param $wh_kernel i32)
    console.log("Resultado [Esquerda e Direita]:", currentInstance.exports.pad_image(4, 1, 3));
    console.log("Resultado [Cima e Baixo]:", currentInstance.exports.pad_image(4, 1, 3));

    //(param $h_img i32)      ;; altura da imagem real
    //(param $w_img i32)      ;; largura da imagem real
    //(param $h_kernel i32)   ;; altura do kernel
    //(param $w_kernel i32)   ;; largura do kernel
    //(param $stride_h i32)   ;; stride vertical
    //(param $stride_w i32)   ;; stride horizontal
    // retorna: (pad_top, pad_bottom, pad_left, pad_right)
    console.log("Resultado [Cima e Baixo]:",
        currentInstance.exports.calculate_padding_4(4, 4, 3, 3, 1, 1));
    
    console.log("Resultado [Cima e Baixo]:",
        currentInstance.exports.calculate_padding_4(5, 6, 4, 3, 2, 2));



    



    

})();
