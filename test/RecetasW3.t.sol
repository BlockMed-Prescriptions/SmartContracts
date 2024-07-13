// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/RecetasW3.sol";

contract RecetasW3Test is Test {
    RecetasW3 private recetas;
    string private constant HASH = "hash123";
    string private constant HASH2 = "hash124";
    RecetasW3.Medicamento[] private medicamentos;

    function setUp() public {
        recetas = new RecetasW3();
        RecetasW3.Medicamento memory medicamento = RecetasW3.Medicamento({
            codigo: "COD123",
            cantidad: 10,
            lote: "LOTE123" // Añadir el lote aquí
        });
        medicamentos.push(medicamento);
    }

    function testEmitirRecetaCorrectamente() public {
        recetas.emitirReceta(HASH);
        RecetasW3.Receta memory rec = recetas.verificarReceta(HASH);
        assertEq(rec.hash, HASH);
        assertFalse(rec.dispensada);
        assertEq(rec.bloque, block.number);
    }

    function testDispensarMedicamentoCorrectamente() public {
        recetas.emitirReceta(HASH);
        recetas.dispensarMedicamento(HASH, "DID123", medicamentos);
        RecetasW3.Receta memory rec = recetas.verificarReceta(HASH);
        assertTrue(rec.dispensada);
        assertEq(rec.DIDfarmacia, "DID123");
        assertEq(rec.medicamentos.length, 1);
        assertEq(rec.medicamentos[0].lote, "LOTE123");
    }

    function testFalloAlDispensarMedicamentoNoEmitido() public {
        vm.expectRevert(unicode"La receta no existe.");
        recetas.dispensarMedicamento(HASH, "DID123", medicamentos);
    }

    function testEmitirRecetaConHashVacio() public {
        vm.expectRevert(unicode"El hash no puede estar vacío.");
        recetas.emitirReceta("");
    }

    function testEmitirRecetaConArrayMedicamentosVacio() public {
        recetas.emitirReceta(HASH2);
        RecetasW3.Receta memory rec = recetas.verificarReceta(HASH2);
        assertEq(rec.hash, HASH2);
        assertFalse(rec.dispensada);
        assertEq(rec.medicamentos.length, 0);
    }

    function testDispensarRecetaConHashVacio() public {
        vm.expectRevert(unicode"La receta no existe.");
        recetas.dispensarMedicamento("", "DID123", medicamentos);
    }

    function testDispensarRecetaYaDispensadaConDidDiferente() public {
        recetas.emitirReceta(HASH);
        recetas.dispensarMedicamento(HASH, "DID123", medicamentos);
        vm.expectRevert(unicode"La receta ya fue dispensada.");
        recetas.dispensarMedicamento(HASH, "DID124", medicamentos);
    }

    function testEmitirMultiplesRecetas() public {
        recetas.emitirReceta(HASH);
        recetas.emitirReceta(HASH2);
        RecetasW3.Receta memory rec1 = recetas.verificarReceta(HASH);
        RecetasW3.Receta memory rec2 = recetas.verificarReceta(HASH2);
        assertEq(rec1.hash, HASH);
        assertEq(rec2.hash, HASH2);
    }

    function testVerificarRecetaNoExistente() public {
        RecetasW3.Receta memory rec = recetas.verificarReceta(HASH);
        assertEq(rec.hash, "");
    }

    function testNumeroDeBloqueNoCambiaDespuesDeDispensar() public {
        recetas.emitirReceta(HASH);
        uint256 bloque = block.number;
        recetas.dispensarMedicamento(HASH, "DID123", medicamentos);
        RecetasW3.Receta memory rec = recetas.verificarReceta(HASH);
        assertEq(rec.bloque, bloque);
    }

    function testEmitirRecetaConHashExistenteDiferentesMedicamentos() public {
        recetas.emitirReceta(HASH);
        RecetasW3.Medicamento[] memory nuevosMedicamentos = new RecetasW3.Medicamento[](1);
        RecetasW3.Medicamento memory nuevoMedicamento = RecetasW3.Medicamento({
            codigo: "COD124",
            cantidad: 5,
            lote: "LOTE124" // Añadir el lote aquí
        });
        nuevosMedicamentos[0] = nuevoMedicamento; // Asignar el elemento por índice
        vm.expectRevert(unicode"La receta ya ha sido emitida.");
        recetas.emitirReceta(HASH);
    }

    function testVerificarDidFarmaciaNoSeActualiza() public {
        recetas.emitirReceta(HASH);
        recetas.dispensarMedicamento(HASH, "DID123", medicamentos);
        RecetasW3.Receta memory rec = recetas.verificarReceta(HASH);
        assertEq(rec.DIDfarmacia, "DID123");
        vm.expectRevert(unicode"La receta ya fue dispensada.");
        recetas.dispensarMedicamento(HASH, "DID124", medicamentos);
        rec = recetas.verificarReceta(HASH);
        assertEq(rec.DIDfarmacia, "DID123");
    }

    function testVerificarLoteNoSeActualiza() public {
        recetas.emitirReceta(HASH);
        recetas.dispensarMedicamento(HASH, "DID123", medicamentos);
        RecetasW3.Receta memory rec = recetas.verificarReceta(HASH);
        assertEq(rec.medicamentos[0].lote, "LOTE123");
        vm.expectRevert(unicode"La receta ya fue dispensada.");
        recetas.dispensarMedicamento(HASH, "DID123", medicamentos);
        rec = recetas.verificarReceta(HASH);
        assertEq(rec.medicamentos[0].lote, "LOTE123");
    }
}
