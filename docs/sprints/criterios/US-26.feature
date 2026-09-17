Feature: Notificación de nuevas peticiones para Farmacia

  Scenario: Existe una nueva petición
    Given que el usuario de Farmacia ha iniciado sesión
    And existe una nueva petición
    When el sistema procesa la petición
    Then Farmacia debe recibir una notificación
    And debe poder acceder al detalle de la petición

  Scenario: No existen nuevas peticiones
    Given que no existen nuevas peticiones
    When Farmacia consulta sus notificaciones
    Then no debe mostrar alertas de nuevas peticiones
    And debe mostrar las notificaciones disponibles

  Scenario: Sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el sistema intenta entregar una notificación
    Then debe informar que no existe conexión
    And debe permitir reintentar

  Scenario: Error del servidor
    Given que existe una nueva petición
    And el servidor presenta un error
    When el sistema procesa la notificación
    Then debe registrar el error
    And debe permitir reintentar

