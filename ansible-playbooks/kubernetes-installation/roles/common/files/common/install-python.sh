#! /bin/bash

#############
# VARIABLES #
#############
s_null="/dev/null"
install_dir="/tmp/python-offline"
stdout_log="$install_dir/installation_stdout.log"
stderr_log="$install_dir/installation_stderr.log"


function installPython(){

  ################
  # INSTALLATION #
  ################
  #echo "Descomprimiendo archivos..."
  cd $install_dir
  tar xzf Python-3.7.11.tgz
  chmod 755 Python-3.7.11
  tar xzf gcc.tar.gz
  chmod 755 gcc
  tar xzf openssl.tar.gz
  chmod 755 openssl
  tar xzf zlib.tar.gz
  chmod 755 zlib
  tar xzf bzip2-devel.tar.gz
  chmod 755 bzip2-devel
  tar xzf libffi-devel.tar.gz
  chmod 755 libffi-devel
  tar xzf setuptools.tar.gz
  chmod 755 setuptools
  tar xzf pip.tar.gz
  chmod 755 pip

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
  #installAnsible

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
 #rpm -iU libffi-devel/* | tee -a $stdout_log $stderr_log
 yum --disablerepo=* localinstall -y  $install_dir/libffi-devel/*.rpm | tee -a $stdout_log $stderr_log

}



function installOpenSSL() {
  echo "Instalando OpenSSL..."| tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  yum --disablerepo=* localinstall -y  $install_dir/openssl/*.rpm | tee -a $stdout_log $stderr_log
  #rpm -iU  $install_dir/openssl/* | tee -a $stdout_log $stderr_log
}

function installBzip2() {
  echo "Instalando bzip2..."| tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  #rpm -iU $install_dir/bzip2-devel/*
  yum --disablerepo=* localinstall -y  $install_dir/bzip2-devel/*.rpm | tee -a $stdout_log $stderr_log
}

function installZlib() {
  echo "Instalando zlib..."| tee -a $stdout_log $stderr_log
  echo "===========================================================" | tee -a $stdout_log $stderr_log
  yum --disablerepo=* localinstall -y  $install_dir/zlib/*.rpm | tee -a $stdout_log $stderr_log
  #rpm -iU $install_dir/zlib/* | tee -a $stdout_log $stderr_log
}



# Separo la función por si variase en el sistema final
function install_gcc(){
  echo "Instalando gcc y sus dependencias..." |tee -a $stdout_log $stderr_log
  yum --disablerepo=* localinstall -y  gcc/*.rpm | tee -a $stdout_log $stderr_log
  #rpm -iU gcc/* | tee -a $stdout_log $stderr_log
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
   echo "¡Este Script debe ejecutarse como SuperUsuario!" 1>&2
   echo "============================================================================"
   echo
    exit 1
else
  tput civis
  installPython
  #cleanDirectory
  tput cnorm
    exit 0
fi
