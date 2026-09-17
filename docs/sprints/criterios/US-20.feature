Feature: Consultar usuario solicitante

  Scenario: Existe información del solicitante
    Given que existe una petición registrada
    When el administrador consulta la trazabilidad
    Then debe visualizar el usuario que realizó la petición
    And debe visualizar la información necesaria para la auditoría

  Scenario: No existe información del solicitante
    Given que una petición no tiene usuario asociado
    When el administrador consulta la trazabilidad
    Then debe mostrar que no existe información del solicitante
    And debe informar que el registro está incompleto

  Scenario: Sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el administrador consulta la trazabilidad
    Then debe mostrar los datos disponibles localmente
    And debe informar que podrían estar desactualizados

  Scenario: Error del servidor
    Given que el servidor responde con un error 500
    When el administrador consulta la trazabilidad
    Then debe mostrar un mensaje de error
    And debe permitir reintentar

