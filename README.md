# GitInstall

**Script de instalación y corte de repositorios**  

---

## Parámetros del script

| Parámetro              | Descripción                                                                                                                                                                                                               |
|------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **-S**, **--setup**    | Crea los directorios que necesita el script para funcionar (en `/opt/gitinstall`). **Es necesario ejecutarlo primero** como `root`.                                                                          |
| **-l**, **--link**     | Enlace al repositorio de GitHub (o de otra plataforma Git) que se clonará (lo que usarías en `git clone`).                                                                                                       |
| **-f**, **--file**     | Directorio o archivo específico que quieres extraer del repositorio. Si no indicas nada, el script instalará todo el contenido.                                                                                           |
| **-s**, **--save**     | Directorio donde se guardará el contenido clonado. Por defecto, se guarda en `/opt/gitinstall/repositories`.                                                                                                              |
| **-m**, **--more**     | Permite especificar varios directorios/archivos de corte. Al usar este parámetro, **no** debes usar `-f` ni añadir argumentos tras él. El script te preguntará qué directorios necesitas.                                 |
| **-q**, **--quiet**    | Ejecuta el script en modo silencioso. Solo mostrará errores.                                                                                                        |
| **-h**, **--help**     | Muestra la ayuda del script, explicando cada parámetro y su uso.                                                                                                                                                          |

---

## ¿Cómo funciona?

1. **Clonación:** El script clona el repositorio completo que indiques y lo almacena temporalmente en `/opt/gitinstall/tmp`.
2. **Movimiento de contenido:**  
   - Si no especificas ningún directorio o archivo de corte (`-f` o `-m`), se moverá **todo** el contenido del repositorio a la ruta de guardado que indiques (o a la ruta por defecto).  
   - Si especificas un directorio o archivo de corte, solo se moverá esa parte, y se eliminará el resto de la carpeta temporal.
3. **Limpieza:** Finalmente, el script limpia la carpeta temporal (`/opt/gitinstall/tmp`) para evitar acumulación de datos innecesarios.

> **Importante**: Para que funcione correctamente, primero debes ejecutar el script con la opción `-S` (setup) como `root`, de modo que se creen los directorios y permisos necesarios en `/opt/gitinstall`.

---

## Importante 

1. Para que funcione correctamente, primero debes de usar la opción `-S`
2. Por ahora el script no interpreta espacios. Posiblemente lo arregle en un futuro.

## Autor 

Script desarrollado por jofunpe, más info en https://jofunpe.com
