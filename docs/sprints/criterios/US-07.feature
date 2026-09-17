Feature: Indicar doctor y motivo de la petición

  Scenario: Registrar doctor y motivo correctamente
    Given que el usuario ha iniciado sesión
    And existe una petición de medicamentos
    When selecciona un doctor responsable
    And ingresa el motivo de la petición
    Then el sistema debe asociar el doctor a la petición
    And debe guardar el motivo indicado

  Scenario: No se selecciona un doctor
    Given que el usuario ha iniciado sesión
    And existe una petición de medicamentos
    When intenta enviar la petición sin seleccionar un doctor
    Then el sistema debe indicar que el doctor es obligatorio
    And no debe permitir enviar la petición

  Scenario: Registrar información sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el usuario intenta guardar el doctor y el motivo
    Then el sistema debe informar que no existe conexión
    And debe permitir reintentar la operación

  Scenario: Error del servidor
    Given que el usuario ha seleccionado un doctor y un motivo
    And el servidor presenta un error
    When intenta guardar la información
    Then el sistema debe mostrar un mensaje de error comprensible
    And no debe confirmar la operación como registrada

