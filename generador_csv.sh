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
    titulo=$1

    case "$titulo" in
        "Grandmaster")      echo "GM";;
        "International Master")     echo "IM";;
        "Fide Master")   echo "FM";;
        *) echo "";;
    esac
}


#Lectura del fichero
while IFS= read -r id_FIDE; do
    #echo "Hola"
    idFIDE=$(echo $id_FIDE | awk -F';' '{print $1}')
    URL="https://ratings.fide.com/profile/$idFIDE/calculations"
    curl -s $URL > $archivo_html

    #Obtencion de los datos
    titulo=$(awk -v RS="</div>" 'RT{gsub(/.*FIDE title:<\/div><div class="profile-top-info__block__row__data>/, "", RT); print RT}' "$archivo_html")

    #titulo=$(traducir_titulo $titulo)
    rating_std=$(cat $archivo_html | grep -A1 '<span class="profile-top-rating-dataDesc">std</span>' | tail -n 1 | awk -F'<' '{print $1}' | tr -d '[:space:]')
    rating_rapid=$(cat $archivo_html | grep -A1 '<span class="profile-top-rating-dataDesc">rapid</span>' | tail -n 1 | awk -F'<' '{print $1}' | tr -d '[:space:]')
    rating_blitz=$(cat $archivo_html | grep -A1 '<span class="profile-top-rating-dataDesc">blitz</span>' | tail -n 1 | awk -F'<' '{print $1}' | tr -d '[:space:]')
    apellidos_nombre=$(cat $archivo_html | grep '<div class="col-lg-8 profile-top-title">' | sed -n 's/.*>\(.*\)<\/div>/\U\1/p' | tr -d '\n' | tr -d ',' | sed 's/ *$//')
    
    #Escritura en el archivo CSV
    echo -e "$i,$apellidos_nombre,$idFIDE,$titulo,$rating_std,$rating_rapid,$rating_blitz" | tee -a ratings.csv
    let i+=1
done < $archivo_ids

rm $archivo_html