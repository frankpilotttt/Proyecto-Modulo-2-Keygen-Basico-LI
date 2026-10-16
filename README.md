# keygen Basico en ensamblador

* **Nombre Del Alumno:** Ramos Vazquez Francisco
* *Materia:* Lenguajes De Interfaz

## Descripción del Proyecto

Es un keygen sencillo hecho en ensamblador x86-64. El programa te pide un nombre de usuario, suma los valores ASCII de todos sus caracteres, le aplica un XOR con 0ABCDh y muestra el resultado como un número hexadecimal de 16 dígitos. Ese número es la "clave" del usuario.

Si no escribes nada y solo das Enter, el programa te avisa que el nombre está vacío y no genera clave.

Hecho con **UASM64** y **GoLink**.

## Cómo compilarlo

Desde la terminal, en la carpeta donde está el `.asm`:

```
uasm64 -win64 keygen.asm
golink /console /entry main keygen.obj kernel32.dll
```

## Cómo funciona

1. **Pide el nombre.** Muestra un mensaje en pantalla y lee lo que escribe el usuario con la función de entrada de consola, guardándolo en un buffer.
2. **Revisa si está vacío.** Después de leer, checa cuántos caracteres se capturaron (sin contar el Enter). Si son cero, salta a la parte que muestra el mensaje de error y termina el programa.
3. **Suma los ASCII.** Recorre el nombre caracter por caracter y va sumando el valor ASCII de cada uno en un registro, hasta llegar al final de la cadena.
4. **Aplica el XOR.** Al resultado de la suma le hace un `XOR` con `0ABCDh`.
5. **Convierte a hexadecimal.** Toma el valor final y lo pasa a texto en 16 dígitos hexadecimales. Va sacando de 4 en 4 bits, y cada grupo lo convierte al caracter `0-9` o `A-F` que le toca. Los dígitos que sobran a la izquierda quedan en ceros.
6. **Muestra la clave.** Imprime el resultado en pantalla y el programa termina.
