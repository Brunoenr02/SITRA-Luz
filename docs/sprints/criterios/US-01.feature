Feature: Inicio de sesión

  Scenario: Inicio de sesión con credenciales válidas
    Given que el usuario tiene una cuenta registrada
    When ingresa un correo y contraseña válidos
    And selecciona "Iniciar sesión"
    Then el sistema debe permitir el acceso a SITRA-Luz
    And debe crear la sesión del usuario

  Scenario: Inicio de sesión con credenciales inválidas
    Given que el usuario tiene una cuenta registrada
    When ingresa una contraseña incorrecta
    And selecciona "Iniciar sesión"
    Then el sistema debe mostrar un mensaje de credenciales inválidas
    And no debe permitir el acceso

  Scenario: Inicio de sesión sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el usuario intenta iniciar sesión
    Then el sistema debe informar que no existe conexión
    And debe permitir intentar nuevamente

  Scenario: Error del servidor durante el inicio de sesión
    Given que el servidor presenta un error
    When el usuario intenta iniciar sesión con credenciales válidas
    Then el sistema debe mostrar un mensaje de error
    And no debe iniciar la sesión

