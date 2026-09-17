Feature: Revisar detalle de una petición

  Scenario: La petición tiene medicamentos
    Given que el usuario de Farmacia ha iniciado sesión
    And existe una petición registrada con medicamentos
    When abre el detalle de la petición
    Then debe visualizar los medicamentos solicitados
    And debe visualizar las cantidades, usuario solicitante y doctor responsable

  Scenario: La petición no tiene medicamentos
    Given que el usuario de Farmacia ha iniciado sesión
    And existe una petición sin medicamentos registrados
    When abre el detalle de la petición
    Then debe mostrar un mensaje indicando que no hay medicamentos
    And no debe permitir procesar una petición incompleta

  Scenario: Consulta sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el usuario de Farmacia abre el detalle de una petición
    Then debe mostrar la información disponible localmente
    And debe informar que los datos podrían estar desactualizados

  Scenario: Error del servidor
    Given que el usuario de Farmacia ha iniciado sesión
    And el servidor responde con un error 500
    When abre el detalle de una petición
    Then debe mostrar un mensaje de error comprensible
    And debe permitir reintentar la consulta

