Feature: Cambiar estado de una petición

  Scenario: Cambiar estado correctamente
    Given que el usuario de Farmacia ha iniciado sesión
    And existe una petición pendiente
    When cambia el estado de la petición
    Then el sistema debe guardar el nuevo estado
    And debe mostrar el estado actualizado

  Scenario: No existen peticiones
    Given que no existen peticiones pendientes
    When el usuario intenta cambiar un estado
    Then el sistema debe informar que no existen peticiones
    And no debe realizar ningún cambio

  Scenario: Sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el usuario cambia el estado de una petición
    Then el sistema debe informar que no existe conexión
    And debe permitir reintentar

  Scenario: Error del servidor
    Given que existe una petición
    And el servidor presenta un error
    When el usuario cambia su estado
    Then debe mostrar un mensaje de error
    And no debe confirmar el cambio

