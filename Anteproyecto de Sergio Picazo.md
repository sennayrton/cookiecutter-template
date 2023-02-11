# Anteproyecto de Sergio Picazo

- COSAS A COMENTARTE:
Quería comentarte que ayer después de la llamada lo estuve pensando y claro, lo chulo sería mostrar en la presentación algo que no aburra a la gente como tú me comentaste, pero claro, por otro lado, la instalación de este clúster depende de la rapidez con la que lo apliquemos en el banco porque nosotros tenemos casi todo preparado, pero a lo mejor la instalación se alarga hasta el Q4 del año...
Entonces, ¿podríamos mantener la misma idea pero haciéndolo yo en el laboratorio de GMV en las máquinas a más pequeña escala? Y así no dependo del tiempo que lleve hacerlo en BBVA.

Se recomienda que el anteproyecto de TFG tenga la siguiente estructura y contenidos básicos desarrollados con una extensión aproximada de tres-cuatro páginas:

Autor: Sergio Picazo Serrano
Tutor: Óscar García Población
Titulación: Grado en ingeniería en sistemas de información
Título: a ser posible que aporte información. TDB
Visto bueno del cotutor (en su caso)


## Definición del ámbito del proyecto

- ¿Cómo quedaría el índice de tu TFG?

**Tabla de contenidos**

- **1 Introducción y objetivos**
    - 1.1 Introducción
    - 1.2 Motivación
    - 1.3 Objetivo
    - 1.4 Estructura del documento
- **2 Antecedentes**
    - 2.1 Contenedores
    - 2.2 Kubernetes
    - 2.3 Ansible
- **3 Desarrollo**
    - 3.1 Punto de partida
    - 3.3 Planificación de uso de recursos
    - 3.4 Arquitectura nodos master
    - 3.5 Arquitectura nodos worker
    - 3.6 Método de instalación
    - 3.6.1 Creación de máquinas independientes (setup-host.sh)
    - 3.6.2 Instalación de common necesarios
    - 3.7 Configuración de la plataforma o clúster
    - 3.7.1 Configuración del bastión
    - 3.7.2 Configuración del registry (salida a internet mediante proxy)
    - 3.7.3 Configuración del nodo master
    - 3.7.4 Configuración de nodos worker
    - 3.7.5 Configuración de loadbalancer
    - 3.7.6 Configuración de backup (etcd)
    - 3.8 Automatización de la instalación
- **4 Resultados**
    - Demostración
- **5 Conclusiones**
- **6 Vista a futuro u otras formas de instalar en k8s (Helm)**
- **7 Bibliografía**



- ¿Cómo harías una presentación para mostrar evidencias del trabajo hecho?

Por ejemplo, un vídeo demostrando métricas y gráficas, carga de CPU y recursos.
Creo que lo más llamativo de la idea es el tema de la automatización de la instalación del clúster con Ansible, ya que facilita mucho las cosas y puedes replicar en distintas máquinas que tengas en el inventario.
También el tema de que la instalación sea offline y accedamos a hacer los pull con docker a través de un proxy.
Quizá también mostrando un frontal de algún aplicativo montado (Rundeck para lanzar jobs) o una BD con algo interesante.

## Introducción
(Fijar el contexto en el que se desenvolverá el TFG y sus antecedentes si existen.)
En este Trabajo de Fin de Grado se va a montar un clúster de Kubernetes mediante automatización con Ansible en un entorno offline montado on premise.

A diferencia de las máquinas virtuales, los contenedores permiten desplegar, arrancar y parar aplicaciones más rápido, aprovechando mejor los recursos de hardware.

La motivación de este proyecto viene por el papel que están teniendo últimamente las tecnologías Cloud Native, en especial Kubernetes debido a que ayuda a las empresas a crear, escalar y administrar aplicaciones en la nube y mantener sus ciclos de vida dinámicos.
Según un artículo de _Dominio de las Ciencias_ [1], se demuestra como actualmente, la manera más eficiente para el desarrollo y puesta en producción de aplicaciones es la implementación de microservicios contenerizados, orquestados en Kubernetes, y ya no los procesos tradicionales a través de monolitos.
Kubernetes permite el desarrollo y puesta en producción de aplicaciones de manera más rápida y con propiedades de escalamientos y alta disponibilidad.
La conclusión es evidente, desde su nacimiento está ganando una adopción masiva en todas las industrias, ayudando a las empresas a ofrecer soluciones de software con menos énfasis en la infraestructura.

Uno de los casos más destacados es el de `Mercedes-Benz` [2], hace años, los ingenieros de software se enfrentaban a tiempos difíciles en Mercedes-Benz: operaciones con hojas de cálculo, procesos manuales, infraestructuras crecidas y una gobernanza estricta. Una iniciativa popular de los ingenieros propuso el reto de cambiar las reglas del juego, y su bala de plata fue Kubernetes. Comenzaron con Kubernetes 0.9 en servidores gestionados hasta el día de hoy, donde manejan una plataforma on-premise self-service con cerca de 1000 clústeres en Cluster API. Apostaron por transformar un centro de datos con un equipo joven que, en su mayoría, desconocía los procesos empresariales, pero a través de una mezcla de visiones ingenuas y una fuerte creencia en el código abierto con mucha resistencia hizo que el proyecto fuera un éxito.

La clave de este trabajo reside en la necesidad de conseguir, de la manera más eficiente posible, aprovechando al máximo unos recursos limitados, desplegar un entorno en el que el mantenimiento de este y la gestión de aplicaciones sea lo más sencilla posible.
Esto se debe a que antiguamente la solución era mantener tus servicios y aplicaciones en un solo ordenador físico, llevando a obtener muchos problemas a las empresas.
Los contenedores nacieron para simplificar este proceso y ofreciendo virtualización ligera, generan el entorno mínimo necesario para aprovechar en mayor parte los recursos de la máquina física donde se ejecuta.

## Objetivos del trabajo de fin de grado y campo de aplicación
(Delimitar y explicar con claridad los objetivos generales a conseguir con el TFG y la
aplicación del mismo.)

Este proyecto tiene como objetivo el aprendizaje de cómo instalar de forma automatizada un clúster de Kubernetes en un escenario con los requisitos mínimos para poder instalar este tipo de plataforma sin perder ninguna funcionalidad y sin comprometer su funcionamiento correcto.

El objetivo al finalizar el proyecto es ser capaz de ofrecer un entorno totalmente funcional de laboratorio en el que se puedan hacer pruebas que conlleven riesgos y donde se puedan probar todo tipo de instalaciones de aplicativos para seguir aprendiendo sobre dicha plataforma, por tanto, un entorno de laboratorio es su principal campo de aplicación.


### Entregables

Como resultado de este proyecto tendremos:
- Repositorio en GitHub con el código fuente
- Demostración del clúster, recursos y funcionalidades
- Documento con el análisis y diseño propuestos, así como con los pasos seguidos para la elaboración

## Descripción de las tareas
(Explicar en detalle qué se va a hacer, cómo y por qué. Sería interesante incluir un esquema/diagrama de bloques, si se puede.)

Con el fin de llegar al objetivo final de este proyecto, la instalación automatizada del clúster, se llevarán a cabo diversas tareas.
Por tanto, debemos familiarizarnos con estas nuevas tecnologías y habrá que seguir los siguientes objetivos paso a paso.
Estudio sobre sistemas de uso de contenedores como Docker y aprender sobre el uso de herramientas de virtualización, automatización y IAC(infraestructura como código).
Dar a conocer las ventajas de los contenedores sobre otras tecnologías y sistemas de orquestación de contenedores, en este caso Kubernetes[3].
Identificar ventajas del empleo de estas plataformas orquestadoras.
Tras haber logrado entender el funcionamiento de estas tecnologías habrá que descubrir las posibles formas de instalar estas plataformas. Por ello habrá que:
- Aprender a desplegar un entorno de orquestación de contenedores llevando a cabo la configuración necesaria
Al mismo tiempo que se elaboran estas tareas, se efectuará la tarea de las pruebas, muy importante en el ciclo de desarrollo de software. Finalmente, se redactará la memoria con los resultados obtenidos.
Con la tecnología entendida e instalada, es decir, ya con la infraestructura en funcionamiento, se comprobará si el funcionamiento es el esperado. Por tanto:
- Estudiar que el funcionamiento es el correcto tras todo el despliegue.
- Realizar la conclusión de lo analizado.
Tras el análisis se llevará a cabo una conclusión de los resultados y de lo aprendido en el desarrollo del proyecto.
Simultáneamente, se irán efectuando las respectivas pruebas del código implementado. Al crear el video, se pueden ir modificando elementos tanto a nivel estético como a nivel funcional.

Por último, se redactará la memoria plasmando los resultados obtenidos en ella. En esta se detallará el diseño de las soluciones adoptadas.


## Metodología y plan de trabajo
Descripción (puede ser incluso una enumeración) clara de las etapas que se van a seguir, y si es posible se deberá incluir un diagrama de Gantt.

Para procedes a la realización del trabajo de fin de grado se ha optado por dividirlo en diferentes fases para poder llevar un control y seguimiento de las tareas de manera específica. El total de horas de trabajo será 350 aproximadamente.

El trabajo se ha dividido en semanas y no en días para una mayor libertad en la consecución de los objetivos. Cada semana comprenderá 17.5 horas de trabajo.

De cara a la consecución de los objetivos del proyecto que se han descrito anteriormente, estas serán las fases a seguir:
1. **Formación inicial (5 semanas):**
    * **Formación en el uso de Ansible, Docker y Kubernetes (3 semanas):** Durante esta fase, se obtendrán los conocimientos que permitan un manejo óptimo de la herramienta. Para ello se tomarán como ayuda la documentación proporcionada por la propia herramienta y las guías de inicio.
    * **Consulta bibliográfica y de la API (2 semanas):** Recopilación de la información necesaria tanto de la comunidad como de la API.
2. **Análisis y diseño del entorno (4 semanas):**
    * **Análisis de los requisitos (2 semanas):** Se llevará a cabo un análisis de los requerimientos de cada una de las máquinas que formarán el clúster.
    * **Diseño de las arquitecturas (2 semanas):** Se hará un planteamiento de las arquitecturas que sean necesarias para la posterior implementación de estas.
3. **Implementación y desarrollo de las configuraciones (10 semanas):**
    * **Desarrollo del código fuente (4 semanas):** Durante esta etapa, se identificarán las variables de uso, se elegirán las versiones adecuadas y se escogerán los roles necesarios. Tras esto, se procederá a materializar todo el conocimiento en el código.
    * **Depuración del código (2 semanas):** Se facilitará la interpretación visual del código eliminando elementos repetitivos.
    * **Pruebas (3 semanas):** En esta fase se busca detectar los fallos que se han podido cometer en etapas anteriores y corregirlos.
    * **Correcciones estéticas (0,5 semanas):** Retoques y modificaciones a nivel decorativo y artístico.
    * **Documentación del código (0,5 semanas):** Comentar y documentar de forma adecuada el código de los diferentes programas.
4. **Documentación y finalización del proyecto (1 semanas):** En esta última fase, se realizará la documentación correspondiente poniendo especial atención en los últimos detalles.

## Medios
(Descripción de los medios necesarios para realizar el TFG.)

Se utilizarán máquinas RHEL (Red Hat Enterprise Linux) de laboratorio:
Inventario Laboratorio
*IP - Hostname    - Rol*
 IP - master1.cin - Kubernetes Master
 IP - worker1.cin - Kubernetes Worker1
 IP - worker1.cin - Kubernetes Worker2
 IP - loadbalancer.cin	- Kubernetes Registry
 IP - loadbalancer1.cin - Kubernetes Load Balancer1
 IP - loadbalancer2.cin - Kubernetes Load Balancer2
 IP - VIPa - Kubernetes Ingress VIP (solo IP virtual, no es una máquina)
 IP - etcd1.cin	- Kubernetes ETCD
 IP - etcd2.cin	- Kubernetes ETCD
 IP - etcd3.cin	- Kubernetes ETCD



## Referencias bibliográficas
(Lista de recursos bibliográficos utilizados para la confección del anteproyecto y otros que ya se conoce/dispone para su utilización en la realización del TFG. El estilo de citación de referencias será preferentemente del IEEE.)


1. Valladares, C. S. T., & Sacoto, A. S. Q. (2022). Procesos de protección en entornos de ejecución de contenedores Kubernetes para una entidad financiera: una revisión sistemática. Dominio de las Ciencias, 8(4), 619-644.
2. 7 Years of Running Kubernetes for Mercedes-Benz, https://www.youtube.com/watch?v=UmbjwSK9b3I&list=PLj6h78yzYM2PfD9vkHopnzNNIVicOFtih&index=18
3. Kubernetes, https://kubernetes.io/