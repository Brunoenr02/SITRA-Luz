Feature: Notificaciones de cambios de estado

  Scenario: Existe un cambio de estado
    Given que el usuario tiene una petición registrada
    And el estado de la petición cambia
    When el sistema procesa el cambio
    Then el usuario debe recibir una notificación
    And debe visualizar el nuevo estado

  Scenario: No existen cambios de estado
    Given que el usuario no tiene cambios recientes
    When consulta sus notificaciones
    Then no debe mostrar notificaciones de cambios
    And debe mostrar las notificaciones disponibles

  Scenario: Sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el sistema intenta entregar una notificación
    Then debe informar que no existe conexión
    And debe permitir reintentar

  Scenario: Error del servidor
    Given que existe un cambio de estado
    And el servidor presenta un error
    When se procesa la notificación
    Then debe registrar el error
    And debe permitir reintentar

