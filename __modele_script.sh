#!/usr/bin/env bash
### vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr
###vim:et:ft=sh:sts=2:sw=2
#
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-p] [-l] -c [fichier de config]
#%
#% DESCRIPTION
#%    C'est un script d'exemple
#%    pour montrer la conception d'un squellette de script
#%
#% OPTIONS
#%    -p, --param                set param setting
#%    -l, --liste                set liste setting
#%    -c [name], --config=[name] set config file name
#%    -h, --help                 print this help
#-
#- IMPLEMENTATION
#-    version         __modele_script.sh 2.1.2
#-    author          Jean-Noel Baudin
#-    Copyright       2021 GIP SILPC https://silpc.fr
#-
#- Licensed under the Apache License, Version 2.0 (the "License");
#- you may not use this file except in compliance with the License.
#- You may obtain a copy of the License at
#-
#-    http://www.apache.org/licenses/LICENSE-2.0
#-
#- Unless required by applicable law or agreed to in writing, software
#- distributed under the License is distributed on an "AS IS" BASIS,
#- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#- See the License for the specific language governing permissions and
#- limitations under the License.
#
#==============================================================================

#
#==============================================================================
#
#          FILE:  __modele_script.sh
#
#   DESCRIPTION:
#
#       OPTIONS:  aucune
#  REQUIREMENTS:  fichier de configuration ./__modele_fichier_config.cfg
#                 bibliotheque      ${SILPC_LIBRARY_PATH}/sh/lib_commun_function.sh
#                 bibliotheque      ${SILPC_LIBRARY_PATH}/sh/lib_fs_function.sh
#                 $DEMAT_SCRIPT
#==============================================================================
# CHANGELOG
#==============================================================================
# 2.1.2 2021-07-09 JNB
# + ajout de la focntion getOptsFunction
#
# 2.1.1 2021-07-07 JNB
# x function rmlock suppression répertoire TMP_DIR
# + utilisation variable SILPC_LIBRARY_PATH
#
# 2.1.0 2021-01-22 JNB
#  
# 1.0.2 10/03/2020 JNB
# - suppresion fonction baba()
# + ajout fonction de compress_fichier
# x correction function _traitement_copie_fichiers() - gestion argument $1
#
#==============================================================================
# convention de nommage des variables
#
# MAJUSCULE           : variable d'environnement ou d'un fichier source
# _MAJUSCULE          : variable globale
#
# _minuscules_       : variable parametre de fonction locale
#  minuscules        : variable locale avec unset
#
# convention de nommage des fonctions
# __nom_de_fonction  : fonction commune
# _nom_de_fonction   : fonction interne
#==============================================================================



### ShellCheck (http://www.shellcheck.net/)

# Exit immediately if a simple command exits with a non-zero status.
set -o errexit

# Treat unset variables as an error when performing parameter expansion.
set -o nounset

set -o pipefail
# set -o xtrace


#=======================================================================
# Initialisation des variables
#=======================================================================

#== program variables ==#
_VERSION='2.2.1'; # <release>.<major change>.<minor change>
_PROGRAM='__modele_script';
_AUTHOR="GIP SILPC 2021";

#-----------------------------------------------------------------------
# Lock file Functions
#-----------------------------------------------------------------------
_TMP_DIR="/tmp/__a_personnaliser__"

[[ ! -d "${_TMP_DIR}" ]] \
    && mkdir -p "${_TMP_DIR}" \
    && chmod 740 "${_TMP_DIR}"

_LOCK_DIR="${_TMP_DIR}/lock"
_LOCK_EXISTS=""


function _mklock() {
    # If it can create $_LOCK_DIR then no other instance is running
    _PROCESS_LOCK_DIR="${_LOCK_DIR}"/$(date +%s.%N).$$ # Private Global. Use Epoch.Nano.PID
     mkdir "${_LOCK_DIR}"
     if [[ "$?" -eq 0 ]]; then
        mkdir "${_PROCESS_LOCK_DIR}"  # create this instance's specific lock in queue
        _LOCK_EXISTS=true  # Global
    else
        echo "FATAL: Lock already exists.
              Another copy is running or manually lock clean up required."
        return 5  # Or work out some sleep_while_execution_lock elsewhere
    fi
}

function _rmlock() {
    if [[ ! -d "${_LOCK_DIR}" ]];then
        echo "WARNING: Lock is missing. ${_LOCK_DIR} does not exist" 
    else	
        rmdir "${_PROCESS_LOCK_DIR}"
        rmdir "${_LOCK_DIR}"
        rmdir "${_TMP_DIR}"
    fi	
}

#-----------------------------------------------------------------------
# Private Signal Traps Functions
#
# DANGER: SIGKILL cannot be trapped. So, try not to `kill -9 PID` or 
#         there will be *NO CLEAN UP*. You'll have to manually remove 
#         any locks in place.
#-----------------------------------------------------------------------
function _sig_exit {

    # Place your clean up logic here 

    # Remove the LOCK
    [[ -n "${_LOCK_EXISTS}" ]] && _rmlock
}

function _sig_int {
    echo "WARNING: SIGINT caught"    
    exit 100
}

function _sig_quit {
    echo "SIGQUIT caught"
    exit 101
}

function _sig_term {
    echo "WARNING: SIGTERM caught"    
    exit 102
}



#-----------------------------------------------------------------------
usage()
{
  printf "Usage: "; \
  head -50 "${0}" | \
  grep "^#+" | \
  sed -e "s/^#+[ ]*//g" -e "s/\${_SCRIPT_NAME}/${_SCRIPT_NAME}/g" ;
  }


usagefull()
{
  head -50 "${0}" | \
  grep -e "^#[%+-]" | \
  sed -e "s/^#[%+-]//g" -e "s/\${_SCRIPT_NAME}/${_SCRIPT_NAME}/g" ;
}


_show_usage() {
  echo -e "Affichage des fichiers du repertoire /tmp\n
           Usage: ./__modele_script.sh
           \t-h | --help\t\tmontre ce menu d'aide
           \t-v | --version\t\tmontre le numero de version
           \t-c | --config \t\tfichier de configuration 
           \t-p | --param \t\taffiche le fichier de configuration"
}


#-----------------------------------------------------------------------
# Gestion des options passees en arguments
#-----------------------------------------------------------------------

_controle_options ()
{ 
  declare options

  # options may be followed by one colon to indicate they have a required argument
  options=$(getopt -o lphc: -l liste,param,help,config: -- "$@")

  set -- $options

  while [ "$#" -gt 0 ]
  do
    case "$1" in

    -l|--liste) _VERBOSE=true ;;

    -p|--param) _SHOW_PARAM=true ;;

    # for options with required arguments, an additional shift is required
    #-c|--config) _CONFIG_FILE="${2}" 
    # suppression des quotes en debut et fin de chaine
    -c|--config) tempo=$(echo ${2} | sed -e "s/^.//" -e "s/.$//") 
                 _CONFIG_FILE="${_DIR}"/"$tempo"
                 echo -e "Fichier de configuration [${_CONFIG_FILE}]" 1>&2
                 shift;;

    -h|--help) _SHOW_USAGE=true ;;

    (--) shift; break;;

    (-*) echo "$0: erreur - option non reconnue $1" 1>&2; exit 1;;

    (*) break;;

    esac
    shift
  done
}




#============================================================================== 
# Traitement des fichiers xxx
# 
# @param 1     : [option 1]
# @param 2     : [OUI|NON]           centralisation du fichier
# @param 3     : [xxxx|yyyy]         archivage du fichier
# @param 4     : liste de fichiers
#
# @return      : 
#
# dependencies : none
#
# exemple      :
#      __traitement_fichiers_1_1 \
#            "option_1" \
#            "option_2" \
#            "${NBJ_RETENTION}" \
#            "${fichiers_a_traiter[@]}"
#
#============================================================================== 
_traitement_fichiers_1_1()
{
    declare _supp_fichier_
    declare _centralisation_
    declare _archivage_

    _supp_fichier_="${1}"
    _centralisation_="${2}"
    _archivage_="${3}"

    shift 3

    declare -a _liste_des_fichiers=("${@}") 

    declare _fichier_source
    declare _nom_de_fichier
    declare _ctrl_file
    declare -i _age_fichier

    for _fichier_source in ${_liste_des_fichiers[*]}
    do
        _ctrl_file=$(__controle_fichier "${_fichier_source}")
        ##__affiche_message "Valeur de _ctrl_file          [${_ctrl_file}]"

        _nom_de_fichier=$( basename "${_fichier_source}" )

        _age_fichier=$(__fileage "${_fichier_source}")
        _date_jjhhmmss=$(__displaytime "${_age_fichier}")

        __affiche_message "Fichier en cours [${_date_jjhhmmss}][${_nom_de_fichier}]"

    done
}


#=============================================================================== 
# Controle des repertoires xxxxx
# @param       :
# @return      : 
# dependencies : none
# example      :
#=============================================================================== 
_traitement_numero_1()
{
  __affiche_message "Debut du traitement numero 1"

  declare -a _fichiers_a_traiter
  declare -i _len

  _fichiers_a_traiter=($(__recherche_fichiers_a_traiter \
                        "/tmp" \
                        "*.*"))
  _len=${#_fichiers_a_traiter[@]}

  if [[ "${_len}" -ne 0 ]];then
    _traitement_fichiers_1_1 \
      "option_1" \
      "option_2" \
      "${NBJ_RETENTION}" \
      "${_fichiers_a_traiter[@]}"
  fi
}


#============================================================================== 
#  Controle du fichier de configuration
# @param  :
# @return      : 
# dependencies : none
# exemple :
#============================================================================== 
_controle_fichier_config(){

  if [[ ! -f "${_CONFIG_FILE}" ]];then
    __affiche_message "Fichier de configuration absent [${_CONFIG_FILE}] !"
    exit 2
  fi

  #chargement des variables du fichier de configuration
  source "${_CONFIG_FILE}"

  __controle_variable_environment \
      "EXIST" \
      NBJ_RETENTION \
      "${NBJ_RETENTION}"
}


#============================================================================== 
# Affichage du fichier de confiuration
# @param  :
# @return      : 
# dependencies : none
# exemple :
#============================================================================== 
_show_param()
{
  __affiche_message "${_TRAIT}"
  __affiche_message "Debut de traitement de xxxxxxxxxxxx"
  __affiche_message "Fichier de configuration          [${_CONFIG_FILE}]"
  __affiche_message "Age mini en ms du fichier         [${AGE_MINI_FICHIER}]"
  __affiche_message "Nb jours de retention             [${NBJ_RETENTION}]"
}

#============================================================================== 
#  Controle des variables d'environnement
# @param  :
# @return      : 
# dependencies : none
# exemple :
#============================================================================== 
_controle_environnement()
{
  __controle_variable_environment \
      "EXIST" \
      SILPC_LIBRARY_PATH \
      "${SILPC_LIBRARY_PATH}"

  __controle_variable_environment \
      "EXIST" \
      DEMAT_SCRIPTS \
      "${DEMAT_SCRIPTS}"

  _controle_fichier_config
}

#============================================================================== 
# declaration variables globales
# @param  :
# @return      : 
# dependencies : none
# exemple :
#============================================================================== 
_declare_variables_globales()
{
  # Set magic variables for current file & dir
  _DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  _FILE="${_DIR}/$(basename "${BASH_SOURCE[0]}")"

  _BASE="$(basename ${_FILE} .sh)"
  #_ROOT="$(cd "$(dirname "${_DIR}")" && pwd)" :# <-- change this as it depends on your app

  _FILE_avant="${_FILE}_avant"
  _FILE_apres="${_FILE}_apres"

  _PRG=$( basename "$0" )
  _SCRIPT_NAME="$(basename ${0})"
  _TRAIT="==========================================================="

}


#=======================================================================
# Main
#=======================================================================

main()
{
  _declare_variables_globales

  # Set TRAPs
  trap _sig_exit EXIT    # SIGEXIT
  trap _sig_int INT      # SIGINT
  trap _sig_quit QUIT    # SIGQUIT
  trap _sig_term TERM    # SIGTERM

  _mklock

  source "${SILPC_LIBRARY_PATH}/sh/lib_commun_function.sh"
  source "${SILPC_LIBRARY_PATH}/sh/lib_fs_function.sh"

  __declare_variables_os

  _SHOW_PARAM=false
  _SHOW_USAGE=false
  _VERSBOSE=false
  _CONFIG_FILE=""

  _controle_options "${@}"

  if [[ "${_SHOW_USAGE}" = true ]]; then
    usagefull && exit 0
  fi    

  _controle_environnement

  if [[ "${_SHOW_PARAM}" = true ]]; then
    _show_param
  fi    

  echo -e "Fichier de configuration [${_CONFIG_FILE}]"


  echo "zzzzzzzz" >/tmp/fichier_test_1.dat
  echo "aaaaaaaa" >/tmp/fichier_test_2.dat
  echo "aaaaaaaa" >/tmp/fichier_test_3.dat
  echo "aaaaaaaa" >/tmp/fichier_test_4.dat

  > /tmp/fichier_test_1_vide.dat
  > /tmp/fichier_test_2_vide.dat

  touch -t 01011102 /tmp/fichier_test_vide_1.dat


  _traitement_numero_1
}


main "${@}"

exit
