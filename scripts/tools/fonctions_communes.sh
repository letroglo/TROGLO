#!/bin/sh
#==================================================================
#   | version |   date   |   Auteur   |              Libelle
#   ----------+----------+------------+-------------------------------
#   | v1.0    |24/11/2022|    BBRUN   | initialisation
# ------------------------------------------------------------------------------------------------------------------------------------------------- 

#---------------------------------------------------------------------------------------------------------------------
# Fonction _Param_Decode_Obligatoires : decode les param obligatoires, les rend aux variables passees
# Entree : 
# - "$@"
# - nb de param obligatoires
# - noms des variables attendues en retour
# Sortie :
# - positionne les variables attendues et g_MY_OPTIND
#---------------------------------------------------------------------------------------------------------------------
function _Param_Decode_Obligatoires
{
  # Globale necessaire
  g_MY_OPTIND=1 #sera modifiee apres decodage des parametres obligatoires

  local ind=0
  local array_var array_value
  local params="$1" #=PARAM_SEP
  local nb_params=$(echo $params|wc -w)
  local NB_PARAM_POSITIONNELS=$2 #nb param positionnels obligatoires 
  shift 2 # pour sauter la chaine en entree et le nb de param

  # verif nb de parametres positionnels du script
  old_IFS=$IFS
  IFS=$'#' 
  local nb=0
  for arg in $(echo "$params"); do
    #v1.202 if [ $(echo "$arg"|cut -c1) == '-' ]; then break; # si $arg vaut -n sort en erreur
		if [ $(printf "%s" "$arg"|cut -c1) == '-' ]; then break;
    else let nb=$nb+1; fi;
  done
  IFS=$old_IFS
  if [ $nb -ne $NB_PARAM_POSITIONNELS ]; 
  then 
    if [ $(echo "$params"|grep -E "\-0|\-\-help"|wc -l) -ne 0 ] || [ $nb_params -eq 0 ] #v1.03
    then
      UsageFull; exit 99;
    else
      echo "ERREUR : Il faut $NB_PARAM_POSITIONNELS parametres et vous en avez donne $nb"
	Usage
	exit 99
    fi
  fi
  # variables en retour
  g_MY_OPTIND=$(expr $NB_PARAM_POSITIONNELS + 1) # v_globale : index ou commencent les param optionnels
  #[[ $NB_PARAM_POSITIONNELS -eq 1 ]] && shift 1

  echo "${WLP} Parametres obligatoires :"
	OLD_IFS=$IFS
	IFS=' '
	#echo "$@"|read -r -a array_var
	# version AIX
	let ind=0
	for ch in $@
	do
		array_var[$ind]=$ch
		let ind=$ind+1
	done

	IFS='#'
	# echo "$params"|read -r -a array_value
        # version AIX
        let ind=0
        for ch in $params
        do
                array_value[$ind]=$ch
                let ind=$ind+1
        done

	IFS=$OLD_IFS
#  IFS='#' read -r -a array_value <<< "$params"

  #for (( ind=0; ind<${#array_var[@]}; ind++ )); do
  let ind=0
	while [ $ind -lt ${#array_var[@]} ]
	do  
 		eval ${array_var[ind]}='"'${array_value[ind]}'"'
		echo "${WLP} "${array_var[ind]} = ${array_value[ind]}
		let ind=$ind+1
  done
  return $?
}


#---------------------------------------------------------------------------------------------------------------------
# Fonction _Param_Decode_Optionnels : recupere les valeurs des params optionnels
# Globales : 
# - tableaux ARRAY_AE, ARRAY_NL et ARRAY_NC
# Sortie :
# - positionne les variables de chaque option
#---------------------------------------------------------------------------------------------------------------------
function _Param_Decode_Optionnels
{
  local OPTIND=$g_MY_OPTIND # necessaire OPTINF doit etre local
  # on  compose 4 tableaux avec les descriptions des parametres attendus
 
  local i=0
  #v1.04 for p in $( echo ${!#}); do #${!#} = dernier parametre de la fonction
 #compatible AIX  for p in $( echo ${*: -1}); do #${*: -1} = dernier parametre de la fonction - compatible RHEL7
for last in "$@"; do :; done # determine le dernier parametre
for p in $last; do
    #retirer les ()
    p=$(echo $p|tr -d '()')
    
    #couper en 4 zones
    nc=$(echo $p|cut -d',' -f1)
    nl=$(echo $p|cut -d',' -f2)
    ae=$(echo $p|cut -d',' -f3)
    var=$(echo $p|cut -d',' -f4)
    
    #competer les tableaux
    ARRAY_NC[i]="$nc"
    ARRAY_NL[i]="$nl"
    ARRAY_AE[i]="$ae"
    ARRAY_VAR[i]="$var"
    
    let i=$i+1
  done
  _Param_Init LIST_OPTIONS SCRIPT_OPTS

# ajout option help
  ARRAY_NC[${#ARRAY_NC[@]}]="0"  #v1.03
  ARRAY_NL[${#ARRAY_NC[@]}]="help" 

#echo dollararrobase $@; echo

if [ $OS != 'Linux' ]
then
	let val=$OPTIND-1
	shift $val # on shifte les param obligatoires deja lus
	
#echo DEBU ap $1 $2 $3
fi
#echo dollararrobase aprs shift $@; echo
  #== parse options ==#
  while getopts ${SCRIPT_OPTS} OPTION; do
#echo
  #echo "juste apres getops" OPTION $OPTION  OPTARG $OPTARG OPTIND $OPTIND
  #== translate long options to short ==#
    if [[ "x$OPTION" == "x-" ]]; then
      LONG_OPTION=$OPTARG
      LONG_OPTARG=$(echo $LONG_OPTION | grep "=" | cut -d'=' -f2)
      LONG_OPTIND=-1
      [[ "x$LONG_OPTARG" = "x" ]] && LONG_OPTIND=$OPTIND || LONG_OPTION=$(echo $OPTARG | cut -d'=' -f1)
      [[ $LONG_OPTIND -ne -1 ]] && eval LONG_OPTARG="\$$LONG_OPTIND"
      # ksh uniquement OPTION=${ARRAY_OPTS[$LONG_OPTION]}
      OPTION=$(_Param_Get_Nom_Court $LONG_OPTION)
      [[ $? -ne 0 ]] && printf "\nERREUR option longue invalide : $LONG_OPTION \n " && Usage >&2 && exit 99 
      
      [[ "x$OPTION" = "x" ]] &&  OPTION="?" OPTARG="-$LONG_OPTION" 

      if [[ $( echo "${SCRIPT_OPTS}" | grep -c "${OPTION}:" ) -eq 1 ]]; then
        if [[ "x${LONG_OPTARG}" = "x" ]] || [[ "${LONG_OPTARG}" = -* ]]; then
          OPTION=":" OPTARG="-$LONG_OPTION"
          #echo "dans le then"
        else
          OPTARG="$LONG_OPTARG";
          if [[ $LONG_OPTIND -ne -1 ]]; then
            [[ $OPTIND -le $Optnum ]] && OPTIND=$(( $OPTIND+1 ))
#echo debug shift optind $OPTIND
            shift $OPTIND
            OPTIND=1
          fi
        fi
      fi
    fi 
    #echo apres long option OPTION $OPTION  OPTARG $OPARG
    #== options follow by another option instead of argument ==#
    if [[ "x${OPTION}" != "x:" ]] && [[ "x${OPTION}" != "x?" ]] && [[ "${OPTARG}" = -* ]]; then
      OPTARG="$OPTION" OPTION=":"
    fi 

    #== manage options ==#
    if [ $(echo $LIST_OPTIONS|grep $OPTION) ] 
    then
      [[ $(_Param_Argument_Excepted $OPTION) == "0" ]] && OPTARG='yes' #si pas d'argument excepted alors 'yes'
      eval $(_Param_Get_Variable $OPTION)='"'${OPTARG}'"'
    else
      case "$OPTION" in
        "0") UsageFull && exit 0 ;; #v1.03
        "?") printf "\nERREUR option invalide : -$OPTARG \n " && Usage >&2 && exit 99 ;;
        ":") printf "\nERREUR option -$OPTARG : necessite une valeur \n " && Usage >&2 && exit 99 ;;
      esac
    fi 

  done
	#echo DEBUG OPTIND $OPTIND
  # utile ??? shift $((${OPTIND} - 1))

  # Afficher les options decodees
  echo "${WLP} Parametres optionnels - variables en retour"
  i=0
  for opt in ${ARRAY_NC[*]}
  do
    if [ "x${opt}" != "x0" ] #v1.03
    then
      var=$(_Param_Get_Variable $opt)
      value=$(eval echo "\$"$var)
      echo "${WLP} $var = $value"
    fi
    let i=$i+1
  done
  
  # liberer les variables de getops
  unset OPTSTRING
  unset OPTIND
}


#---------------------------------------------------------------------------------------------------------------------
# Fonction _Param_Option_String : construit l'option string pour getops
# Globales : 
# - le tableau ARRAY_NC et ARRAY_AE : les parametres en nom court et excepted ou pas
# Sortie :
# - Retourne l'option string necessaire a getops
#---------------------------------------------------------------------------------------------------------------------
function _Param_Option_String
{
  local ch=":"  # ":" en premier pour tester les parametres inattendus
  local i=0
  trouve=0 #false
  for arg_excepted in ${ARRAY_AE[*]}
  do
    if [ "x${arg_excepted}" == "x1" ]
    then
      ch=${ch}${ARRAY_NC[i]}":"
    else
      ch=${ch}${ARRAY_NC[i]}
    fi    
    let i=$i+1
  done
  # ajouter les options necessaires au code
  #ch=${ch}"-:h"
  ch=${ch}"-:0" #v1.03
  echo $ch
}

#---------------------------------------------------------------------------------------------------------------------
# Fonction _Param_Init : verifie les tableaux, initialise les variables utiles
# S'appelle en passant les noms des variables et non leur valeur !
#---------------------------------------------------------------------------------------------------------------------
function _Param_Init 
{
    #---------------------------------------------------------------------------------------------------------------------
    # Fonction _Param_List_Options : liste des param noms courts (pour le case)
    # Globales : 
    # - le tableau ARRAY_NC : les parametres en nom court
    # Sortie :
    # - Retourne la liste des param courts separes par des |
    #---------------------------------------------------------------------------------------------------------------------
    function _Param_List_Options
    {
      local ch=""
      for mot in ${ARRAY_NC[*]}
      do
        ch=$ch"|"$mot
      done
      #retirer le premier |
      ch=$(echo $ch|cut -c2-)
      echo $ch
    }

    #---------------------------------------------------------------------------------------------------------------------
    # Fonction _Param_Option_String : construit l'option string pour getops
    # Globales : 
    # - le tableau ARRAY_NC et ARRAY_AE : les parametres en nom court et excepted ou pas
    # Sortie :
    # - Retourne l'option string necessaire a getops
    #---------------------------------------------------------------------------------------------------------------------
    function _Param_Option_String
    {
      local ch=":"  # ":" en premier pour tester les parametres inattendus
      local i=0
      trouve=0 #false
      for arg_excepted in ${ARRAY_AE[*]}
      do
        if [ "x${arg_excepted}" == "x1" ]
        then
          ch=${ch}${ARRAY_NC[i]}":"
        else
          ch=${ch}${ARRAY_NC[i]}
        fi    
        let i=$i+1
      done
      # ajouter les options necessaires au code
      #ch=${ch}"-:h"
      ch=${ch}"-:0" #v1.03
      echo $ch
    }

### corps de la fonction ###
  local i=0
  local erreur=0 #false
  local list=""
  
  # les param contiennent le nom des variables à retourner
  local p1=$1
  local p2=$2
  
  # verif coherence tableaux
  ## NL et AE doivent avoir un NC
  for NL in ${ARRAY_NL[*]}
  do
    [[ "${ARRAY_NC[i]}" == "" ]] && printf "\nERREUR DE CODE: Dans ARRAY_NL, "'"'$NL'"'" indice "'"'$i'"'" n'a pas de nom court dans ARRAY_NC\n " && exit 999
    let i=$i+1
  done
  let i=0
  for AE in ${ARRAY_AE[*]}
  do
    [[ "${ARRAY_NC[i]}" == "" ]] && printf "\nERREUR DE CODE : Dans ARRAY_AE, l'indice "'"'$i'"'" n'a pas de nom court dans ARRAY_NC\n " && exit 999
    let i=$i+1
  done

  #init et retour desvariables pour le case et getops
  eval $p1="'$(_Param_List_Options)'"
  eval $p2="'$(_Param_Option_String)'"
}

#---------------------------------------------------------------------------------------------------------------------
# fonctions usage
#---------------------------------------------------------------------------------------------------------------------
Usage ()
{ 
	printf "Usage: "; head -50 ${DOLLAR_ZERO} | grep "^#+" | sed -e "s/^#+[ ]*//g" -e "s/\${script}/${script}/g" ; 
}

UsageFull ()
{ 
Saut='
' # c'est moche mais \n\n ne marche pas sous AIX ...
head -100 ${DOLLAR_ZERO} | grep -e "^#[%+=]" | sed -e "s/^#[%+=]//g" -e "s/\${script}/${script} ${version} \\${Saut}\\${Saut}   ${script}/g" ; 
}


#---------------------------------------------------------------------------------------------------------------------
# Fonction _Sortie : appelée pour sortir en traçant : paramètres : $0 $*
#---------------------------------------------------------------------------------------------------------------------
function _Sortie
{	
  code_retour=$1
  if [ "$code_retour" != "0" ]
  then
    sujet="KO : Shell "$0" sur "$(hostname)
    corps="Code retour $code_retour - Commande executee : $0 $*"
  fi
exit $code_retour
}

