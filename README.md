
### Descripción

Este proyecto tiene como objetivo el diseño y construcción de una instalación automatizada de un clúster de Kubernetes, con aprovisionamiento automático, en un entorno de alta seguridad, en el que la conectividad a Internet es limitada o nula.

El objetivo al finalizar el proyecto es ser capaz de ofrecer un entorno totalmente funcional de laboratorio en el que se puedan hacer pruebas que conlleven riesgos y donde se puedan probar todo tipo de instalaciones de aplicativos para seguir aprendiendo sobre dicha plataforma, por tanto, un entorno de laboratorio es su principal campo de aplicación.

En el laboratorio creamos máquinas correspondientes a nodo master/etcd, nodos worker, registry todas basadas en RHEL 8.6. En ellos se hará una instalación de kubernetes con todos sus componentes, extensiones y otras utilidades que consideremos interesantes (herramientas, lenguajes de programación, etc), con el objetivo de identificar todos los pasos y paquetes necesarios para realizar una instalación completamente offline.

### Entregables
Como resultado de este proyecto tendremos:
Repositorio en GitHub con el código fuente => https://github.com/sennayrton/k8s-ansible-offline
Plantilla de Cookiecutter para la personalización del despliegue => https://github.com/sennayrton/cookiecutter-template
Demostración del clúster, recursos y funcionalidades => Frontend con servicios levantado, monitorización con Prometheus y Grafana, pruebas de carga del frontend con Locust y gestión del clúster con Rancher.
Documento con el análisis y diseño propuestos, así como con los pasos seguidos para la elaboración.

Esquema del código del proyecto en Git:
```bash

├── k8s-ansible-offline
│   ├── README.md
│   ├── ansible-playbooks
│   │   ├── README.md
│   │   ├── ansible.cfg
│   │   ├── group_vars
│   │   │   └── all
│   │   │       ├── rke2_agents.yml
│   │   │       ├── rke2_servers.yml
│   │   │       ├── vars.yaml
│   │   │       └── vault.yaml
│   │   ├── hosts.ini
│   │   ├── inventario
│   │   ├── locustfile.py
│   │   ├── requirements.yml
│   │   ├── roles
│   │   │   ├── common
│   │   │   │   ├── tasks
│   │   │   │   │   ├── common-packet.yaml
│   │   │   │   │   ├── main.yaml
│   │   │   │   │   ├── pruebaSemap.yaml
│   │   │   │   │   ├── python-packet.yaml
│   │   │   │   │   └── setup.yaml
│   │   │   │   ├── templates
│   │   │   │   │   ├── almalinux.repo.j2
│   │   │   │   │   ├── docker-ce.repo.j2
│   │   │   │   │   ├── hosts.j2
│   │   │   │   │   ├── kernel_modules.conf.j2
│   │   │   │   │   └── kubernetes.repo.j2
│   │   │   │   └── vars
│   │   │   │       └── main.yaml
│   │   │   ├── registry
│   │   │   │   ├── files
│   │   │   │   │   ├── daemon.json
│   │   │   │   │   ├── docker-compose.yml
│   │   │   │   │   ├── harbor-offline-installer-v2.5.0.tar.gz
│   │   │   │   │   ├── harbor.yml
│   │   │   │   │   ├── install.sh
│   │   │   │   │   ├── metadata.json
│   │   │   │   │   ├── registry.cert
│   │   │   │   │   └── trivy.db
│   │   │   │   ├── tasks
│   │   │   │   │   ├── install-docker.yaml
│   │   │   │   │   ├── install-harbor.yaml
│   │   │   │   │   └── main.yml
│   │   │   │   ├── templates
│   │   │   │   │   ├── daemon.json.j2
│   │   │   │   │   ├── docker-compose.yml.j2
│   │   │   │   │   ├── docker.service.j2
│   │   │   │   │   └── v3.ext.j2
│   │   │   │   └── vars
│   │   │   │       └── main.yml
│   │   │   ├── rke2_agent
│   │   │   │   ├── defaults
│   │   │   │   │   └── main.yml
│   │   │   │   ├── tasks
│   │   │   │   │   └── main.yml
│   │   │   │   ├── templates
│   │   │   │   │   └── rke2-agent.j2
│   │   │   │   └── vars
│   │   │   │       └── main.yml
│   │   │   ├── rke2_common
│   │   │   │   ├── defaults
│   │   │   │   │   └── main.yml
│   │   │   │   ├── handlers
│   │   │   │   │   └── main.yml
│   │   │   │   ├── tasks
│   │   │   │   │   ├── add-audit-policy-config.yml
│   │   │   │   │   ├── add-manifest-addons.yml
│   │   │   │   │   ├── add-registry-config.yml
│   │   │   │   │   ├── cis-hardening.yml
│   │   │   │   │   ├── config.yml
│   │   │   │   │   ├── images_tarball_install.yml
│   │   │   │   │   ├── iptables_rules.yml
│   │   │   │   │   ├── main.yml
│   │   │   │   │   ├── network_manager_fix.yaml
│   │   │   │   │   ├── previous_install.yml
│   │   │   │   │   ├── rpm_install.yml
│   │   │   │   │   └── tarball_install.yml
│   │   │   │   └── vars
│   │   │   │       └── main.yml
│   │   │   ├── rke2_server
│   │   │   │   ├── defaults
│   │   │   │   │   └── main.yml
│   │   │   │   ├── tasks
│   │   │   │   │   ├── first_server.yml
│   │   │   │   │   ├── main.yml
│   │   │   │   │   └── other_servers.yml
│   │   │   │   ├── templates
│   │   │   │   │   └── rke2-server.j2
│   │   │   │   └── vars
│   │   │   │       └── main.yml
│   │   │   └── semaphore
│   │   │       ├── tasks
│   │   │       │   ├── install-semaphore.yaml
│   │   │       │   ├── launch-semaphore.yaml
│   │   │       │   └── main.yaml
│   │   │       ├── templates
│   │   │       │   ├── docker-compose.yml.j2
│   │   │       │   └── docker.servicelocalhost.j2
│   │   │       └── vars
│   │   │           └── main.yml
│   │   ├── sample_files
│   │   │   ├── audit-policy.yaml
│   │   │   ├── manifest
│   │   │   │   ├── manifest.yaml
│   │   │   │   └── manifest2.yaml
│   │   │   └── registries.yaml
│   │   ├── site.yml
│   │   └── sites.yaml
│   └── scripts
│       └── setup-host.sh

```
