Feature: Visualizar peticiones pendientes en Farmacia

  Scenario: Existen peticiones pendientes
    Given que el usuario de Farmacia ha iniciado sesión
    And existen peticiones pendientes
    When abre la pantalla de peticiones
    Then debe visualizar las peticiones pendientes
    And debe visualizar el usuario solicitante, fecha y estado

  Scenario: No existen peticiones pendientes
    Given que el usuario de Farmacia ha iniciado sesión
    And no existen peticiones pendientes
    When abre la pantalla de peticiones
    Then debe mostrar un mensaje indicando que no hay peticiones pendientes
    And debe permitir actualizar la lista

  Scenario: Consulta sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el usuario de Farmacia abre la pantalla de peticiones
    Then debe mostrar la información disponible localmente
    And debe informar que los datos podrían estar desactualizados

  Scenario: Error del servidor
    Given que el usuario de Farmacia ha iniciado sesión
    And el servidor responde con un error 500
    When abre la pantalla de peticiones
    Then debe mostrar un mensaje de error comprensible
    And debe permitir reintentar la consulta

