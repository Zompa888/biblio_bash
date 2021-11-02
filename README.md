# Biblio_bash
bash skeleton

Bibliothèque de fonctions bash

Comme promis un squelette de programme bash avec fonctions maison.<br>
Ce programme liste les fichiers *.* du répertoire /tmp. 

<pre>
.
├── __modele_script.sh
├── __modele_fichier_config.cfg
├── lib
    └── sh
        ├── lib_bash_function.sh
        └── lib_commun_function.sh
</pre>


##convention de nommage

<pre>
convention de nommage des variables

 MAJUSCULE           : variable d'environnement ou d'un fichier source
 _MAJUSCULE          : variable globale

 _minuscules_       : variable parametre de fonction locale
  minuscules        : variable locale avec unset

convention de nommage des fonctions
 
 __nom_de_fonction  : fonction commune
 _nom_de_fonction   : fonction interne au programme
</pre>

Fichier de configuration

<pre>
# Fichier de configuration [__modele_fichier_config.cfg]
# site : xxxxxx
# date : 21-01-2021
# compatibilite 
# --------------------------------------------------------------------
#
# Age du fichier en secondes pour etre pris selectionner dans partraitement
AGE_MINI_FICHIER=120
#
# Nbre de jours pour conserver les fichiers avant
# suppression du fichier
NBJ_RETENTION=100
</pre>

<pre>
$ ./__modele_script.sh --help
Affichage des fichiers du repertoire /tmp
 
           Usage: ./__modele_script.sh
                -h |--help              montre ce menu d'aide
                -v | --version          montre le numero de version et autres informations
                -p | --param            affiche le fichier de configuration
</pre>

<pre>
$ ./__modele_script.sh --version
__modele_script version: 0.0.7 (GIP SILPC 2020)
</pre>

<pre>
$ ./__modele_script.sh --param 
[ 26-01-2021-17:10:02 ] - ===========================================================
[ 26-01-2021-17:10:02 ] - Debut de traitement de xxxxxxxxxxxx
[ 26-01-2021-17:10:02 ] - Fichier de configuration                        [/demat_soft/demat/scripts/__modele_fichier_config.cfg]
[ 26-01-2021-17:10:02 ] - Age mini en ms du fichier                       [120]
[ 26-01-2021-17:10:02 ] - Nb jours de retention                           [100]
[ 26-01-2021-17:10:02 ] - Debut du traitement numero 1
[ 26-01-2021-17:10:02 ] - Fichier en cours [25j:6h:8m:2s][fichier_test_vide_1.dat]
[ 26-01-2021-17:10:02 ] - Fichier en cours [0j:0h:0m:0s][fichier_test_1.dat]
[ 26-01-2021-17:10:02 ] - Fichier en cours [0j:0h:0m:0s][fichier_test_1_vide.dat]
[ 26-01-2021-17:10:02 ] - Fichier en cours [0j:0h:0m:0s][fichier_test_2.dat]
[ 26-01-2021-17:10:02 ] - Fichier en cours [0j:0h:0m:0s][fichier_test_2_vide.dat]
[ 26-01-2021-17:10:02 ] - Fichier en cours [0j:0h:0m:0s][fichier_test_3.dat]
[ 26-01-2021-17:10:02 ] - Fichier en cours [0j:0h:0m:0s][fichier_test_4.dat]
</pre>

<pre>
$ ./__modele_script.sh --liste
[ 26-01-2021-17:10:18 ] - Debut du traitement numero 1
[ 26-01-2021-17:10:18 ] - Fichier en cours [25j:6h:8m:18s][fichier_test_vide_1.dat]
[ 26-01-2021-17:10:18 ] - Fichier en cours [0j:0h:0m:0s][fichier_test_1.dat]
[ 26-01-2021-17:10:18 ] - Fichier en cours [0j:0h:0m:0s][fichier_test_1_vide.dat]
[ 26-01-2021-17:10:18 ] - Fichier en cours [0j:0h:0m:0s][fichier_test_2.dat]
[ 26-01-2021-17:10:18 ] - Fichier en cours [0j:0h:0m:0s][fichier_test_2_vide.dat]
[ 26-01-2021-17:10:18 ] - Fichier en cours [0j:0h:0m:0s][fichier_test_3.dat]
[ 26-01-2021-17:10:18 ] - Fichier en cours [0j:0h:0m:0s][fichier_test_4.dat]
</pre>

<pre>
$ ./__modele_script.sh --function
functions available:
__affiche_message
__check_bash_version
__compress_fichier
__controle_age_fichier
__controle_fichier
__controle_fichier_type_xml
__controle_fichier_xml
__controle_os
__controle_repertoire
__controle_repertoire_archive
__controle_variable_environment
__creation_repertoire
__declare_variables_os
__displaytime
__ecriture_fichier_cible
__fileage
__function_list
__header
__msg_debug
__msg_error
__msg_info
__recherche_fichiers_a_traiter
__show_version
_controle_environnement
_controle_fichier_config
_declare_variables_globales
_mklock
_rmlock
_show_param
_show_usage
_sig_exit
_sig_int
_sig_quit
_sig_term
_traitement_fichiers_1_1
_traitement_numero_1
</pre>
