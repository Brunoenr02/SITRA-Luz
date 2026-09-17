Feature: US-04 - Gestionar perfil de usuario

Scenario: Visualizar datos del perfil
  Given que el usuario inició sesión
  When accede a su perfil
  Then el sistema debe mostrar sus datos registrados

Scenario: Perfil sin datos
  Given que el usuario inició sesión
  And no existen datos adicionales registrados
  When accede a su perfil
  Then el sistema debe mostrar el perfil disponible sin información adicional

Scenario: Sin conexión
  Given que el usuario está consultando su perfil
  And no existe conexión a Internet
  When solicita cargar sus datos
  Then el sistema debe informar que no hay conexión

Scenario: Error del servidor
  Given que el usuario está consultando su perfil
  When ocurre un error del servidor
  Then el sistema debe mostrar un mensaje de error
