# FoxPager
Paginador flexible para tratamientos de datos en bloques. Lo `flexible` viene de que es capaz de llamar a tu `callback` que realizará el trabajo. Dicho proceso puede estar en un objeto o procedimiento, con objeto me refiero tanto a objetos instanciados de clases personales o también objetos de un formulario como un `commandbutton`.

## Propiedades y Métodos

- **sendDelegateParams** es una propiedad boolean que le indica a `FoxPager` que el `callback` recibirá 2 parámetros: **nMinRow** y **nMaxRow**. Por ejemplo 1 y 5 indicando que el bloque actual comprende el registro 1 hasta el registro 5.
- **setPageRange(tnRange)** ajusta el número de registros por página. Por defecto es 5.
- **setCursorName(tcName)** es el nombre del cursor base desde donde se obtendrán los datos.
- **setDataSessionID(tnSessionID)** si usas sesiones privadas entonces tienes que indicarla aquí.
- **setEventHandler(toHandler)** es el nombre del objeto que contiene el método que hará de `callback`. Si tienes un `PROCEDURE` entonces no es necesario setear este método.
- **setCallback(tcCallback)** es el nombre del procedimiento, método o evento que analizará el bloque de registros.
- **setResultName(tcName)** es el nombre del cursor resultante, es decir, el cursor que contendrá los datos en cada bloque. Por defecto es `cResult`.


## Ejemplos
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
   // 6. setCallback => nombre del método que se encargará de analizar los registros.
   oFoxPager.setCallback("procesarBloqueDeClientes")
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

# Uso 2: callback desde un objeto instanciado

```xBase
   // 0. creo la instancia de `miClase`
   miClase = CREATEOBJECT("miClase")
   
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
   // 6. setCaller => es el nombre del objeto que contiene el método `callback`
   oFoxPager.setCaller(miClase)
   // 7. setCallback => nombre del método que se encargará de analizar los registros.
   oFoxPager.setCallback("analizarClientes")
   // 8. quieres darle un nombre personalizado al cursor resultante? entonces dícelo a FoxPager
   oFoxPager.setResultName('BloqueClientes')
   // 9. lanzar el paginador
   oFoxPager.run()
   
   // Mi clase X
   DEFINE CLASS miClase AS CUSTOM
      // Este método de mi clase hará de callback
      FUNCTION analizarClientes
         SELECT listaClientes
         SCAN
            ?listaClientes.ClienteID
            ?listaClientes.Nombre
         ENDSCAN
      ENDFUNC
   ENDDEFINE
```
