#! /bin/bash

#############
# VARIABLES #
#############
s_null="/dev/null"
install_dir="/tmp/ansible"
stdout_log="$install_dir/installation_stdout.log"
stderr_log="$install_dir/installation_stderr.log"


function install(){

  ################
  # INSTALLATION #
  ################
  cd ${install_dir}
  tar xzf ansible.tar.gz
  chmod 755 ansible

  installAnsible

}


function installAnsible() {
  cd $install_dir
  echo "Instalar dependencias de Ansible..." |tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  pip3.7 install $install_dir/*.whl
  
  echo "Instalando Ansible..." |tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  pip3.7 install $install_dir/ansible-2.9.27.tar.gz
}


# Comprobamos que el fichero Bash ha sido ejecutado como SuperUsuario - root.
# En caso FALSE informamos al usuario de que ejecute de nuevo como root.
# En caso TRUE se llama a la función de instalación.
if [ "$(id -u)" != "0" ]; then
   echo
   echo "============================================================================"
   echo "¡Este Script debe ejecutarse como SuperUsuario!" 1>&2
   echo "============================================================================"
   echo
    exit 1
else
  install
    exit 0
fi

