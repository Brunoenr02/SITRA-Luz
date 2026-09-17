Feature: Registro de usuario

  Scenario: Registro exitoso
    Given que el usuario no tiene una cuenta registrada
    When ingresa un correo válido y los datos requeridos
    And selecciona "Registrarse"
    Then el sistema debe crear la cuenta
    And debe mostrar un mensaje indicando que el registro fue exitoso

  Scenario: Registro con correo ya registrado
    Given que el correo ya pertenece a una cuenta existente
    When el usuario intenta registrarse con ese correo
    Then el sistema debe informar que el correo ya está registrado
    And no debe crear una cuenta duplicada

  Scenario: Registro sin conexión
    Given que el dispositivo no tiene conexión a Internet
    When el usuario intenta registrarse
    Then el sistema debe informar que no existe conexión
    And debe permitir intentar nuevamente

  Scenario: Error del servidor durante el registro
    Given que el servidor presenta un error
    When el usuario envía sus datos de registro
    Then el sistema debe mostrar un mensaje de error comprensible
    And no debe crear la cuenta

