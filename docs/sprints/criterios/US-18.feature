Feature: Registrar recepción de medicamentos

  Scenario: Registrar recepción correctamente
    Given que existe una transferencia enviada desde Almacén
    When el usuario de Farmacia registra la recepción
    Then el sistema debe registrar los medicamentos recibidos
    And debe actualizar el estado de la transferencia

  Scenario: No existen transferencias pendientes
    Given que no existen transferencias pendientes
    When el usuario consulta las recepciones
    Then debe mostrar un mensaje indicando que no hay transferencias
    And no debe permitir registrar una recepción inexistente

  Scenario: Sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el usuario registra una recepción
    Then debe informar que no existe conexión
    And debe permitir reintentar

  Scenario: Error del servidor
    Given que existe una transferencia pendiente
    And el servidor presenta un error
    When el usuario registra la recepción
    Then debe mostrar un mensaje de error
    And no debe confirmar la recepción

