#! /bin/bash


## Necesario pasar el fichero comprimido con todas las dependencias de Python y Ansible previamente a la ruta /tmp
## Fichero => ansible-bash.tar.gz

#############
# VARIABLES #
#############
install_dir="/tmp/python-ansible"
stdout_log="$install_dir/installation_stdout.log"
stderr_log="$install_dir/installation_stderr.log"

function ctrl_c() {
  echo -e "\n[!] Saliendo..."
  exit 1
}

# Ctrl+C
trap ctrl_c INT

function install(){

  ################
  # INSTALLATION #
  ################
  #echo "Descomprimiendo archivos..."
  cd /tmp/
  tar xzf ansible-bash.tar.gz
  chmod 755 $install_dir
  tar xzf $install_dir/Python-3.7.11.tgz
  chmod 755 $install_dir/Python-3.7.11
  tar xzf $install_dir/gcc.tar.gz
  chmod 755 $install_dir/gcc
  tar xzf $install_dir/openssl.tar.gz
  chmod 755 $install_dir/openssl
  tar xzf $install_dir/zlib.tar.gz
  chmod 755 $install_dir/zlib
  tar xzf $install_dir/bzip2-devel.tar.gz
  chmod 755 $install_dir/bzip2-devel
  tar xzf $install_dir/libffi-devel.tar.gz
  chmod 755 $install_dir/libffi-devel
  tar xzf $install_dir/setuptools.tar.gz
  chmod 755 $install_dir/setuptools
  tar xzf $install_dir/pip.tar.gz
  chmod 755 $install_dir/pip
  tar xzf $install_dir/ansible.tar.gz
  chmod 755 $install_dir/ansible

  installDependencies

  echo "Configurando la instalación" | tee -a $stdout_log $stderr_log
  echo "Esto puede tardar unos minutos..." | tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  cd $install_dir/Python-3.7.11
  ./configure  2>>$stderr_log 1>>$stdout_log
  echo "Compilando python..."| tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  make 2>>$stderr_log 1>>$stdout_log
  echo "Instalando python..."| tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  make install 2>>$stderr_log 1>>$stdout_log

  installSetupTools
  installPIP
  installAnsible

}

function installDependencies() {
  echo "Instalando dependencias..."| tee $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  install_gcc
  installZlib
  installBzip2
  installOpenSSL
  installLibffiDevel
}


function installAnsible() {
  cd $install_dir/ansible
  echo "Instalar dependencias de Ansible..." |tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  pip3.7 install $install_dir/ansible/*.whl
  
  echo "Instalando Ansible..." |tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  pip3.7 install $install_dir/ansible/ansible-2.9.27.tar.gz
}



function installPIP() {
  cd $install_dir/pip
  echo "Compilando PIP..." | tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  python3.7 ./setup.py build 2>>$stderr_log 1>>$stdout_log
  echo "Instalando PIP..." | tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  python3.7 ./setup.py install 2>>$stderr_log 1>>$stdout_log

}


function installSetupTools() {
  cd $install_dir/setuptools
  echo "Compilando setupTools..." | tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  python3.7 ./setup.py build 2>>$stderr_log 1>>$stdout_log
  echo "Instalando setupTools..." | tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  python3.7 ./setup.py install 2>>$stderr_log 1>>$stdout_log

}

function installLibffiDevel() {
 echo "Instalando libffi-devel..." |tee -a $stdout_log $stderr_log
 echo "===========================================================" | tee -a $stdout_log $stderr_log
 yum --disablerepo=* localinstall -y $install_dir/libffi-devel/*.rpm | tee -a $stdout_log $stderr_log

}



function installOpenSSL() {
  echo "Instalando OpenSSL..."| tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  yum --disablerepo=* localinstall -y $install_dir/openssl/*.rpm | tee -a $stdout_log $stderr_log
}

function installBzip2() {
  echo "Instalando bzip2..."| tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log 
  yum --disablerepo=* localinstall -y $install_dir/bzip2-devel/*.rpm
}

function installZlib() {
  echo "Instalando zlib..."| tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  yum --disablerepo=* localinstall -y $install_dir/zlib/*.rpm | tee -a $stdout_log $stderr_log 
}

function install_gcc(){
  echo "Instalando gcc y sus dependencias..." |tee -a $stdout_log $stderr_log
  yum --disablerepo=* localinstall -y $install_dir/gcc/*.rpm | tee -a $stdout_log $stderr_log
}

function cleanDirectory() {
  echo "Limpiamos los ficheros generados..."| tee -a $stdout_log $stderr_log
  rm -rf $install_dir/libffi-devel/ $install_dir/zlib/ $install_dir/Python-3.7.11/ $install_dir/openssl/ $install_dir/gcc/ $install_dir/bzip2-devel/ 
}


# Comprobamos que el fichero Bash ha sido ejecutado como SuperUsuario - root.
# En caso FALSE informamos al usuario de que ejecute de nuevo como root.
# En caso TRUE se llama a la función de instalación.
if [ "$(id -u)" != "0" ]; then
   echo
   echo "============================================================================"
   echo "¡Este Script debe ejecutarse como Root o con permisos de SUDO" 1>&2
   echo "============================================================================"
   echo
    exit 1
else
  install
  cleanDirectory
  exit 0
fi
