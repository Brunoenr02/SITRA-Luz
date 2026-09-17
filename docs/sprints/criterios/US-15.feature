Feature: Registrar receptor del medicamento

  Scenario: Registrar receptor correctamente
    Given que existe un despacho pendiente
    When el usuario registra los datos del receptor
    Then el sistema debe asociar el receptor al despacho
    And debe guardar la fecha y hora de recepción

  Scenario: Datos del receptor incompletos
    Given que existe un despacho pendiente
    When el usuario intenta registrar un receptor sin los datos requeridos
    Then el sistema debe indicar los campos obligatorios
    And no debe completar el registro

  Scenario: Sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el usuario registra los datos del receptor
    Then debe informar que no existe conexión
    And debe permitir reintentar

  Scenario: Error del servidor
    Given que los datos del receptor son válidos
    And el servidor presenta un error
    When el usuario guarda el registro
    Then debe mostrar un mensaje de error
    And no debe confirmar el registro

