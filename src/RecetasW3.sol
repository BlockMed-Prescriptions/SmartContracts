// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RecetasW3 {
    struct Medicamento {
        string codigo;
        uint cantidad;
    }

    struct Receta {
        string hash;
        bool dispensada;
        string DIDfarmacia;
        Medicamento[] medicamentos;
        string lote; // Nuevo campo para el lote
        uint256 bloque; // Nuevo campo para el bloque de la transacción
    }

    mapping(string => Receta) public recetas;

    event RecetaEmitida(string hash);
    event RecetaDispensada(string hash, string DIDfarmacia, string lote);

    function emitirReceta(
        string memory _hash,
        Medicamento[] memory _medicamentos
    ) public {
        require(bytes(_hash).length != 0, unicode"El hash no puede estar vacío.");
        require(bytes(recetas[_hash].hash).length == 0, unicode"La receta ya ha sido emitida.");
        
        Receta storage receta = recetas[_hash];
        receta.hash = _hash;
        receta.dispensada = false;
        receta.DIDfarmacia = "";
        receta.lote = ""; // Inicialmente vacío
        receta.bloque = block.number; // Guardar el bloque de la transacción

        for (uint i = 0; i < _medicamentos.length; i++) {
            receta.medicamentos.push(Medicamento({
                codigo: _medicamentos[i].codigo,
                cantidad: _medicamentos[i].cantidad
            }));
        }

        emit RecetaEmitida(_hash);
    }

    function dispensarMedicamento(string memory _hash, string memory _DIDfarmacia, string memory _lote) public {
        Receta storage receta = recetas[_hash];
        require(bytes(recetas[_hash].hash).length != 0, unicode"La receta no existe.");
        require(!receta.dispensada, unicode"La receta ya fue dispensada.");
        
        receta.DIDfarmacia = _DIDfarmacia;
        receta.lote = _lote; // Completar el campo lote
        receta.dispensada = true;

        emit RecetaDispensada(_hash, _DIDfarmacia, _lote);
    }

    function verificarReceta(string memory _hash) public view returns (Receta memory) {
        return recetas[_hash];
    }
}
