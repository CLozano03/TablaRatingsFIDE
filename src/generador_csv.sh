#!/bin/bash
# Genera un archivo CSV con los datos FIDE de los id pasados como argumento

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

# Variables globales
touch "html.tmp"; touch "ratings.csv"; touch "ult_jug.tmp"
archivo_ids=$1
echo '' > html.tmp
archivo_html="html.tmp"; archivo_ratings="ratings.csv"; ult_jug="ult_jug.tmp"
i=1
n_cabeceras=3 #Lineas antes de empezar con los puntos en el .csv

fecha_formateada=$(date +"%e DE %B DE %Y" | tr '[:lower:]' '[:upper:]')

#Inicializacion del archivo CSV
echo ",ACTUALIZADO A: $fecha_formateada,,,DIAGONAL ALCORCON" > $archivo_ratings
echo "   " >> $archivo_ratings
echo "Num,Apellidos_Nombre,ID_FIDE,TITULO,STANDARD,RAPID,BLITZ,EQUIPO LIGA 23/24,Jugador no activo (3 meses)" >> $archivo_ratings

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

function jugador_activo(){
    archivo_activo="$1"
    activo=0
    mi_lista=("" "" "")
    
    # Bucle para std rapid blitz
    for i in {1..3}; do
        if [ $activo -eq 1 ]; then
                break;
        fi

        # Meses
        for j in {1..3}; do
            if [ $activo -eq 1 ]; then
                break;
            fi

            numero_linea=$((6 * (j - 1) + 2*i - 1))
            linea=$(sed -n "${numero_linea}p" "$archivo_activo")
            numero_=$(echo "$linea" | grep -oP '>&nbsp;\K\d+' | awk '{print $1}')
            if [ -z "$numero_" ]; then
                numero_=0
            fi

            if [ "$j" -eq 1 ]; then
                mi_lista[$((i - 1))]=$numero_
            elif [ "$numero_" -ne "${mi_lista[$((i - 1))]}" ]; then
                activo=1
                continue
            fi
        done
    done
    echo $activo
}

echo "Ejecutando..."

#Lectura del fichero
while IFS= read -r id_FIDE; do

    idFIDE=$(echo $id_FIDE | awk -F';' '{print $1}')
    URL="https://ratings.fide.com/profile/$idFIDE/chart"
    curl -s $URL > $archivo_html

    #Obtencion de los datos
    titulo=$(grep -A1 '<div class="profile-top-info__block__row__header">FIDE title:</div>' $archivo_html | awk -F'>|<' '{print $3}' | sed 's/FIDE title://g' | tr -d '\n' | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
    titulo=$(traducir_titulo $titulo)
    rating_std=$(grep -A1 '<span class="profile-top-rating-dataDesc">std</span>' $archivo_html  | tail -n 1 | awk -F'<' '{print $1}' | tr -d '[:space:]' | sed 's/Notrated/0/')
    rating_rapid=$(grep -A1 '<span class="profile-top-rating-dataDesc">rapid</span>' $archivo_html | tail -n 1 | awk -F'<' '{print $1}' | tr -d '[:space:]' | sed 's/Notrated/0/')
    rating_blitz=$(grep -A1 '<span class="profile-top-rating-dataDesc">blitz</span>' $archivo_html | tail -n 1 | awk -F'<' '{print $1}' | tr -d '[:space:]' | sed 's/Notrated/0/')
    apellidos_nombre=$(grep '<div class="col-lg-8 profile-top-title">' $archivo_html | sed -n 's/.*>\(.*\)<\/div>/\U\1/p' | tr -d '\n' | tr -d ',' | sed 's/ *$//')


    grep "<td valign" $archivo_html > $ult_jug

    # Comprobacion de si el jugador es activo
    activo=$(jugador_activo $ult_jug)

    if [ $activo -eq 1 ]; then
        activo=""       # El jugador es activo
    else
        activo="1"   # El jugador no es activo
    fi

    #Escritura en el archivo CSV
    echo -e "$i,$apellidos_nombre,$idFIDE,$titulo,$rating_std,$rating_rapid,$rating_blitz,,$activo" >> $archivo_ratings
    let i+=1
done < $archivo_ids

# Ordenado por rating
{ head -n $n_cabeceras $archivo_ratings; tail -n +$((n_cabeceras+1)) $archivo_ratings | sort -t, -k5,7 -r | awk 'BEGIN { FS=OFS=","; contador=0 } { $1=++contador; print; }'; } > ratings_sort.csv

# Borrar archivos temporales
rm $archivo_ratings; rm $archivo_html; rm $ult_jug

echo "Finalizado con exito"
exit 0
