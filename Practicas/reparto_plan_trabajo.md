# Reparto del plan de trabajo

## Alcance aprobado

El trabajo estudia la planificación de horarios universitarios en la formulación Curriculum-Based Course Timetabling (CB-CTT). Combina una revisión crítica de la literatura con un estudio de reproducibilidad del algoritmo BHC-KSA/LectureKick de Ceschia et al. El benchmark experimental es ITC-2007 UD2; ITC-2019 se utiliza únicamente como contexto para discutir el alcance de las conclusiones.

El estudio práctico compila y ejecuta el código abierto publicado sobre las 19 instancias no redundantes de UD2. Registra función objetivo, tiempo, configuración, semillas, logs y soluciones, y compara los resultados con los valores publicados. El alcance no incluye implementar un parser, un validador, un método greedy ni un modelo CP-SAT propios. Los métodos exactos, de restricciones y CP-SAT forman parte de la revisión bibliográfica.

## Organización del equipo

| Persona | Responsabilidades principales | Entregables de referencia |
|---|---|---|
| **Persona 1 - Introducción y revisión** | Presentar el problema CB-CTT, objetivos y alcance; describir la búsqueda bibliográfica; revisar ITC-2007 e ITC-2019; sintetizar métodos exactos y basados en restricciones. | Introducción, protocolo de búsqueda, contexto de los benchmarks, matriz bibliográfica correspondiente y sección de métodos exactos/de restricciones. |
| **Persona 2 - Estado del arte y reproducción** | Revisar metaheurísticas, híbridos y aprendizaje automático; explicar LectureKick; compilar y reproducir el solver publicado sin alterar el algoritmo; automatizar la campaña y conservar la evidencia de ejecución. | Matriz bibliográfica, sección de estado del arte, informe de reproducción, scripts, entorno, `results.csv`, logs y soluciones. |
| **Persona 3 - Resultados y análisis crítico** | Transformar los resultados crudos en tablas y gráficas; compararlos con el artículo publicado; analizar diferencias de tiempo y calidad, limitaciones y amenazas a la validez; elaborar conclusiones. Liderar la integración del artículo y del póster. | Tablas y figuras, análisis crítico, conclusiones, bibliografía consolidada, fuente LaTeX integrada, póster y comprobación final de la entrega. |
| **Equipo completo** | Acordar el protocolo antes de interpretar los resultados; revisar de forma cruzada las secciones; comprobar coherencia entre revisión, resultados y conclusiones; validar la versión final. | Artículo final, póster, repositorio reproducible y entrega revisada. |

## Secuencia de trabajo

| Fase | Objetivo | Resultado |
|---|---|---|
| Revisión y protocolo | Delimitar CB-CTT, las fuentes, los benchmarks y el experimento reproducido. | Estructura del artículo, bibliografía seleccionada y configuración experimental fijada. |
| Reproducción | Compilar BHC-KSA/LectureKick y ejecutar la campaña sobre UD2. | Resultados por instancia y semilla, logs, soluciones y entorno documentado. |
| Análisis | Resumir los resultados y contrastarlos de forma prudente con el estudio publicado. | Tablas, gráficas, discusión de calidad, tiempos y límites de comparabilidad. |
| Integración y entrega | Unificar las tres secciones, preparar el póster y revisar la trazabilidad. | Artículo y póster listos para entregar. |

## Reglas de coordinación

- ITC-2007 UD2 es el benchmark experimental principal; ITC-2019 no se ejecuta en esta entrega.
- Las 19 instancias no redundantes son `comp01`--`comp10`, `comp12`--`comp14` y `comp16`--`comp21`. Se excluyen `comp11`, por su coste objetivo cero, y `comp15`, equivalente a `comp03` bajo UD2.
- Toda comparación debe indicar versión del código, compilador, sistema operativo, semillas, límite de ejecución y definición de las métricas.
- Los tiempos de la reproducción se interpretarán con cautela cuando difieran el hardware o el entorno del artículo original.
- Cada integrante revisará al menos una sección elaborada por otra persona antes de la entrega final.

## Contribución de la Persona 2

La contribución individual de la Persona 2 está completada y lista para que la Persona 3 la analice e integre:

- revisión bibliográfica de metaheurísticas, métodos híbridos, aprendizaje automático y el algoritmo LectureKick;
- explicación del operador LectureKick, de los sesgos de búsqueda y de la configuración BHC-KSA;
- reproducción del estudio de Ceschia et al. en las 19 instancias no redundantes, con las semillas 0, 1 y 2: 57 ejecuciones en total;
- automatización en Windows mediante PowerShell y alternativa para Linux/Docker;
- fijación de commits, compilador, opciones de compilación, límite virtual, resultados, logs y soluciones;
- documentación de límites: tres semillas no sustituyen las 30 repeticiones del artículo y los tiempos no son directamente comparables entre entornos distintos.

Los artefactos de esta contribución se encuentran en `Practicas/persona_2/`, especialmente en `persona2_section.tex`, `matriz_bibliografica.md` y `reproduction/`.
