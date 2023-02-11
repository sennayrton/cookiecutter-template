# Transformación K8S

## Script inicial

Si la máquina virtual es nueva, se debe crear el script en la máquina local ( **scripts/setup-host.sh** ) para configurar el hostname , la IP y los usuarios de la misma.


## Playbooks de instalación

Para la instalación de los diferentes aplicativos de la transformación se han creado los siguientes roles de Ansible ( dentro de ansible-playbooks ) que instalan diferentes paquetes para cada tipo de instancia diferente:

- common ( Role que instala las dependencias comunes a todas las máquinas y que se debe ejecutar inicialmente en todas )
- registry ( Role que instala las dependencias y aplicaciones para el Registry de Docker )
- k8s (  Role que instala las dependencias  y aplicaciones para los nodos workers y masters de Kubernetes )
- etcd (  Role que instala las dependencias  y aplicaciones para los nodos etcd )
- bastion ( Role que instala las dependencias  y aplicaciones para los nodos bastión de Kubernetes )
- balanceador ( Role que instala las dependencias  y aplicaciones para los balanceadores de Kubernetes )

Para ejecutar estos roles sobre una máquina con Ansible instalado debemos tener la VPN de CIN activa y ejecutar el siguiente comando para ejecutar un determinado role:

```shell
ansible-playbook -i inventario --ask-vault-pass --limit <máquina> sites.yaml
```

Adicionalmente, se deben descargar los paquetes necesarios para cada role desde el Drive ( https://drive.google.com/drive/folders/18rcX8oO3f4Uc-f3fSvWzorPHxG9KWr-2 ) y meterlos en el directorio local donde se ejecutará Ansible ( dentro del role en el directorio files).

Esto ejecutará el role de common en la máquina específicada en el parámetro limit y después el role determinada por el inventario de Ansible ( **ansible-playbooks/inventario** ) .
Adicionalmente se puede ejecutar una determinada tarea especificada según la tag que se defina en las tasks de ese role:

```shell
ansible-playbook -i inventario --ask-vault-pass --limit <máquina> --tags <tag> sites.yaml
```
