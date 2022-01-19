# FoxPager
Paginador flexible para tratamientos de datos en bloques. Lo `flexible` viene de que es capaz de llamar a tu `callback` que realizará el trabajo. Dicho proceso puede estar en un objeto o procedimiento, con objeto me refiero tanto a objetos instanciados de clases personales o también objetos de un formulario como un `commandbutton`.

# Ejemplos

Supongamos que tienes un cursor `Clientes` con 100.000 registros y quieres darle tratamiento por bloques.

# Uso 1: callback desde un procedure

```xBase
   // 1. declarar la librería
   SET PROCEDURE TO "FoxPager" ADDITIVE
   // 2. crear la instancia de foxPager
   oFoxPager = CREATEOBJECT("FoxPager")
   // 3. usas sesiones privadas? entonces dícelo a FoxPager
   oFoxPager.setDatasessionid(set("Datasession"))
   // 4. setCursorName => nombre del cursor principal
   oFoxPager.setCursorName('Clientes')
   // 5. setPageRange => es el rango de registros por páginas. Por defecto de 5 en 5.
   oFoxPager.setPageRange(10)   
   // 6. setDelegateEvent => nombre del método que se encargará de analizar los registros.
   oFoxPager.setDelegateEvent("procesarBloqueDeClientes")
   // 7. quieres darle un nombre personalizado al cursor resultante? entonces dícelo a FoxPager
   oFoxPager.setResultName('BloqueClientes')
   // 8. lanzar el paginador
   oFoxPager.run()
   
   // procedimiento que hará de 'callback' en cada bloque de registros.
   PROCEDURE procesarBloqueDeClientes
      SELECT BloqueClientes
      SCAN
         ?BloqueClientes.ClienteID
         ?BloqueClientes.Nombre
      ENDSCAN
   ENDPROC
```
