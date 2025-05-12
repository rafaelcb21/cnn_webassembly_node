## Comandos

```
wat2wasm add.wat -o add.wasm
wasm-interp add.wasm -r "somar" -a "i32:5" -a "i32:3"

node main.js
```

https://www.w3.org/TR/wasm-core-1/
https://developer.mozilla.org/pt-BR/docs/WebAssembly/Guides/Understanding_the_text_format
https://developer.mozilla.org/en-US/docs/WebAssembly/Reference/Control_flow/if...else

Todo o código em um módulo webassembly é agrupado em funções
( func <assinatura> <locais> <corpo> )

todas as palavras reservadas