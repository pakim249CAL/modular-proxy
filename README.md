## Modular Proxy

This repository hosts my take on the EIP-2535 proxy pattern. It works using the same mechanics as EIP-2535, but strips out a lot of the code to simplify the implementation. Contracts are built out using "modules" using namespaced storage rather than the default solidity storage layout. This pattern allows for an effectively unlimited contract size, eliminates the possibility of storage alignment errors in upgrades, and provides unlimited flexibility due to overcoming the limitation in libraries of accessing contract storage.
