#!/bin/sh
# #
#================================================================
#% SYNOPSIS
#+    ${script} <NOM_SCRIPT>
#%
#% DESCRIPTION
#%    Script de generation d'un script pour patch
#%
#-
#==================================================================
#   | version |   date   |   Auteur   |              Libelle
#   ----------+----------+------------+-------------------------------
#   | v1.0    |26/02/2018|    DCL     | initialisation
# -------------------------------------------------------------------------------------------------------------------------------------------------



#####################################################################################################################
if [ -z "$SCRIPTS_PATH" ] || [ -z "$SCRIPTS_LOGS" ]  || [ -z "$SCRIPTS_TOOLS_PATH" ]; then
        echo "ERREUR : variables globales SCRIPTS_PATH ou SCRIPTS_LOGS ou SCRIPTS_TOOLS_PATH pas positionnees !!"
        exit 1
fi
.  "$SCRIPTS_PATH/tools/fonctions_param.sh"
#####################################################################################################################


#---------------------------------------------------------------------------------------------------------------------
# Fonction Questionner : interroger pour avoir les infos
#---------------------------------------------------------------------------------------------------------------------
Questionner()
{
echo "Decrivez votre script !"
echo
read -p "=> Que va faire votre script ? " DESCRIPTION
echo
echo "Il va prendre des parametres obligatoires"
read -p "=> Lesquels (en majuscules) ? (<P1> <P2> ...) : " PARAMS_OBLIG
echo
echo "Et peut-etre des parametres optionnels"
echo "- Vous devez donner : le nom court, le nom long, si une valeur est attendue,
le nom de la variable qui va recevoir la valeur et une explication sur ce parametre"
echo "sous la forme (<nom_court>,[nom_long],<valeur attendue 0/1>,<variable_retour>,<explication>)"
echo "Par exemple : (d,base,1,BASE,nom de la base) (f,fichier_dump,1,DUMP,Fichier d'export)"
echo "ATTENTION : -0 et --help sont reserves, ne les utilisez pas"
echo
echo "Donnez les n uplets en une seule fois"
read -p "=> Entrez vos nuplets : " NUPLETS

# controle : pas de -h dans les parametres optionnels
moins_h=$(echo "$NUPLETS"|grep -c "(h\|,h")
if [ "$moins_h" -ne 0 ]; then echo "ERREUR : vos options ne peuvent commencer par h"; code_retour=1; _Sortie "$0" "$TOUSPARAM"; fi
}

#---------------------------------------------------------------------------------------------------------------------
# Fonction Creer_Cartouche : genere le cartouche
#---------------------------------------------------------------------------------------------------------------------
Creer_Cartouche()
{
HELP_PARAMS_OBLIG=$(echo "<${PARAMS_OBLIG}>"|sed -e "s/ /> </g")
NB_PARAMS_OBLIG=$(wc -w <<<$PARAMS_OBLIG)
echo "#
#=====================================================================================================
#% SYNOPSIS
#+   \${script} $HELP_PARAMS_OBLIG
#%
#% DESCRIPTION
#%   $DESCRIPTION
#%
#% OPTIONS" >>$NOM_SCRIPT

old_IFS=$IFS
IFS=$')'
local i=0
local Chaine_Nuplets_Param_Opt=""
for p in $NUPLETS; do # on lit les nuplets
  #retirer les ()
  p=$(echo "$p"|tr -d '()')

  #couper en zones
  nc=$(echo "$p"|cut -d',' -f1|tr -d ' ')
  nl=$(echo "$p"|cut -d',' -f2)
  ae=$(echo "$p"|cut -d',' -f3)
  var=$(echo "$p"|cut -d',' -f4)
  expli=$(echo "$p"|cut -d',' -f5)
  if [ "$ae" == "1" ]; then lib_ae="="$var; else lib_ae=""; fi
  # afficher
  printf "#%%   -%-1s, --%-20s    %-30s \n" $nc "${nl}${lib_ae}" "$expli" >>$NOM_SCRIPT
  # preparer la chaine parametre de _Param_Decode_Optionnels
  Chaine_Nuplets_Param_Opt=$Chaine_Nuplets_Param_Opt"($nc,$nl,$ae,$var) "
  let i=$i+1
done
IFS=$old_IFS
echo "#%   -0, --help                    Affiche l'aide
#-
#=====================================================================================================
#   | version |   date   |   Auteur   |              Libelle
#   ----------+----------+------------+---------------------------------------------------------------
#   | v0.9    |01/01/2022|    troglo  | Genere par patch_template.sh
# ----------------------------------------------------------------------------------------------------
if [ -z \$SCRIPTS_PATH ] || [ -z \$SCRIPTS_LOGS ]  || [ -z \$SCRIPTS_TOOLS_PATH ]; then
        echo "'"'"ERREUR : variables globales SCRIPTS_PATH ou SCRIPTS_LOGS ou SCRIPTS_TOOLS_PATH pas positionnees !!"'"'"
        exit 1
fi
.  \_SCRIPTS_PATH/tools/fonctions_param.sh
#####################################################################################################################

# 1. Parametres obligatoires
_Param_Decode_Obligatoires "'"'"\$PARAM_SEP"'"'" $NB_PARAMS_OBLIG $PARAMS_OBLIG

# 2. Ici, mettez vos valeurs par defaut pour les param optionnels

# 3. Decodage des parametres optionnels
_Param_Decode_Optionnels "'"'"\$@"'"'" "'"'"${Chaine_Nuplets_Param_Opt}"'"'"

#---------------------------------------------------------------------------------------------------------------------
# MAIN Corps du shell
#---------------------------------------------------------------------------------------------------------------------

echo; echo "'"'"Hello LE TROGLO !"'"'"; echo

######################################################################################################################
# Partie du template a ne pas modifier : Traces de fin et code retour
if [ -z \$code_retour ]; then code_retour=0; fi; _Sortie "'"'"\$0"'"'" "'"'"\$TOUSPARAM"'"'"
######################################################################################################################
">>$NOM_SCRIPT
}

######################################################################################################################
# Decodage des parametres :
# - parametrer _Param_Decode_Obligatoires et _Param_Decode_Optionnels
# - gerer les valeurs par defaut
######################################################################################################################
# 1. Parametres obligatoires
_Param_Decode_Obligatoires "$TOUSPARAM" 1 NOM_SCRIPT

#---------------------------------------------------------------------------------------------------------------------
# MAIN Corps du shell
#---------------------------------------------------------------------------------------------------------------------

clear
echo
echo "Creation du script $NOM_SCRIPT"
echo
[[ -f "${NOM_SCRIPT}" ]] && { echo "ERREUR = $NOM_SCRIPT existe deja"; code_retour=1; _Sortie "$0" "$TOUSPARAM"; }
touch $NOM_SCRIPT
chmod 700 $NOM_SCRIPT
[[ $? -eq 0 ]] || { echo "ERREUR = creation de $NOM_SCRIPT KO"; code_retour=1; _Sortie "$0" "$TOUSPARAM"; }

# avec le debut du script on deduit la techno (et donc les variables d'environnement)
techno=$(tr '[A-Z]' '[a-z]' <<<$(cut -d'_' -f1 <<<$(basename ${NOM_SCRIPT})))
TECHNO=$(tr '[a-z]' '[A-Z]' <<<$(cut -d'_' -f1 <<<$(basename ${NOM_SCRIPT})))

# on demande les infos
Questionner

# c'est un script bash
echo "#!/bin/bash" >$NOM_SCRIPT

# on genere le cartouche
Creer_Cartouche

# afficher le script resultat
echo; echo; echo ". script : $NOM_SCRIPT genere !"
ls -l $NOM_SCRIPT


######################################################################################################################
# Partie du template ▒ ne pas modifier
# Traces de fin et code retour
code_retour=0
_Sortie "$0" "$TOUSPARAM"
######################################################################################################################
