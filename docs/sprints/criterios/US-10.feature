Feature: Consultar historial de peticiones

  Scenario: El usuario tiene historial
    Given que el usuario ha iniciado sesión
    And tiene peticiones registradas anteriormente
    When abre el historial de peticiones
    Then debe visualizar sus peticiones anteriores
    And debe visualizar el estado y la fecha de cada petición

  Scenario: El historial está vacío
    Given que el usuario ha iniciado sesión
    And no tiene peticiones registradas
    When abre el historial de peticiones
    Then debe mostrar un mensaje indicando que no existen peticiones
    And debe mostrar una opción para registrar una nueva petición

  Scenario: Consulta sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el usuario abre el historial de peticiones
    Then debe mostrar la información disponible localmente
    And debe informar que los datos podrían estar desactualizados

  Scenario: Error del servidor
    Given que el usuario ha iniciado sesión
    And el servidor responde con un error 500
    When abre el historial de peticiones
    Then debe mostrar un mensaje de error comprensible
    And debe permitir reintentar la consulta

