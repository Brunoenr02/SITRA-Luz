Feature: Visualizar medicamentos próximos a vencer

  Scenario: Existen medicamentos próximos a vencer
    Given que existen medicamentos próximos a su fecha de vencimiento
    When el usuario de Almacén consulta el inventario
    Then debe visualizar los medicamentos próximos a vencer
    And debe visualizar su fecha de vencimiento

  Scenario: No existen medicamentos próximos a vencer
    Given que no existen medicamentos próximos a vencer
    When consulta el inventario
    Then debe mostrar un mensaje indicando que no existen alertas
    And debe mostrar el inventario disponible

  Scenario: Sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When consulta el inventario
    Then debe mostrar la información disponible localmente
    And debe informar que podría estar desactualizada

  Scenario: Error del servidor
    Given que el servidor presenta un error
    When consulta el inventario
    Then debe mostrar un mensaje de error
    And debe permitir reintentar

