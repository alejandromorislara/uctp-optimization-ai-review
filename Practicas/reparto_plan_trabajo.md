# Reparto del plan de trabajo

## Organización del equipo

| Perfil | Responsabilidades principales | Entregables de referencia |
|---|---|---|
| **Perfil A** | Diseñar el protocolo bibliográfico; realizar la búsqueda y el cribado de trabajos; elaborar la taxonomía y la síntesis crítica del estado del arte. | Matriz bibliográfica, síntesis del estado del arte y sección de revisión del artículo. |
| **Perfil B** | Implementar el parser común, el validador y la función de coste; preparar el baseline greedy y el modelo CP-SAT; documentar el formato de entradas y salidas. | Código de infraestructura, pruebas de validación, resultados de greedy y CP-SAT. |
| **Perfil C — Persona 2** | Revisar la literatura sobre metaheurísticas, híbridos y LectureKick; reproducir el solver publicado (BHC-KSA/LectureKick) sin modificar su algoritmo; automatizar las ejecuciones y gestionar semillas, límites temporales, logs y soluciones. | Matriz bibliográfica, informe de estado del arte y reproducción, scripts reproducibles, entorno, logs, soluciones y `results.csv`. |
| **Equipo completo** | Diseñar y congelar el protocolo experimental; revisar los resultados; realizar el análisis estadístico; interpretar las amenazas a la validez; redactar y revisar el artículo; preparar el póster y la entrega final. | Protocolo final, análisis comparativo, artículo IEEE, póster y repositorio reproducible. |

## Plan de cuatro semanas

| Semana | Objetivo | Hitos y entregables |
|---|---|---|
| **1. Preparación** | Cerrar el alcance, las fuentes y el protocolo. | Protocolo bibliográfico y experimental congelado; conjunto de instancias, métricas y formato de resultados definidos. |
| **2. Implementación** | Construir y probar los componentes computacionales. | Parser, validador, scorer, greedy, CP-SAT y SA integrados; pruebas básicas superadas. |
| **3. Ejecución y análisis** | Ejecutar los experimentos bajo condiciones comunes. | Resultados por instancia y semilla; logs, tiempos, fallos y *timeouts* conservados; análisis estadístico preliminar. |
| **4. Redacción y entrega** | Consolidar la evidencia y preparar los materiales finales. | Interpretación conjunta, artículo, póster, revisión cruzada y repositorio reproducible. |

## Reglas de coordinación

- Compartir hardware, límites temporales, número de núcleos y formato de salida entre los métodos.
- Registrar versiones, comandos, semillas, configuraciones y resultados crudos.
- Revisar conjuntamente cualquier cambio en el protocolo antes de ejecutar la evaluación final.
- Mantener ITC-2007 UD2 como alcance principal de esta entrega; ITC-2019 se utilizará únicamente como contexto.
- Cada integrante revisará al menos una parte desarrollada por otra persona antes de cerrar la entrega.

## Correspondencia con el trabajo de la Persona 2

La contribución ya realizada por la Persona 2 queda recogida principalmente en el Perfil C:

- revisión bibliográfica de métodos metaheurísticos, híbridos y aprendizaje aplicado al timetabling;
- reproducción de Ceschia et al. sobre las 19 instancias no redundantes, con tres semillas por instancia;
- automatización del protocolo en Windows mediante PowerShell, con alternativa para Linux/Docker;
- conservación de versiones, configuración de compilación, resultados, logs y soluciones;
- documentación de las limitaciones de la reproducción, especialmente la diferencia frente a las 30 repeticiones del artículo y la no comparabilidad directa de tiempos.

La implementación del parser común, el baseline greedy y CP-SAT corresponde al Perfil B; el análisis estadístico conjunto y la redacción final corresponden a todo el equipo.
