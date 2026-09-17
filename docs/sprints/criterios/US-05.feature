Feature: Registrar petición de medicamentos

  Scenario: Registrar una petición correctamente
    Given que el usuario ha iniciado sesión
    And existen medicamentos disponibles
    When selecciona los medicamentos y las cantidades requeridas
    And indica el doctor responsable y el motivo
    And envía la petición
    Then el sistema debe registrar la petición
    And debe mostrar el estado "Pendiente"

  Scenario: No existen medicamentos disponibles
    Given que el usuario ha iniciado sesión
    And no existen medicamentos disponibles
    When intenta registrar una petición
    Then el sistema debe informar que no hay medicamentos disponibles
    And no debe permitir enviar una petición vacía

  Scenario: Registrar petición sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el usuario intenta enviar una petición
    Then el sistema debe informar que no existe conexión
    And debe permitir reintentar el envío

  Scenario: Error del servidor al registrar la petición
    Given que el usuario ha completado los datos de la petición
    And el servidor presenta un error
    When el usuario envía la petición
    Then el sistema debe mostrar un mensaje de error comprensible
    And la petición no debe registrarse como enviada

