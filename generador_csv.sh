#!/bin/bash
# Genera un archivo CSV con los datos de los archivos de la carpeta actual

# Comprobacion del paso del archivo con los id
if [ $# -ne 1 ]; then
    echo "Error: Numero de parametros incorrecto"
    echo "Uso: $0 <archivo_id>"
    exit 1
fi

# Comprobacion de que el archivo existe
if [ ! -f $1 ]; then
    echo "Error: El archivo $1 no existe"
    exit 1
fi

archivo_ids=$1

# Variables globales
echo '' > html.tmp
archivo_html="html.tmp"
i=0

#Inicializacion del archivo CSV
echo "Num,Apellidos_Nombre,ID_FIDE,TITULO,STANDARD,RAPID,BLITZ" > ratings.csv

function traducir_titulo(){
    titulo_f=$1

    case "$titulo_f" in
        "GRANDMASTER")                  echo "GM" ;;
        "INTERNATIONALMASTER")          echo "IM" ;;
        "FIDEMASTER")                   echo "FM" ;;
        "CANDIDATEMASTER")              echo "CM" ;;
        "WOMANGRANDMASTER")             echo "WGM" ;;
        "WOMANINTERNATIONALMASTER")     echo "WIM" ;;
        "WOMANCANDIDATEMASTER")         echo "WCM" ;;
        "NONE")                         echo "";;
    esac
}


#Lectura del fichero
while IFS= read -r id_FIDE; do
    #echo "Hola"
    idFIDE=$(echo $id_FIDE | awk -F';' '{print $1}')
    URL="https://ratings.fide.com/profile/$idFIDE/calculations"
    curl -s $URL > $archivo_html

    #Obtencion de los datos
    titulo=$( cat $archivo_html | grep -A1 '<div class="profile-top-info__block__row__header">FIDE title:</div>' | awk -F'>|<' '{print $3}' | sed 's/FIDE title://g' | tr -d '\n' | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
    titulo=$(traducir_titulo $titulo)
    rating_std=$(cat $archivo_html | grep -A1 '<span class="profile-top-rating-dataDesc">std</span>' | tail -n 1 | awk -F'<' '{print $1}' | tr -d '[:space:]' | sed 's/Notrated/0/')
    rating_rapid=$(cat $archivo_html | grep -A1 '<span class="profile-top-rating-dataDesc">rapid</span>' | tail -n 1 | awk -F'<' '{print $1}' | tr -d '[:space:]' | sed 's/Notrated/0/')
    rating_blitz=$(cat $archivo_html | grep -A1 '<span class="profile-top-rating-dataDesc">blitz</span>' | tail -n 1 | awk -F'<' '{print $1}' | tr -d '[:space:]' | sed 's/Notrated/0/')
    apellidos_nombre=$(cat $archivo_html | grep '<div class="col-lg-8 profile-top-title">' | sed -n 's/.*>\(.*\)<\/div>/\U\1/p' | tr -d '\n' | tr -d ',' | sed 's/ *$//')
    
    #Escritura en el archivo CSV
    echo -e "$i,$apellidos_nombre,$idFIDE,$titulo,$rating_std,$rating_rapid,$rating_blitz" | tee -a ratings.csv
    let i+=1
done < $archivo_ids

rm $archivo_html