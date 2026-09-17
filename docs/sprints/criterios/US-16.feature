Feature: Consultar disponibilidad de medicamentos

  Scenario: Existen medicamentos disponibles
    Given que el usuario de Almacén ha iniciado sesión
    And existen medicamentos registrados
    When consulta el inventario
    Then debe visualizar los medicamentos disponibles
    And debe visualizar su stock actual

  Scenario: Inventario vacío
    Given que no existen medicamentos registrados
    When consulta el inventario
    Then debe mostrar un mensaje indicando que el inventario está vacío
    And debe permitir actualizar la información

  Scenario: Consulta sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When consulta el inventario
    Then debe mostrar los datos disponibles localmente
    And debe informar que podrían estar desactualizados

  Scenario: Error del servidor
    Given que el servidor responde con un error 500
    When consulta el inventario
    Then debe mostrar un mensaje de error comprensible
    And debe permitir reintentar

