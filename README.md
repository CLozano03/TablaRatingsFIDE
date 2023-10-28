## TablaRatingsFIDE

El script `generador_csv.sh` genera un archivo `.csv` con los datos FIDE de los jugadores pasados como argumento al programa: uno por linea.

***Ejecución:***
```
./generador_csv.sh <archivo_ids>
```

El archivo devuelto se llamará `ratings_sort.csv`y contendrá la siguiente cabecera:
*Num,Apellidos_Nombre,ID_FIDE,TITULO,STANDARD,RAPID,BLITZ*

Ejemplo de archivo de salida:
<div align = "center">
<img src="https://github.com/CLozano03/TablaRatingsFIDE/blob/main/assets/Resultados_Ratings_Sort.jpg" width="600" height="200">
</div>