Feature: US-03 - Recuperar contraseña

Scenario: Recuperación con correo registrado
  Given que el usuario está en la pantalla de recuperación
  When ingresa un correo registrado y solicita recuperar su contraseña
  Then el sistema debe enviar las instrucciones de recuperación

Scenario: Correo no registrado
  Given que el usuario está en la pantalla de recuperación
  When ingresa un correo no registrado
  Then el sistema debe informar que no existe una cuenta asociada

Scenario: Sin conexión
  Given que el usuario está en la pantalla de recuperación
  And no existe conexión a Internet
  When solicita recuperar su contraseña
  Then el sistema debe informar que no hay conexión

Scenario: Error del servidor
  Given que el usuario está en la pantalla de recuperación
  When ocurre un error del servidor
  Then el sistema debe mostrar un mensaje de error
