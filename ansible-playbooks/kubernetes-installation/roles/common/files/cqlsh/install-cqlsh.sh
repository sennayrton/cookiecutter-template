#!/bin/bash

#############
# VARIABLES #
#############
s_null="/dev/null"
install_dir="/tmp/cqlsh"
stdout_log="$install_dir/installation_stdout.log"
stderr_log="$install_dir/installation_stderr.log"


function install(){

  installCQLSH

}


function installCQLSH() {
  cd $install_dir
  echo "Instalar dependencias de cqlsh..." |tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  python3 -m pip install --no-index six-1.16.0-py2.py3-none-any.whl
  python3 -m pip install --no-index typing_extensions-4.1.1-py3-none-any.whl
  python3 -m pip install --no-index zipp-3.7.0-py3-none-any.whl
  python3 -m pip install --no-index importlib_metadata-4.11.3-py3-none-any.whl
  python3 -m pip install --no-index click-8.0.4-py3-none-any.whl
  python3 -m pip install --no-index geomet-0.2.1.post1-py3-none-any.whl
  python3 -m pip install --no-index cassandra_driver-3.25.0-cp37-cp37m-manylinux1_x86_64.whl
  
  echo "Instalando cqlsh..." |tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  python3 -m pip install --no-index thrift-0.15.0.tar.gz
  python3 -m pip install --no-index cql-1.4.0.tar.gz
  python3 -m pip install --no-index cqlsh-6.0.0-py3-none-any.whl
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

