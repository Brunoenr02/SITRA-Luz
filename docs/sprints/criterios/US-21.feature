Feature: Consultar fecha y hora de movimientos

  Scenario: Existen movimientos registrados
    Given que existen movimientos de medicamentos
    When el administrador consulta la trazabilidad
    Then debe visualizar la fecha y hora de cada movimiento
    And debe poder identificar el movimiento correspondiente

  Scenario: No existen movimientos
    Given que no existen movimientos registrados
    When el administrador consulta la trazabilidad
    Then debe mostrar un mensaje indicando que no existen movimientos
    And no debe mostrar información inexistente

  Scenario: Sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el administrador consulta los movimientos
    Then debe mostrar los datos disponibles localmente
    And debe informar que podrían estar desactualizados

  Scenario: Error del servidor
    Given que el servidor presenta un error
    When el administrador consulta los movimientos
    Then debe mostrar un mensaje de error
    And debe permitir reintentar

