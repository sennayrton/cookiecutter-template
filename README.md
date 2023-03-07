# Despliegue de Kubernetes con Ansible en entornos offline

### **Descripción**

Este proyecto tiene como objetivo el diseño y construcción de una instalación automatizada de un clúster de Kubernetes, con aprovisionamiento automático, en un entorno de alta seguridad, en el que la conectividad a Internet es limitada o nula.

El objetivo al finalizar el proyecto es ser capaz de ofrecer un entorno totalmente funcional de laboratorio en el que se puedan hacer pruebas que conlleven riesgos y donde se puedan probar todo tipo de instalaciones de aplicativos para seguir aprendiendo sobre dicha plataforma, por tanto, un entorno de laboratorio es su principal campo de aplicación.

En el laboratorio de CIN creamos máquinas correspondientes a nodo master, nodo worker, nodo etcd, registry, balanceador y bastión, todas basadas en RHEL 7.9. En ellos se hará una instalación de kubernetes con todos sus componentes, extensiones y otras utilidades que consideremos interesantes (herramientas, lenguajes de programación, etc), con el objetivo de identificar todos los pasos y paquetes necesarios para realizar una instalación completamente offline en la nueva infraestructura. Importante tener en cuenta que solo dispondremos de un usuario sin permisos de root, que solo tendrá propiedad de la ruta /usr/local/<entorno>/<usuario> , donde tendremos que instalar y almacenar todo.

### **Paso 1: Configuración inicial**

**Descripción:** se configura la IP, hostname, usuario, grupo y directorio de trabajo para todas las máquinas.

● Configuración del archivo .bashrc de nuestro usuario, estableciendo el prompt y otros detalles mínimos.

● Creación del archivo .profile en el home de nuestro usuario, indicando que se cargue la configuración del .bashrc con cada login.

● Cambio del layout del teclado a español (originalmente está en teclado inglés americano).

● Añadir el grupo al archivo /etc/sudoers para que los usuarios que pertenezcan a él puedan ejecutar comandos como root con sudo. Si vamos a tener binarios que necesiten ejecutarse con sudo y que se encuentren en rutas que no estén en el PATH de sudo (comprobar con printenv), es necesario comentar la línea de secure_path en el /etc/sudoers.

● Configuración de IP y hostname de las máquinas (explicado en Laboratorio GMV - Documentos de Google) + reinicio del servicio network. Importante mantener el UUID de la interfaz de red.

**Paquetes:** ninguno**.

**Scripts:** [setup-host.sh]

**Probado en:** master.

**Falta por probar en:** worker, etcd, registry, balanceador, bastión.

## **Paso 2: Instalación de containerd y nerdctl**

**Descripción:** se instala containerd y nerdctl con todo lo que necesitan, y se realiza una prueba de levantar contenedor de nginx.
1 - Extraer contenido del .tar.gz de nerdct-fulll (binarios, librerías, etc) en /usr/local/pr/kamino.
tar Cxzvvf /usr/local/pr/kamino nerdctl-full-0.18.0-linux-amd64.tar.gz
2 - Generamos el config.toml con los siguientes comandos:
sudo mkdir -p /etc/containerd/config.toml
containerd config default > /etc/containerd/config.toml
3 - Arrancamos el servicio de containerd :
sudo systemctl enable --now containerd
Esto genera el fichero /usr/usr/local/lib/systemd/system/containerd.service
4 - Seguidamente especificamos este archivo de configuración de containerd en el daemon de containerd:
sudo vi /usr/local/lib/systemd/system/containerd.service
ExecStart=/usr/local/bin/containerd -c /etc/containerd/config.toml
5 - Configurar servicio containerd para que el directorio de almacenamiento persistente (pods, addons y plugins, etc). Se modifica con el parámetro root y state al iniciar el servicio con systemd (alternativamente se puede crear un archivo de configuración, ver https://github.com/containerd/containerd/blob/main/docs/ops.md#:~:text=%2D%2Droot%20 value%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20containerd %20root%20directory , archivo /etc/containerd/config.toml https://containerd.io/docs/getting-started/ ).
root = "/usr/local/pr/kamino/var/lib/containerd" state = "/usr/local/pr/kamino/run/containerd"
6 - Recargamos systemd:
systemctl daemon-reload
7 - Reiniciamos el servicio de containerd:
systemctl restart containerd
8- Test: levantar contenedor de alpine
nerdctl run --rm -it alpine:latest

**Paquetes:** nerdctl-full-0.14.0-linux-amd64.tar.gz , nginx-alpine.tar

**Scripts:** install-containerd-nerdctl.sh

**Probado en:** master.

**Falta por probar en:** worker, registry, bastión.

**Reorganización repositorio de Gitlab de Transformación**

Se ha creado un repositorio en Gitlab con los roles de Ansible para instalar en cada máquina que corresponda los programas y dependencias automáticamente .

## **Script inicial**

Si la máquina virtual es nueva, se debe crear el script en la máquina local ( **scripts/setup-host.sh** ) para configurar el hostname , la IP y los usuarios de la misma.

## **Playbooks de instalación**

Para la instalación de los diferentes aplicativos de la transformación se han creado los siguientes roles de Ansible ( dentro de scripts/ansible-playbooks ) que instalan diferentes paquetes para cada tipo de instancia diferente:

- common ( Role que instala las dependencias comunes a todas las máquinas y que se debe ejecutar inicialmente en todas )
- registry ( Role que instala las dependencias y aplicaciones para el Registry de Docker )
- k8s ( Role que instala las dependencias y aplicaciones para los nodos workers y masters de Kubernetes )
- etcd ( Role que instala las dependencias y aplicaciones para los nodos etcd )
- bastion ( Role que instala las dependencias y aplicaciones para los nodos bastión de Kubernetes )
- balanceador ( Role que instala las dependencias y aplicaciones para los balanceadores de Kubernetes )

Para ejecutar estos roles sobre una máquina con Ansible instalado debemos tener la VPN de CIN activa y ejecutar el siguiente comando para ejecutar un determinado role:

`ansible-playbook -i inventario --limit <máquina> sites.yaml`

Adicionalmente, se pensó en descargar los paquetes necesarios para cada role desde el Drive y meterlos en el directorio local donde se ejecutaría Ansible ( dentro del role en el directorio files).
Pero finalmente podremos apuntar al repo oficial de RHEL 8.6, por tanto, se descargarán los paquetes a instalar (latest) de dicho repo para su posterior instalación.

Esto ejecutará el role de common en la máquina específicada en el parámetro limit y después el role determinada por el inventario de Ansible ( **scripts/ansible-playbooks/inventario** ) . Adicionalmente se puede ejecutar una determinada tarea especificada según la tag que se defina en las tasks de ese role:

`ansible-playbook -i inventario --limit <máquina> --tags <tag> sites.yaml`

## **Paso 3: Instalación y configuración de Docker y Harbor, Creación y configuración del Registry**

Se ha creado un role de Ansible que instala Docker y sus dependencias , seguidamente lo configura para que la ruta donde crea los contenedores sea /usr/local/pr/kamino/var/lib/docker/overlay2.  Para las pruebas se ha utilizado la máquina del loadbalancer ( 192.168.112.139 ) aunque finalmente se llamará registry.cin o similar.

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

Los ficheros se pueden encontrar en la siguiente carpeta del Drive.

Para ejecutar este playbook bajamos el repositorio de Gitlab mencionado anteriormente en una máquina con Ansible instalado ( con Python 3.5 o superior ) , después bajamos los ficheros mencionados anteriormente en la ruta roles/registry/files y lo ejecutamos mediante los siguientes comandos:

Si le ponemos las tags docker-install y harbor-install solo realizará la instalación de Docker y Harbor :

**ansible-playbook -i inventario --limit harbor --ask-vault-pass --tags=”docker-install” sites.yaml**

**ansible-playbook -i inventario --limit harbor --ask-vault-pass --tags=”harbor-install” sites.yaml**

Si se desea realizar una instalación completa, primero de los paquetes comunes y después de Docker y Harbor se debe ejecutar de la siguiente manera:

**ansible-playbook -i inventario --limit harbor --ask-vault-pass sites.yaml**

De esta manera también es necesario bajar los ficheros comunes ( roles/common/files) del Drive al directorio local de nuestro PC con Ansible.

URL Registry Actual Funcionando =>

[https://192.168.112.139/account/sign-in?redirect_url=%2Fharbor%2Fprojects](https://192.168.112.139/account/sign-in?redirect_url=%2Fharbor%2Fprojects)

(Credenciales las mismas que el Registry actual de Producción )

### **Configurar Clientes**

Para conectarse a este Registry es necesario importar el certificado **loadbalancer.cin.cert** del Registry ( [loadbalancer.cin.cert](https://drive.google.com/file/d/1qlqy7vXCh2HvbGDUhyHSQRyZeF7JKvMe/view?usp=sharing)  )  a la ruta /**etc/docker/certs.d/loadbalancer.cin** ( es necesario crearla )  y después reiniciar el servicio de Docker.

Añadimos de forma temporal el host al fichero de hosts:

**echo "192.168.112.139 loadbalancer loadbalancer.cin" >> /etc/hosts**

Después nos logueamos contra el Registry ( usuario admin) :

**docker login loadbalancer.cin:443**

Para bajarnos imágenes de Internet mediante el proxy:

**docker pull loadbalancer.cin:443/proxy_docker_hub/bitnami/openldap:2.5.11**

O bien de Kubernetes (repositorio k8s.gcr.io) :

**docker pull loadbalancer.cin:443/k8s.gcr.io/pause:3.5**
**docker pull loadbalancer.cin:443/k8s.gcr.io/coredns/coredns:v1.8.4**

Se puede observar que el Registry ha accedido mediante el proxy al repositorio de Internet k8s.gcr.io y ha bajado las imágenes requeridas.


### **Creación y configuración del Bastion
Paquetes a instalar: kube-ps1 Scripts relacionados:
Prompt para kubernetes
Descomprimir kube-ps1.tar.gz en /opt/kube-ps1
Añadir a /usr/local/pr/kuka/home/.bashrc lo siguiente:
#Kube-ps1
source /opt/kube-ps1/kube-ps1.sh
PS1='[\u@\h \W $(kube_ps1)]\$ '



