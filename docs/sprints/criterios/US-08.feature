Feature: Consultar estado de una petición

  Scenario: La petición tiene información
    Given que el usuario ha iniciado sesión
    And tiene al menos una petición registrada
    When abre el historial de peticiones
    Then debe visualizar sus peticiones
    And debe visualizar el estado de cada petición

  Scenario: No existen peticiones
    Given que el usuario ha iniciado sesión
    And no tiene peticiones registradas
    When abre el historial de peticiones
    Then debe mostrar un mensaje indicando que no existen peticiones
    And debe mostrar una opción para registrar una nueva petición

  Scenario: Consulta sin conexión
    Given que el dispositivo no tiene conexión a Internet
    And existen peticiones guardadas localmente
    When el usuario consulta sus peticiones
    Then debe visualizar la información disponible localmente
    And debe informar que los datos podrían estar desactualizados

  Scenario: Error del servidor al consultar
    Given que el usuario ha iniciado sesión
    And el servidor responde con un error 500
    When consulta sus peticiones
    Then debe mostrar un mensaje de error comprensible
    And debe permitir reintentar la consulta

