Feature: Registrar despacho de medicamentos

  Scenario: Registrar despacho correctamente
    Given que existe una petición lista para despacho
    When el usuario de Farmacia registra los medicamentos entregados
    Then el sistema debe registrar el despacho
    And debe guardar la fecha, hora y usuario responsable

  Scenario: No existen medicamentos para despachar
    Given que la petición no contiene medicamentos disponibles
    When el usuario intenta registrar el despacho
    Then debe mostrar un mensaje indicando que no existen medicamentos
    And no debe registrar el despacho

  Scenario: Sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el usuario registra un despacho
    Then debe informar que no existe conexión
    And debe permitir reintentar

  Scenario: Error del servidor
    Given que el servidor presenta un error
    When el usuario registra un despacho
    Then debe mostrar un mensaje de error
    And no debe confirmar el despacho

