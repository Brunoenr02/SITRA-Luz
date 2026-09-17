Feature: Notificación de pedido listo para recojo

  Scenario: Pedido listo para recojo
    Given que el usuario tiene una petición registrada
    And Farmacia cambia el estado a "Listo para recojo"
    When el sistema procesa el cambio de estado
    Then el usuario debe recibir una notificación
    And la notificación debe indicar que su pedido está listo para recojo

  Scenario: No existen pedidos listos
    Given que el usuario ha iniciado sesión
    And no tiene pedidos en estado "Listo para recojo"
    When consulta sus notificaciones
    Then no debe mostrar notificaciones de pedidos listos
    And debe mostrar las notificaciones disponibles

  Scenario: Sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el sistema intenta entregar una notificación
    Then debe informar que no existe conexión
    And la notificación debe quedar disponible para reintentar

  Scenario: Error del servidor
    Given que existe un pedido listo para recojo
    And el servidor presenta un error
    When el sistema intenta procesar la notificación
    Then debe registrar el error
    And debe permitir reintentar el proceso

