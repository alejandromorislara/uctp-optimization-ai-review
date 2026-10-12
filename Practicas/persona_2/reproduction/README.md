# Reproducción de LectureKick

Este directorio contiene el protocolo ejecutable y los resultados de la parte asignada a la Persona 2. El objetivo es comprobar el artefacto de Ceschia et al. sobre las 19 instancias no redundantes del conjunto `comp`.

## Artefactos fijados

- Solver: `iolab-uniud/cb-ctt`, commit `9cb3eb63040241fd1954ba49abcaba64461702f6`.
- EasyLocal++ 3: commit `b40b14c2db2bdc81574a0613c52674644f8a0101`.
- Compilación: C++17, `-O3` y `-DENHANCED`.
- Método: `BHC-KSA`.
- Semillas: 0, 1 y 2.
- Límite virtual: 192 segundos.

## Ejecución reproducida en Windows

La campaña entregada se ejecutó con MSYS2 UCRT64, GNU G++ 16.2 y Boost 1.92. El directorio de trabajo debe usar una ruta sin tildes porque MinGW no enlaza correctamente cuando la ruta de su instalación contiene caracteres acentuados. Desde la raíz del proyecto:

```powershell
$env:PATH = 'D:\ruta\msys64\ucrt64\bin' + [IO.Path]::PathSeparator + $env:PATH
& 'Practicas/persona_2/reproduction/run_experiments.ps1' `
  -WorkRoot 'D:\ruta_ascii\persona2-cbctt' `
  -Gxx 'D:\ruta\msys64\ucrt64\bin\g++.exe' `
  -BoostLibrary 'boost_program_options-mt' `
  -VirtualTimeout 192
```

El script clona los dos repositorios cuando no están presentes, compila con las opciones del estudio y trabaja en serie. Si `results.csv` ya contiene una combinación de instancia y semilla, la omite. La opción `-ResetResults` inicia una campaña nueva. Debe usarse después de guardar una copia de los resultados anteriores.

`run_experiments.sh` conserva la ruta prevista para Ubuntu 24.04 o un contenedor con GNU G++ 13.3. El `Dockerfile` permite preparar esa alternativa, pero no se usó para generar el CSV entregado.

## Prueba mínima

Antes de la campaña se ejecutó dos veces `comp01` con semilla 0 y un límite virtual de un segundo. Ambas pruebas obtuvieron coste 5, cero violaciones y el mismo horario. Los tiempos de la fase principal fueron 1.73233 y 1.73285 segundos. La diferencia temporal no afecta a la comprobación de determinismo de la solución.

## Salida

La campaña incluida terminó el 5 de octubre de 2026. `results.csv` registra las 57 parejas de instancia y semilla. Todas terminaron con código de salida cero y sin violaciones duras.

`results.csv` contiene una fila por ejecución. `reported_time_s` es el tiempo comunicado por la fase principal del solver. `wall_time_s` incluye construcción inicial, escritura y sobrecarga del proceso. Los logs conservan la línea de resumen original y las soluciones incluyen horario, coste y tiempo.

Una ejecución aceptada debe cumplir tres condiciones:

1. Código de salida igual a cero.
2. Coste objetivo numérico.
3. Cero violaciones duras.

Tres semillas no permiten reproducir la distribución de 30 repeticiones del artículo. Los datos sirven para verificar el funcionamiento y preparar el análisis crítico de la Persona 3. Los tiempos no son directamente comparables con los publicados porque cambian el sistema operativo, el compilador y el procesador.
