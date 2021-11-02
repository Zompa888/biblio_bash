#!/usr/bin/env bash
# vim: syntax=sh cc=80 tw=79 ts=4 sw=4 sts=4 et sr
#
# lib_fs_function.sh
#
#-------------------------------------------------------------------
# 22/01/2021 JN Bbaudin
# + controle_fichier
# + controle_fichier_xml
#
# 08/01/2021 JNB
# x Correction code
#
# 22/12/2020 JNB
# + creation_repertoire()
# + controle_repertoire()
# + ecriture_fichier_cible()
# + compress_fichier()
# + recherche_fichiers_a_traiter()
# + controle_repertoire_archive()
#-------------------------------------------------------------------

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


#==============================================================================
# creation de repertoire
#
# @param 1      : repertoire racine
#
# valeur retour :
#
# dependencies  : none
#
#==============================================================================
__creation_repertoire()
{
  declare _repertoire_

  _repertoire_="${1}"

  if [[ -z "${_repertoire_}" ]];then
    return 1
  fi

  if [[ ! -d "${_repertoire_}" ]];then
    __affiche_message "Repertoire [${_repertoire_}] inexistant ! - Creation"
    mkdir -p "${_repertoire_}" && \
    chmod ug+w "${_repertoire_}"
  fi
}


#==============================================================================
# controle_repertoire
#
# @param 1      : repertoire de recherche
#
# valeur retour :
#
# dependencies  : none
#
#============================================================================== 
__controle_repertoire()
{
    declare _repertoire_
    _repertoire_="${1}"

    if [[ ! -d "${_repertoire_}" ]];then
        __affiche_message "Repertoire [$_repertoire_] inexistant !"
        exit 1
    fi
}


#============================================================================== 
# Ecriture fichier cible
# 
# @param 1      : fichier source -- nom original du fichier en absolu
# @param 2      : fichier cible  -- nom original du fichier en absolu

# dependencies  : none
#
# ecriture_fichier_cible fic1 fic2
#
# si param 1 est vide alors on unique le fichier cible
# ecriture_fichier_cible "" fic1.ok
#
#============================================================================== 
__ecriture_fichier_cible()
{
    declare _fichier_source_
    declare _fichier_cible_

    _fichier_source_="${1}"
    _fichier_cible_="${2}"

    if [[ -z "${_fichier_source_}" ]];then
        # creation du fichier
        touch "${_fichier_cible_}" && \
        chmod 666 "${_fichier_cible_}"
    else    
        # copie fichier source vers fichier cible
        cp -p "${_fichier_source_}" "${_fichier_cible_}" && \
        chmod 666 "${_fichier_cible_}"
    fi
}


#==============================================================================
# compress_fichier
#
# @param 1      : fichier a compresser
#
# valeur retour :
#
# dependencies  : existence de ${GZIP}
#
#==============================================================================
__compress_fichier()
{
    declare _fichier_a_traiter_
    _fichier_a_traiter_="${1}"

    #__affiche_message "Compression du fichier [${fichier_a_traiter}]"
    ${_GZIP} -f "${_fichier_a_traiter_}"
}


#============================================================================== 
# Liste des fichiers d'un repertoire d'apres un modele par ordre chronologique
# 
# @param 1      : repertoire de recherche
# @param 2      : modele de recherche
#
# valeur retour : liste des fichiers selectionnes par ordre chronologique
#
# dependencies  : none
# example       : recherche_fichiers_a_traiter /tmp/rep_test  *.xml
#============================================================================== 
__recherche_fichiers_a_traiter()
{
    declare _repertoire_
    declare _nom_du_modele_

    _repertoire_="${1}"
    _nom_du_modele_="${2}"

    declare _liste_des_fichiers

    _liste_des_fichiers=$(find "${_repertoire_}" -maxdepth 1 -type f -name "${_nom_du_modele_}" -printf "%T+\t%p\n" | sort | awk '{print $2}')
    echo "${_liste_des_fichiers}"
}


#============================================================================== 
# controle_repertoire_archive
# 
# @param 1      : repertoire racine
# @param 2      : sous-repertoire
#
# valeur retour :
#
# dependencies  : existence fonction __affiche_message
#
#============================================================================== 
__controle_repertoire_archive()
{
  declare _racine_
  declare _repertoire_

  _racine_="${1}"
  _repertoire_="${2}"

  declare _repertoire_archive
  _repertoire_archive="${_racine_}"

  if [[ -n "${_repertoire_}" ]];then
    _repertoire_archive=${_racine_}/$(basename "${_repertoire_}")
  fi
  if [[ ! -d "${_repertoire_archive}" ]];then
    __affiche_message "_repertoire_ [${_repertoire_archive}] inexistant ! - Creation"
    mkdir -p "${_repertoire_archive}" && \
    chmod ug+w "${_repertoire_archive}"
  fi
}



#=============================================================================== 
# Controle d'un fichier
#
# @parm 1      : fichier
#
# @return      : 5 = fichier trop recent
#              : 2 = fichier vide
#              : 3 = presence d'un fichier err
#              : 4 = format XML non conforme
#
# dependencies :
#
# exemple      :  controle_fichier "${FileName}"  [0|1]
#=============================================================================== 

__controle_fichier()
{ 
    declare _nom_fichier

    _nom_fichier="${1}"

    declare -i _age_fichier

    _age_fichier=$(__fileage "${_nom_fichier}")

    # Controle de l'age du fichier en secondes
    if [[ ! "${_age_fichier}" -gt "${AGE_MINI_FICHIER}" ]];then        
       __affiche_message "[${_nom_fichier}] Fichier trop recent"
       #return 5
       echo  5
    fi    
   
    if [[ ! -s "${_nom_fichier}" ]];then
       __affiche_message "Fichier vide           [${_nom_fichier}]"
       #return 2
       echo 2
    fi
    if [[ -f "${_nom_fichier}.err" ]];then
       __affiche_message "Fichier erreur present" 
       return 3
    fi
}

__controle_fichier_improved()
{ 
    declare _nom_fichier

    _nom_fichier="${1}"

    declare -i _age_fichier

    _age_fichier=$(__fileage "${_nom_fichier}")

    # Controle de l'age du fichier en secondes
    if [[ "${_age_fichier}" -lt "${AGE_MINI_FICHIER}" ]];then        
       #__affiche_message "[${_nom_fichier}] Fichier trop recent"
       return 5
       #echo  5
    fi    
   
    if [[ ! -s "${_nom_fichier}" ]];then
       #__affiche_message "Fichier vide           [${_nom_fichier}]"
       return 2
       #echo 2
    fi
    if [[ -f "${_nom_fichier}.err" ]];then
       #__affiche_message "Fichier erreur present" 
       return 3
    fi
}
#=============================================================================== 
# Controle d'un fichier de type xml
#
# @parm 1      : fichier
#
# @return      : 5 = fichier trop recent
#              : 2 = fichier vide
#              : 3 = presence d'un fichier err
#              : 4 = format XML non conforme
#
# dependencies :
#
# exemple      :  controle_fichier "${FileName}"  [0|1]
#=============================================================================== 

__controle_fichier_type_xml()
{ 
    declare _nom_fichier

    _nom_fichier="${1}"

    declare -i _age_fichier

    _age_fichier=$(__fileage "${_nom_fichier}")

    # Controle de l'age du fichier en secondes
    if [[ ! "${_age_fichier}" -gt "${AGE_MINI_FICHIER}" ]];then        
       __affiche_message "[${_nom_fichier}] Fichier trop recent"
       return 5
    fi    
   
    if [[ ! -s "${_nom_fichier}" ]];then
       __affiche_message "Fichier vide           [${_nom_fichier}]"
       return 2
    fi
    if [[ -f "${_nom_fichier}.err" ]];then
       __affiche_message "Fichier erreur present" 
       return 3
    fi
    if [[ $( __controle_fichier_xml "${_nom_fichier}" ) -eq 1 ]];then
        __affiche_message "Fichier XML non valide [${_nom_fichier}]" 
        return 4
    fi    
}


#=============================================================================== 
# Controle de la validite d'un fichier XML
# 
# @parm1       : nom de fichier
#
# @return      : valeur [0|1]
#
# dependencies : existence de ${XML}
# example      : controle_fichier_xml /tmp/xmlfile.xml
#=============================================================================== 
__controle_fichier_xml()
{
  declare _FileName
  _FileName="${1}"

  "${_XML}" val "${_FileName}"  >/dev/null 2>&1
  echo "$?"
}

#=============================================================================== 
# Calcul du nombre d'element d'un fichier XML
# 
# @parm1       : nom de fichier
# @parm2       : element a compter
#
# @return      : valeur [0|1]
#
# dependencies : existence de ${XML}
# example      : controle_fichier_xml_element \
#                  /tmp/xmlfile.xml          \
#                  "//PES_DepenseAller"
#=============================================================================== 
__controle_fichier_xml_element()
{
  declare _FileName
  declare _Pattern
  _FileName="${1}"
  _Pattern="${2}"

  declare _FileName_tempo
  _FileName_tempo=/tmp/temp_file_$$.xml
 
   #echo -e "valeur de _Pattern  [${_Pattern}]"
   #echo -e "valeur de _FileName_tempo  [${_FileName_tempo}]"
 
   ${_XML} fo -D ${_FileName}  > ${_FileName_tempo}

   echo $("${_XML}" sel -t -c "count("${_Pattern}")" "${_FileName_tempo}")

   if [[ -f "${_FileName_tempo}" ]];then
     rm -f "${_FileName_tempo}"
  fi
}
