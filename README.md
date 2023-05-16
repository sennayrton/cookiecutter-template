# Despliegue de Kubernetes con Ansible en entornos offline



### Descripción

Este proyecto tiene como objetivo el diseño y construcción de una instalación automatizada de un clúster de Kubernetes, con aprovisionamiento automático, en un entorno de alta seguridad, en el que la conectividad a Internet es limitada o nula.

El objetivo al finalizar el proyecto es ser capaz de ofrecer un entorno totalmente funcional de laboratorio en el que se puedan hacer pruebas que conlleven riesgos y donde se puedan probar todo tipo de instalaciones de aplicativos para seguir aprendiendo sobre dicha plataforma, por tanto, un entorno de laboratorio es su principal campo de aplicación.

En el laboratorio de CIN creamos máquinas correspondientes a nodo master/etcd, nodos worker, registry, balanceadores y bastión, todas basadas en RHEL 8.6. En ellos se hará una instalación de kubernetes con todos sus componentes, extensiones y otras utilidades que consideremos interesantes (herramientas, lenguajes de programación, etc), con el objetivo de identificar todos los pasos y paquetes necesarios para realizar una instalación completamente offline en la nueva infraestructura. Importante tener en cuenta que solo dispondremos de un usuario sin permisos de root, que solo tendrá propiedad de la ruta /usr/local/<entorno>/<usuario> , donde tendremos que instalar y almacenar todo.



### Playbooks de instalación

Para la instalación de los diferentes aplicativos de la transformación se han creado los siguientes roles de Ansible ( dentro de scripts/ansible-playbooks ) que instalan diferentes paquetes para cada tipo de instancia diferente:

- common ( Role que instala las dependencias comunes a todas las máquinas y que se debe ejecutar inicialmente en todas )
- registry ( Role que instala las dependencias y aplicaciones para el Registry de Docker )
- balanceador ( Role que instala las dependencias y aplicaciones para los balanceadores de Kubernetes )

Para ejecutar estos roles sobre una máquina con Ansible instalado debemos tener la VPN de CIN activa y ejecutar el siguiente comando para ejecutar un determinado role:

`ansible-playbook -i inventario --limit <máquina> sites.yaml`

Adicionalmente, se pensó en descargar los paquetes necesarios para cada role desde el Drive y meterlos en el directorio local donde se ejecutaría Ansible ( dentro del role en el directorio files).
Pero finalmente podremos apuntar al repo oficial de RHEL 8.6, por tanto, se descargarán los paquetes a instalar (latest) de dicho repo para su posterior instalación.

Esto ejecutará el role de common en la máquina especificada en el parámetro limit y después el role determinada por el inventario de Ansible ( **scripts/ansible-playbooks/inventario** ) . Adicionalmente se puede ejecutar una determinada tarea especificada según la tag que se defina en las tasks de ese role:

`ansible-playbook -i inventario --limit <máquina> --tags <tag> sites.yaml`

### Desde aquí revisar:
  
  
## **Paso 3: Instalación y configuración de Docker y Harbor, Creación y configuración del Registry**

Se ha creado un role de Ansible que instala Docker y sus dependencias , seguidamente lo configura para que la ruta donde crea los contenedores sea /usr/local/pr/kamino/var/lib/docker/overlay2.  Para las pruebas se puede utilizar la máquina del registry ( 192.168.112.186 ) 

Seguidamente, se instala Harbor cargando las imágenes de Docker forma offline y se configura mediante la creación de una CA custom la cual firma la clave privada y certificado y asigna al Nginx que levanta harbor. Se ha preconfigurado el instalador para que instale Trivy , chartmuseum y Harbor de forma offline sin que accedan a Internet salvo para descargar nuevas imágenes no presentes ( install.sh --with-trivy --with-chartmuseum ).

Se pueden ver los ficheros de instalación en el repositorio siguiente de Gitlab => /transformacion-kamino/instalacion-k8s/-/tree/master/scripts/ansible-playbooks/kubernetes-installation/roles/registry]


Si se quiere ejecutar el playbook se deben bajar los ficheros siguientes a la ruta roles/registry/files para que Ansible pueda realizar la instalación de este role correctamente.

Al menos son necesarios los siguientes ficheros en la ruta roles/registry/files:

- **daemon.json** ( Fichero de configuración de Docker para confiar en el Registry )
- **docker-ce-offline.tar.gz** ( Fichero comprimido con las dependencias de Docker)
- **docker-compose.yml** ( compose con el stack de Harbor )
- **harbor-offline-installer-v2.4.2.tgz** ( Fichero comprimido con todas las imágenes de Harbor )
- **harbor.yml** ( Fichero que lee el instalador de harbor ( install.sh ) para arrancar el entorno por primera vez )
- **install.sh** ( Script que lee el fichero harbor.yml y prepara el entorno de Harbor , y comprueba que Docker y docker-compose estén previamente instalados )
- **metadata.json** ( Fichero de configuración para trivy para que no se actualice )
- **trivy.db** ( Base de datos de CVEs de las imágenes de Docker )
- **v3.ext** ( x509 v3 extension file para la creación del certificado del Registry )



Para ejecutar este playbook bajamos el repositorio de Gitlab mencionado anteriormente en una máquina con Ansible instalado ( con Python 3.5 o superior ) , después bajamos los ficheros mencionados anteriormente en la ruta roles/registry/files y lo ejecutamos mediante los siguientes comandos:

Si le ponemos las tags docker-install y harbor-install solo realizará la instalación de Docker y Harbor :

**ansible-playbook -i inventario --limit harbor --ask-vault-pass --tags=”docker-install” sites.yaml**

**ansible-playbook -i inventario --limit harbor --ask-vault-pass --tags=”harbor-install” sites.yaml**

Si se desea realizar una instalación completa, primero de los paquetes comunes y después de Docker y Harbor se debe ejecutar de la siguiente manera:

**ansible-playbook -i inventario --limit harbor --ask-vault-pass sites.yaml**

De esta manera también es necesario bajar los ficheros comunes ( roles/common/files) del Drive al directorio local de nuestro PC con Ansible.



### **Configurar Clientes**

Para conectarse a este Registry es necesario importar el certificado **registry.cert** del Registry ( [registry.cert] a la ruta /**etc/docker/certs.d/registry** ( es necesario crearla )  y después reiniciar el servicio de Docker.

Añadimos de forma temporal el host al fichero de hosts:

**echo "192.168.112.186 registry registry" >> /etc/hosts**

Después nos logueamos contra el Registry ( usuario admin) :

**docker login registry:443**

Para bajarnos imágenes de Internet mediante el proxy:

**docker pull registry:443/proxy_docker_hub/bitnami/openldap:2.5.11**

O bien de Kubernetes (repositorio k8s.gcr.io) :

**docker pull registry:443/k8s.gcr.io/pause:3.5**
**docker pull registry:443/k8s.gcr.io/coredns/coredns:v1.8.4**

Se puede observar que el Registry ha accedido mediante el proxy al repositorio de Internet k8s.gcr.io y ha bajado las imágenes requeridas.






