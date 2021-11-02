#!/usr/bin/env bash
# vim:et:ft=sh:sts=2:sw=2
#
# lib_commun_function.sh
#
#-------------------------------------------------------------------
# 22/01/2021 JN Baudin
# - suppression fonction controle_fichier()
# - suppression fonction controle_fichier_xml()
#
# 08/01/2021 JN Baudin
# x maj controle_fichier affichage du nom du fichier (basename)
#
# 04/01/2021 JN Baudin
# + __msg_error()
# + __msg_debug()
# + __msg_info()
#
# 31/12/2020 JN Baudin
# + show_version()
# + header()
#
# 30/12/2020 JN Baudin
# + controle_os()
# + check_bash_version()
#
# 21/12/2020 JN Baudin
# + __affiche_message()
# + declare_variables_os()
# + controle_variable_environment()
# + FileAge()
# + controle_age_fichier()
# + displaytime()
# + controle_fichier_xml()
# + controle_fichier()
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
# _nom_de_fonction   : fonction interne au programme
#==============================================================================


declare -ir _BOOL=(0 1) # Remember BOOL can't be unset till this shell terminates
readonly false=${_BOOL[0]}
readonly true=${_BOOL[1]}

_ERROR=0
_DEBUG=0
_INFO=0

_VERBOSE=false


__function_list()
{
    echo "functions available:"
    typeset -f | awk '/ \(\) $/ && !/^main / {print $1}'
}


__show_version()
{
  echo "${_PROGRAM} version: ${_VERSION} (${_AUTHOR})";
}

#=============================================================================== 
# Affiche un message formate
# 
# @param 1      : texte a aficher
#
# valeur retour : texte format
#
# dependencies  : none
#
#=============================================================================== 
__affiche_message()
{
  declare _message_
  _message_="${1}"

  declare jour
  jour=$(date +%d-%m-%Y-%H:%M:%S)

  echo "[ ${jour} ] - ${_message_}"

  unset jour 
  unset _message_
}


__header() {
  clear
  # echo -e """
  # ----------------------------------
  # ${PROGNAM} v${VERSION} ${AUTHOR}
  # ----------------------------------\n"""
}


function __msg_error() {
  declare jour
  jour=$(date +%d-%m-%Y-%H:%M:%S)

  [[ "${_ERROR}" == "1" ]] && echo -e "[${jour}][ERROR]: $*"

  unset jour
}

function __msg_debug() {
  declare jour
  jour=$(date +%d-%m-%Y-%H:%M:%S)

  [[ "${_DEBUG}" == "1" ]] && echo -e "[${jour}][DEBUG]: $*"

  unset jour
}

function __msg_info() {
  declare jour
  jour=$(date +%d-%m-%Y-%H:%M:%S)

  [[ "${_INFO}" == "1" ]] && echo -e "[${jour}][INFO]: $*"

  unset jour
}


# echoerr "REVIEW_APPS_GCP_REGION is not set."
#
function echoerr() {
  local header="${2}"

  if [ -n "${header}" ]; then
    printf "\n\033[0;31m** %s **\n\033[0m" "${1}" >&2;
  else
    printf "\033[0;31m%s\n\033[0m" "${1}" >&2;
  fi
}


#
#  if [[ ${#@} -eq 0 ]]; then
#    echoinfo "No forwarding rules to be deleted" true
#    return
#  fi
#
function echoinfo() {
  local header="${2}"

  if [ -n "${header}" ]; then
    printf "\n\033[0;33m** %s **\n\033[0m" "${1}" >&2;
  else
    printf "\033[0;33m%s\n\033[0m" "${1}" >&2;
  fi
}

function echosuccess() {
  local header="${2}"

  if [ -n "${header}" ]; then
    printf "\n\033[0;32m** %s **\n\033[0m" "${1}" >&2;
  else
    printf "\033[0;32m%s\n\033[0m" "${1}" >&2;
  fi
}





#=============================================================================== 
# controle_os
# @param       :
# @return      : 
# dependencies :  check_bash_version()
# exemple      : controle_os
#=============================================================================== 
__controle_os()
{
  # display usage if the script is not un as root user 
  if [[ "${EUID}" -eq 0 ]]; then 
    echo "This script does not be run as root!" 
    exit 1
  fi
  __check_bash_version 4 2
  if [[ "$?" -ne 0 ]];then
    exit 1
  fi
}


#=============================================================================== 
# check_bash_version
# @param       :
# @return      : 
# dependencies : 
# exemple      : check_bash_version 4
#=============================================================================== 
__check_bash_version() {
  local _major_=${1:-4}
  local _minor_=$2

  local rc=0
  local num_re='^[0-9]+$'

  if [[ ! $_major_ =~ $num_re ]] || [[ $_minor_ && ! $_minor_ =~ $num_re ]]; then
    printf '%s\n' "ERROR: version numbers should be numeric"
    return 1
  fi
  if [[ $_minor_ ]]; then
    local bv=${BASH_VERSINFO[0]}${BASH_VERSINFO[1]}
    local vstring=${_major_}.${_minor_}
    local vnum=${_major_}${_minor_}
  else
    local bv=${BASH_VERSINFO[0]}
    local vstring=${_major_}
    local vnum=${_major_}
  fi
  ((bv < vnum)) && {
    printf '%s\n' "ERROR: Need Bash version $vstring or above, your version is ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
    rc=1
  }
  return $rc
}


#=============================================================================== 
# declare_variables_os
# @param       :
# @return      : 
# dependencies : existene fonction __affiche_message
# exemple      : declare_variables_os
#=============================================================================== 
__declare_variables_os()
{
  __controle_os

  declare version_os_

  _GZIP=/usr/bin/gzip
  _MD5=/usr/bin/md5sum 

  version_os_=$(uname -r | grep el)
  case "${version_os_}" in 
    *el6*) _XML=/usr/bin/xmlstarlet ;;
    *el7*) _XML=/usr/bin/xmlstarlet ;;
    *)
      __affiche_message "OS non compatible !!"
      exit 1 ;;
  esac

  if [[ ! -f "${_MD5}" ]];then
    __affiche_message "Utilitaire ${_MD5} absent !!!"
    exit 1
  fi
  if [[ ! -f "${_GZIP}" ]];then
    __affiche_message "Utilitaire ${_GZIP} absent !!!"
    exit 1
  fi
  if [[ ! -f "${_XML}" ]];then
    __affiche_message "Utilitaire ${_XML} absent !!!"
    exit 1
  fi
}


#=============================================================================== 
# Verification de l'existence d'une variable d'environnement
# 
# @param 1      : [EXIST|NO_EXIST] variable d'environnement presence obligatoire
# @param 2      : nom de la variable
# @param 3      : valeur de la variable

# @return       : vrai ou faux la variable existe
#                 valeur retour : valeur 0 = variable existante
#                               : valeur 1 = variable inexistante
#
# dependencies  : none
#
#=============================================================================== 
__controle_variable_environment()
{
  declare _existence_
  declare _variable_
  declare _value_

  _existence_="${1}"
  _variable_="${2}"
  _value_="${3}"

  #__affiche_message "_existence_     [${_existence_}]"
  #__affiche_message "_variable_      [${_variable_}]"
  #__affiche_message "_value_         [${_value_}]"

  #declare _variable__NAME
  #declare _value__NAME
  #_variable__NAME=(${!_variable_@})
  #_value__NAME=(${!_value_@})
  #VAR=\$${_variable_}

  #__affiche_message "_variable__NAME [${_variable__NAME[0]}]"
  #__affiche_message "_value__NAME    [${_value__NAME[0]}]"
  #__affiche_message "\$VAR         [${VAR}]"

  if [[ "${_existence_}" == "EXIST" ]];then
    if [[ ! -n "${_value_}" ]];then
      __affiche_message "Variable      [${_variable_}] absente !]"
      exit 1
    else
      return 0
    fi
  else
    if [[ -n "${_value_}" ]];then
      #__affiche_message "${1}   -- NO_EXIST - Variable      [${_variable_}] [${_value_}] pas vide !]"
      return 0
   else
      __affiche_message "${1}   -- NO_EXIST - Variable      [${_variable_}] [${_value_}] vide !]"
      return 1
    fi
  fi
}


#=============================================================================== 
# Affichage de l'heure en Jour-heure-minute-seconde
# 
# @parm 1      : temps
# @return      : Age en jours-heures-minutes-secondes
#
# dependencies : none
#
#=============================================================================== 
__displaytime()
{
  declare -i _temps_secs_
  _temps_secs_="${1}"

  #__affiche_message "function displaytime arg1 [${1}]" 

  declare -i nb_jour
  declare -i nb_seconde_jour
  declare -i nb_heure
  declare -i nb_minute
  declare -i nb_seconde

  nb_jour=$((_temps_secs_/86400))
  nb_seconde_jour=$((_temps_secs_ - nb_jour*86400))
  nb_heure=$((nb_seconde_jour/3600))
  nb_minute=$((nb_seconde_jour%3600/60))
  nb_seconde=$((nb_seconde_jour%60))

  echo ${nb_jour}j:${nb_heure}h:${nb_minute}m:${nb_seconde}s
}


#=============================================================================== 
# Donne l'age d'un fichier en secondes
# 
# @parm        : un nom de fichier (example: /etc/hosts )
# @return      : Age en secondes
#
# dependencies : none
#
# ex : FileAge /tmp/toto.txt
#=============================================================================== 
__fileage()
{
  declare _filename_
  _filename_="${1}"

  echo $(($(date +%s) - $(date +%s -r "${1}")))
  #echo $(($(date +%s) - $(date +%s -r "$_filename_")))
}


#=============================================================================== 
# Donne l'age d'un fichier en secondes ou en jours
# 
# @parm 1      : un nom de fichier (example: /etc/hosts )
# @parm 2      : [SEC] calcul de l'age en secondes
#              : [DAY] calcul de l'age en jours

# @return      : Age en secondes ou jours
#
# dependencies : none
#
#=============================================================================== 
__controle_age_fichier()
{
  declare _filename_
  declare _unit_

  _filename_="${1}"
  _unit_="${2}"

  declare -i nb_secondes
  declare -i nb_jours

  nb_secondes=$(($(date +%s) - $(date +%s -r "${_filename_}")))
  nb_jours=${nb_secondes}/86400

  if [[ "${_unit_}" = "SEC" ]]; then
    #echo $(($(date +%s) - $(date +%s -r "${_filename_}")))
    echo "${nb_secondes}"
  fi
  if [[ "${_unit_}" = "DAY" ]]; then
    #echo $((($(date +%s) - $(date +%s -r "${_filename_}")) / 86400))
    echo "${nb_jours}"
  fi
}
