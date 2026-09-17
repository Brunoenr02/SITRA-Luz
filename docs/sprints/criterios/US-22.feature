Feature: Consultar doctor asociado a una petición

  Scenario: La petición tiene doctor asociado
    Given que existe una petición registrada
    When el administrador consulta la petición
    Then debe visualizar el doctor responsable
    And debe visualizar la información asociada a la petición

  Scenario: La petición no tiene doctor
    Given que existe una petición sin doctor asociado
    When el administrador consulta la petición
    Then debe informar que no existe doctor asociado
    And debe identificar el registro como incompleto

  Scenario: Sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el administrador consulta la petición
    Then debe mostrar los datos disponibles localmente
    And debe informar que podrían estar desactualizados

  Scenario: Error del servidor
    Given que el servidor presenta un error
    When el administrador consulta la petición
    Then debe mostrar un mensaje de error
    And debe permitir reintentar

