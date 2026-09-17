Feature: Alertas de medicamentos próximos a vencer

  Scenario: Existen medicamentos próximos a vencer
    Given que existen medicamentos próximos a su fecha de vencimiento
    When el usuario de Farmacia consulta el inventario
    Then debe visualizar una alerta de vencimiento
    And debe identificar los medicamentos que requieren atención

  Scenario: No existen medicamentos próximos a vencer
    Given que no existen medicamentos próximos a vencer
    When el usuario consulta el inventario
    Then no debe mostrar alertas de vencimiento
    And debe mostrar el inventario normalmente

  Scenario: Sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When consulta las alertas de vencimiento
    Then debe mostrar los datos disponibles localmente
    And debe informar que podrían estar desactualizados

  Scenario: Error del servidor
    Given que el servidor responde con un error
    When consulta las alertas
    Then debe mostrar un mensaje de error comprensible
    And debe permitir reintentar

