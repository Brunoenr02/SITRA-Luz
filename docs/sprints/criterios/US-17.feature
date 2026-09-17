Feature: Registrar transferencia de medicamentos

  Scenario: Registrar transferencia correctamente
    Given que existen medicamentos disponibles en Almacén
    When el usuario registra una transferencia hacia Farmacia
    Then el sistema debe registrar los medicamentos transferidos
    And debe registrar el usuario, fecha y hora

  Scenario: No existe stock suficiente
    Given que el stock disponible es menor a la cantidad solicitada
    When el usuario intenta registrar la transferencia
    Then el sistema debe informar que no existe stock suficiente
    And no debe completar la transferencia

  Scenario: Sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el usuario registra una transferencia
    Then debe informar que no existe conexión
    And debe permitir reintentar

  Scenario: Error del servidor
    Given que existe stock suficiente
    And el servidor presenta un error
    When el usuario registra la transferencia
    Then debe mostrar un mensaje de error
    And no debe confirmar la transferencia

