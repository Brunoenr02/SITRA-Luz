Feature: Consultar historial de transferencias

  Scenario: Existen transferencias
    Given que existen transferencias registradas
    When el usuario consulta el historial
    Then debe visualizar las transferencias
    And debe visualizar fecha, usuario y estado

  Scenario: Historial vacío
    Given que no existen transferencias registradas
    When el usuario consulta el historial
    Then debe mostrar un mensaje indicando que no existen transferencias
    And debe permitir actualizar la consulta

  Scenario: Sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When consulta el historial
    Then debe mostrar los datos disponibles localmente
    And debe informar que podrían estar desactualizados

  Scenario: Error del servidor
    Given que el servidor responde con un error 500
    When consulta el historial
    Then debe mostrar un mensaje de error comprensible
    And debe permitir reintentar

