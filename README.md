<div align = "center">
    <h1>TablaRatingsFIDE</h1>
</div>

##### Autor:
 - César Lozano Argüeso -> [clozano03](https://github.com/CLozano03)

El script `generador_csv.sh` genera un archivo `.csv` con los datos FIDE de los jugadores pasados como argumento al programa: uno por línea.

##### Ejecución:
```
./src/generador_csv.sh <ruta_archivo_ids>
```

El archivo devuelto se llamará `ratings_sort.csv`y contendrá la siguiente cabecera:
*Num,Apellidos_Nombre,ID_FIDE,TITULO,STANDARD,RAPID,BLITZ*

Ejemplo de archivo de salida:
<div align = "center">
<img src="https://github.com/CLozano03/TablaRatingsFIDE/blob/main/assets/Resultados_Ratings_sort.jpg" width="750" height="200">
</div>
