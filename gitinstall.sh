#!/bin/bash

# Colores

blackcolour="\e[30m"
redcolour="\e[31m"
greencolour="\e[32m"
endcolour="\e[0m"
yellowcolour="\e[33m"
bluecolour="\e[34m"
pinkcolour="\e[35m"
ciancolour="\e[36m"
whitecolour="\033[1;37m"
graycolour="\e[90m"
purplecolour="\e[1;35m"

# ctrl+c

function ctrl_c(){
echo -e "\n\n${redcolour}[!]${endcolour} ${yellowcolour}Saliendo...${endcolour}\n\n"
tput cnorm && exit 1
}
trap ctrl_c INT

# Variables globales 

link=0
file=0
save=0
name=0
declare -i setup_while=0
code=none
respuesta=0
declare -i save_while=0
ComSave=0
declare -i quiet=0
err=0
declare -i more=0
declare -a total
declare -a valid_total

# Funciones 

function help(){
    echo -e "\n${redcolour}[+]${endcolour}${greencolour} -- Parametros del script --${endcolour}\n"
    echo -e "\t${redcolour}[-S]${endcolour}${yellowcolour} --setup${endcolour}${greencolour} Este parámetro crea los directorios que necesita el script para funcionar. Es necesario ejecutarlo primero como${endcolour}${yellowcolour} root.${endcolour}"
    echo -e "\t${redcolour}[-l]${endcolour}${yellowcolour} --link${endcolour}${greencolour} Enlace al repositorio de Github, el que pondrías en git clone.${endcolour}"
    echo -e "\t${redcolour}[-f]${endcolour}${yellowcolour} --file${endcolour}${greencolour} Directorio de corte (con cuál te quieres quedar. Si no pones nada, se instalará todo el repo)${endcolour}"
    echo -e "\t${redcolour}[-s]${endcolour}${yellowcolour} --save${endcolour}${greencolour} Donde quieres guardar el directorio. Si no pones nada, por defecto se guardará en: ${endcolour}${yellowcolour}/opt/gitinstall/repositories${endcolour}"
    echo -e "\t${redcolour}[-h]${endcolour}${yellowcolour} --help${endcolour}${greencolour} Abre el panel de ayuda.${endcolour}"
    echo -e "\t${redcolour}[-m]${endcolour}${yellowcolour} --more${endcolour}${greencolour} Permite tener varios directorios de corte. Si usas este parámetro, no uses el parámetro. ${endcolour}${yellowcolour}-f${endcolour} ${greencolour}Ni le añadas nada como argumento${endcolour}"
    echo -e "\t${redcolour}[-q]${endcolour}${yellowcolour} --quiet${endcolour}${greencolour} Solo reporta errores, no imprime nada más.${endcolour}"
    echo -e "\n${redcolour}[+]${endcolour}${greencolour} -- ¿Cómo funciona? --${endcolour}\n"
    echo -e "\t${redcolour}->${endcolour}${greencolour} primero el script descarga todo el repositorio que le indiques y lo guarda temporalmente en${endcolour}${yellowcolour} /opt/gitinstall/repositories ${endcolour}"
    echo -e "\t${redcolour}->${endcolour}${greencolour} por último mueve lo que le indiques al directorio que le indiques, borrando todo lo demás en el proceso.${endcolour}"
    echo -e "\n${redcolour}[+]${endcolour}${greencolour} -- Uso --${endcolour}\n"
    echo -e "\t${redcolour}->${endcolour}${greencolour} Antes de usarlo, ejecuta el script como ${endcolour}${yellowcolour}root${endcolour}${greencolour} con la opción ${endcolour}${yellowcolour}-S${endcolour}${greencolour} para que el script cree en ${endcolour}${yellowcolour}/opt${endcolour}${greencolour} los directorios que necesita para funcionar.${endcolour}"
    echo -e "\t${redcolour}->${endcolour}${greencolour} Ten en cuenta que, si quieres guardar un repositorio en un directorio en el que tu usuario no tiene permisos, tendrás que ejecutar el script como ${endcolour}${yellowcolour}root${endcolour}"
    echo -e "\t${redcolour}->${endcolour}${greencolour} Por ahora el script no interpreta espacios. Posiblemente lo arregle en un futuro.${endcolour}"
    echo -e "\n${redcolour}[+]${endcolour}${greencolour} -- Autor --${endcolour}\n"
    echo -e "\t${redcolour}->${endcolour}${greencolour} Script desarrollado por Jofunpe${endcolour}"
    echo -e "\t${redcolour}->${endcolour}${greencolour} https://jofunpe.com${endcolour}\n"
    tput cnorm
    exit 0
}

function more(){
#    echo "more"
    tput cnorm
    echo -en "\n${redcolour}[+]${endcolour}${greencolour} Cuáles son los directorios de corte que necesitas: ${endcolour}${bluecolour}" && read -a total
    echo -en "${endcolour}"
    while [ "${#total[@]}" -eq 0 ]; do
        if [ "${#total[@]}" -eq 0 ]; then 
            echo -en "\n${redcolour}[!]${endcolour}${greencolour} No pusiste ningún directorio. Vuelve a intentarlo: ${endcolour}${bluecolour}" && read -a total
            echo -en "${endcolour}"
        fi
    done 
    tput civis

    for i in "${total[@]}"; do
        if [[ "$i" == */* ]]; then
            err=$(find /opt/gitinstall/tmp -wholename "*$i") &>/dev/null
        else
            err=$(find /opt/gitinstall/tmp -name "$i") &>/dev/null
        fi
        if [ -n "$err" ]; then 
            valid_total+=("$i")
        fi
    done


#    echo "pusiste ${#valid_total[@]} y estos son los correctos: ${valid_total[@]}"

    for i in "${valid_total[@]}"; do
        if [ "$quiet" -eq 0 ]; then 
            echo -e "\n${redcolour}[+]${endcolour}${greencolour} moviendo repositorios...${endcolour}"
        fi
        mv /opt/gitinstall/tmp/$i "$ComSave" &>/dev/null
    done 
    rm -rf /opt/gitinstall/tmp/.* /opt/gitinstall/tmp/* &>/dev/null # No hace falta, pero por si acaso 
    echo -e "\n"
    tput cnorm
    exit 0
}

function setup(){
    if [ -e /opt/gitinstall ]; then 
        echo -en "${redcolour}[!]${endcolour}${greencolour} El directorio ${endcolour}${yellowcolour}/opt/gitinstall${greencolour} ya existe ¿Quiere reemplazarlo? -> ${endcolour}${bluecolour}" && read replace 
        echo -en "${endcolour}"
        replace=$(echo "$replace" | tr '[:upper:]' '[:lower:]')
            while [ "$setup_while" -eq 0 ]; do
#            echo "$replace"
            if [ "$replace" == y ] || [ "$replace" == ye ] || [ "$replace" == yes ] || [ "$replace" == s ] || [ "$replace" == si ]; then 
                rm -rf /opt/gitinstall 2>/dev/null
                code=$(echo "$?")
                mkdir /opt/gitinstall /opt/gitinstall/repositories /opt/gitinstall/tmp 2>/dev/null
                chmod 777 /opt/gitinstall 2>/dev/null
                chmod 777 /opt/gitinstall/repositories 2>/dev/null
                chmod 777 /opt/gitinstall/tmp
                if [ "$?" == 0 ]; then 
                    echo -e "\n${redcolour}[+]${endcolour} ${greencolour}Ya se ha reemplazado el directorio ${endcolour}${yellowcolour}/opt/gitinstall${endcolour}${greencolour} y se le dieron permisos a todos los usuarios.${endcolour}\n"
                    tput cnorm
                    exit 0
                else 
                    echo -e "\n${redcolour}[!]${endcolour} ${greencolour}para reemplazar el directorio ${yellowcolour}/opt/gitinstall${endcolour}${greencolour} Es necesario ejecutar el comando como ${endcolour}${yellowcolour}root${endcolour}\n"
                    tput cnorm
                    exit 1
                fi
            elif [ "$replace" == n ] || [ "$replace" == no ]; then
                setup_while=1
                tput cnorm
                exit 0
            else
                echo -en "${redcolour}[!]${endcolour}${greencolour} Respuesta no valida [Y/N] -> ${endcolour}${bluecolour}" && read replace 
                echo -en "${endcolour}"
                replace=$(echo "$replace" | tr '[:upper:]' '[:lower:]')
            fi
        done
    else
        mkdir /opt/gitinstall /opt/gitinstall/repositories /opt/gitinstall/tmp 2>/dev/null
        chmod 777 /opt/gitinstall 2>/dev/null
        chmod 777 /opt/gitinstall/repositories 2>/dev/null
        chmod 777 /opt/gitinstall/tmp
        if [ ! -e /opt/gitinstall ]; then 
            echo -e "\n${redcolour}[!]${endcolour} ${greencolour}para crear el directorio ${yellowcolour}/opt/gitinstall${endcolour}${greencolour} Es necesario ejecutar el comando como ${endcolour}${yellowcolour}root${endcolour}\n"
            tput cnorm
            exit 1
        else
            echo -e "\n${redcolour}[+]${endcolour} ${greencolour}Ya se creo el directorio ${endcolour}${yellowcolour}/opt/gitinstall${endcolour}${greencolour} y se le dieron permisos a todos los usuarios.${endcolour}\n"
            tput cnorm
            exit 0
        fi

    fi
}

# Script 

tput civis 
if [ "$1" == -h ] || [ "$2" == -h ] || [ "$3" == -h ] || [ "$4" == -h ] || [ "$5" == -h ] || [ "$6" == -h ] || [ "$7" == -h ] || [ "$8" == -h ] || # Menu help
   [ "$1" == --help ] || [ "$2" == --help ] || [ "$3" == --help ] || [ "$4" == --help ] || [ "$5" == --help ] || [ "$6" == --help ] || [ "$7" == --help ] || [ "$8" == --help ]; then 
    help
else
    :
fi

if [ "$1" == -q ] || [ "$2" == -q ] || [ "$3" == -q ] || [ "$4" == -q ] || [ "$5" == -q ] || [ "$6" == -q ] || [ "$7" == -q ] || [ "$8" == -q ] || # quiet
   [ "$1" == --quiet ] || [ "$2" == --quiet ] || [ "$3" == --quiet ] || [ "$4" == --quiet ] || [ "$5" == --quiet ] || [ "$6" == --quiet ] || [ "$7" == --quiet ] || [ "$8" == --quiet ]; then 
    quiet=1
fi

if [ "$1" == -m ] || [ "$2" == -m ] || [ "$3" == -m ] || [ "$4" == -m ] || [ "$5" == -m ] || [ "$6" == -m ] || [ "$7" == -m ] || [ "$8" == -m ] || # more directorios 
   [ "$1" == --more ] || [ "$2" == --more ] || [ "$3" == --more ] || [ "$4" == --more ] || [ "$5" == --more ] || [ "$6" == --more ] || [ "$7" == --more ] || [ "$8" == --more ]; then 
    more=1
fi

if [ "$1" == -S ] || [ "$2" == -S ] || [ "$3" == -S ] || [ "$4" == -S ] || [ "$5" == -S ] || [ "$6" == -S ] || [ "$7" == -S ] || [ "$8" == -S ] || # Menu setup
   [ "$1" == --setup ] || [ "$2" == --setup ] || [ "$3" == --setup ] || [ "$4" == --setup ] || [ "$5" == --setup ] || [ "$6" == --setup ] || [ "$7" == --setup ] || [ "$8" == --setup ]; then 
    setup
else
    :
fi

if [ "$1" == -l ] || [ "$2" == -l ] || [ "$3" == -l ] || [ "$4" == -l ] || [ "$5" == -l ] || [ "$6" == -l ] || [ "$7" == -l ] || [ "$8" == -l ] || # Menu help
   [ "$1" == --link ] || [ "$2" == --link ] || [ "$3" == --link ] || [ "$4" == --link ] || [ "$5" == --link ] || [ "$6" == --link ] || [ "$7" == --link ] || [ "$8" == --link ]; then 
    link=$(echo "$*" | sed -n 's/.*\(-l\|--link\)[[:space:]]\+\([^[:space:]]\+\).*/\2/p')
    if echo "$link" | grep -Eq '^(https?://)?(www\.)?(github\.com|gitlab\.com|bitbucket\.org|gitea\.com|codeberg\.org|sourceforge\.net)/[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+(\.git)?/?$'; then
        name=$(echo "$link" | sed -E 's#.*/([^/]+)(\.git)?#\1#') 
#        echo "$name"
    else
        echo -e "\n${redcolour}[!]${endcolour} ${greencolour}El enlace no es valido ${endcolour}\n"
        tput cnorm
        exit 1
    fi
else
    echo -e "\n${redcolour}[!]${endcolour} ${greencolour}Es necesario indicar el enlace del repositorio con ${endcolour}${yellowcolour}-l <link>${endcolour}\n"
    tput cnorm
    exit 1
fi
if [ "$more" -eq 0 ]; then 
    if [ "$1" == -f ] || [ "$2" == -f ] || [ "$3" == -f ] || [ "$4" == -f ] || [ "$5" == -f ] || [ "$6" == -f ] || [ "$7" == -f ] || [ "$8" == -f ] || # file
    [ "$1" == --file ] || [ "$2" == --file ] || [ "$3" == --file ] || [ "$4" == --file ] || [ "$5" == --file ] || [ "$6" == --file ] || [ "$7" == --file ] || [ "$8" == --file ]; then 
        file=$(echo "$*" | sed -n 's/.*\(-f\|--file\)[[:space:]]\+\([^[:space:]]\+\).*/\2/p')
    #    echo "$file"
    else 
        echo -e "\n${redcolour}[!]${endcolour}${greencolour} El repositorio se instalará entero, no indicaste la ruta de corte.${endcolour}"
    fi
fi

if [ "$1" == -s ] || [ "$2" == -s ] || [ "$3" == -s ] || [ "$4" == -s ] || [ "$5" == -s ] || [ "$6" == -s ] || [ "$7" == -s ] || [ "$8" == -s ] || # save
   [ "$1" == --save ] || [ "$2" == --save ] || [ "$3" == --save ] || [ "$4" == --save ] || [ "$5" == --save ] || [ "$6" == --save ] || [ "$7" == --save ] || [ "$8" == --save ]; then 
    save=$(echo "$*" | sed -n 's/.*\(-s\|--save\)[[:space:]]\+\([^[:space:]]\+\).*/\2/p')
#    echo "$save"
#   echo "$save/$name"
    if  [ -e "$save" ]; then 
        if [ -d "$save" ]; then 
            while [ "$save_while" -eq 0 ]; do
                if [ -e "$save/$name" ]; then 
                    tput cnorm
                    echo -en "${redcolour}[!]${endcolour}${greencolour} El fichero ${endcolour}${yellowcolour}$save/$name${endcolour}${greencolour} ya existe. Elija otra ruta para guardarlo (no añadas el nombre del repo al final, el script lo añade despues) -> ${endcolour}${bluecolour}" && read save
                    echo -en "${endcolour}"
                    tput civis
                else
                    if [ "$quiet" -eq 0 ]; then  
                        echo -e "\n${redcolour}[+]${endcolour} ${greencolour}el repositorio se gardará en: ${endcolour}${yellowcolour}"$save/$name"${endcolour}${greencolour}"
                    fi
                    ComSave=$save/$name
                    mkdir -p $ComSave &>/dev/null
                    save_while=1
                fi
            done
        else
            if [ ! -e "/opt/gitinstall/repositories/$name" ]; then 
                echo -e "\n${redcolour}[!]${endcolour}${yellowcolour} $save ${endcolour}${greencolour}No es un directorio. El repositorio se guardará en:${endcolour}${yellowcolour} /opt/gitinstall/repositories/$name${endcolour}"
                ComSave=/opt/gitinstall/repositories/$name
                mkdir -p $ComSave &>/dev/null
            else
                echo -e "\n${redcolour}[!]${endcolour} ${greencolour}No es un directorio. El repositorio se guardará en:${endcolour}${yellowcolour} /opt/gitinstall/repositories/${name}1${endcolour}"
                ComSave=/opt/gitinstall/repositories/${name}1
                mkdir -p $ComSave &>/dev/null
            fi
        fi
    elif [ -z "$save" ]; then 
        if [ ! -e "/opt/gitinstall/repositories/$name" ]; then 
            echo -e "\n${redcolour}[!]${endcolour} ${greencolour}No indicaste la ruta de guardado. el repositorio se guardará en:${endcolour}${yellowcolour} /opt/gitinstall/repositories/$name${endcolour}"
            ComSave=/opt/gitinstall/repositories/$name
            mkdir -p $ComSave &>/dev/null
        else 
            echo -e "\n${redcolour}[!]${endcolour} ${greencolour}No indicaste la ruta de guardado. el repositorio se guardará en:${endcolour}${yellowcolour} /opt/gitinstall/repositories/${name}1${endcolour}"
            ComSave=/opt/gitinstall/repositories/${name}1
            mkdir -p $ComSave &>/dev/null
        fi
    else 
        if [ ! -d "$save" ]; then 
            if [ "$quiet" -eq 0 ]; then
                echo -e "\n${redcolour}[+]${endcolour} ${greencolour}el repositorio se gardará en: ${endcolour}${yellowcolour}"$save/$name" ${endcolour}"
            fi
             ComSave=$save/$name
             mkdir -p $ComSave &>/dev/null
#             echo $ComSave
        fi
    fi
else
#    echo $name
    if [ ! -e "/opt/gitinstall/repositories/$name" ]; then 
        echo -e "\n${redcolour}[!]${endcolour} ${greencolour} No indicaste la ruta de guardado. el repositorio se guardará en:${endcolour}${yellowcolour} /opt/gitinstall/repositories/$name${endcolour}"
        ComSave=/opt/gitinstall/repositories/$name
        mkdir -p $ComSave &>/dev/null
    else
        echo -e "\n${redcolour}[!]${endcolour} ${greencolour} No indicaste la ruta de guardado. el repositorio se guardará en:${endcolour}${yellowcolour} /opt/gitinstall/repositories/${name}1${endcolour}"
        ComSave=/opt/gitinstall/repositories/${name}1
        mkdir -p $ComSave &>/dev/null
    fi
fi

rm -rf /opt/gitinstall/tmp/.* /opt/gitinstall/tmp/* &>/dev/null

if [ "$quiet" -eq 0 ]; then
    echo -e "\n${redcolour}[+]${endcolour}${greencolour} Instalando el repositorio...${endcolour}"
fi
git clone $link /opt/gitinstall/tmp &>/dev/null
if [ ! "$?" == 0 ]; then
    echo -e "\n${redcolour}[!]${endcolour}${greencolour} Hubo un error al instalar el repositorio: ${endcolour}${yellowcolour}$link${endcolour}"
    tput cnorm
    exit 1
else
    if [ "$quiet" -eq 0 ]; then
        echo -e "\n${redcolour}[+]${endcolour}${greencolour} Se ha instalado el repositorio: ${endcolour}${yellowcolour}$name${endcolour}"
    fi
fi

if [ "$more" -eq 1 ]; then 
    more
fi

if [[ "$file" == */* ]]; then 
    err=$(find /opt/gitinstall/tmp -wholename "*${file#/}" 2>/dev/null)
else
    err=$(find /opt/gitinstall/tmp -name "$file" 2>/dev/null)
fi 


if [ -z "$err" ]; then
    echo -e "\n${redcolour}[!]${endcolour}${greencolour} Ha habido un error al buscar${endcolour}${yellowcolour} $file${endcolour}${greencolour} en el repositorio. Se te ha descargado el repositorio entero.${endcolour}"
    file=0
fi

if [ "$file" == 0 ] || [ -z "$file" ]; then
    if [ "$quiet" -eq 0 ]; then
        echo -e "\n${redcolour}[+]${endcolour}${greencolour} Moviendo repositorios...${endcolour}"
    fi
    mv /opt/gitinstall/tmp/{*,.*} "$ComSave" &>/dev/null
    rm -rf /opt/gitinstall/tmp/.* /opt/gitinstall/tmp/* &>/dev/null # No hace falta, pero por si acaso
    if [ ! "$?" == 0 ]; then
        echo -e "\n${redcolour}[!]${endcolour}${greencolour} Hubo un error, ¿Ejecutaste la opción ${endcolour}${yellowcolour}-S ${endcolour}${greencolour}antes de usar el script? ${endcolour}"
    fi
else
    mv /opt/gitinstall/tmp/"$file" "$ComSave" &>/dev/null
    if [ ! "$?" == 0 ]; then 
        echo -e "\n${redcolour}[!]${endcolour}${greencolour} Hubo un error al mover el repositorio, actualmente está ubicado en: ${endcolour}${yellowcolour}/opt/gitinstall/tmp${endcolour}"
    fi
fi

tput cnorm
