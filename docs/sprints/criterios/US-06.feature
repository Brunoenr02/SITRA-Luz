Feature: Seleccionar medicamentos y cantidades

  Scenario: Seleccionar medicamentos disponibles
    Given que el usuario ha iniciado sesión
    And existen medicamentos disponibles
    When selecciona un medicamento
    And indica una cantidad válida
    Then el sistema debe mostrar el medicamento seleccionado
    And debe mostrar la cantidad indicada

  Scenario: No existen medicamentos disponibles
    Given que el usuario ha iniciado sesión
    And no existen medicamentos disponibles
    When abre la pantalla de selección de medicamentos
    Then el sistema debe mostrar un mensaje indicando que no hay medicamentos
    And no debe permitir agregar medicamentos

  Scenario: Selección sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el usuario abre la pantalla de medicamentos
    Then el sistema debe mostrar los datos disponibles localmente
    And debe informar que podrían estar desactualizados

  Scenario: Error del servidor al cargar medicamentos
    Given que el servidor responde con un error 500
    When el usuario abre la pantalla de medicamentos
    Then el sistema debe mostrar un mensaje de error comprensible
    And debe permitir reintentar la carga

