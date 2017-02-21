* PUNTO 1: Combine los archivos de datos para crear una base de datos que contenga todos los registros y variables del estudio. 
more

* Importar base de datos 1 de formato Excel
import excel "Base1.xls", sheet("base1") firstrow
more

* Guardar base de datos 1 en formato Stata
save "Base 1.dta"
more

clear
more

* Importar base de datos 2 de formato CSV
import delimited "Base2.csv"
more

* Guardar base de datos 2 en formato Stata
save "Base 2.dta"
more

clear
more

* Abrir base de datos 1 para usar como base de datos inicial
use "Base 1.dta"
more

* Unir las bases de datos 1 y 2 hacia abajo, usan el mismo formato de fechas
* Comando utilizado append
 append using "Base 2.dta"
 more
 
* Guardar nueva base de datos
save "Base pacientes.dta"
more

* Hago descripción de esta base para ver como quedo
describe
codebook 
more

* Voy a unir la base de datos 3 hacia el lado
* Contienen formatos de fecha diferentes pero se unificara el formato en el punto 5
* Comando merge, usando var1 como llave
merge 1:1 var1 using "Base3.dta"
more

describe 
more

* Guardar nueva base de datos "Base completa"
save "Base completa1.dta"
more

* FIN PUNTO 1
more

* PUNTO 2: Asigne nombres y rótulos a las variables en la base de datos
more

* Variable 1:
rename var1 Id
label variable Id "Número de identificación"
more

* Variable 2:
rename var2 sexo
label variable sexo "Sexo del paciente"
more

* Variable 3:
rename var3 dolortorax
label variable dolortorax "Tipo de dolor torácico"
more

* Variable 4:
rename var4 PAS
label variable PAS "Presión arterial sistólica (mmHg)"
more

* Variable 5:
rename var5 colesterol
label variable colesterol "Colesterol (mmHg)"
more

* Variable 6:
rename var6 EKG
label variable EKG "Resultado EKG en reposo"
more

* Variable 7:
rename var7 fecha_nac
label variable fecha_nac "Fecha de nacimiento (m/d/a)"
more

* Variable 8:
rename var8 enf_coronaria
label variable enf_coronaria "Estado de enf por angiografía"
more

* Variable 9:
rename var9 fecha_angio
label variable fecha_angio "Fecha angiografía coronaria"
more

* Quito la variable "_merge" creada al unir las bases de datos ya que no tendrá uso
drop _merge
more

* Se realizo descripción y se adjunta imagen al documento Word
describe 
more

* Se guarda la base de datos con modificaciones
save "Base completa1.dta", replace
more

*** FIN PUNTO 2
more

* PUNTO 3: Asigne rótulos a los valores de las variables categóricas
more

* Variable sexo:
label define sexo 1 "Masculino" 0 "Femenino"
label values sexo sexo
more

* Variable dolortoax (tipo de dolor tóracico)
label define dolor_torax 1 "Angina típica" 2 "Angina atípica" 3 "Dolor no anginoso" 4 "Asintomático"
label values dolortorax dolor_torax
more

* Variable EKG (resultado de electrocardiograma en reposo"
label define ekg 0 "Normal" 1 "Alteraciones ST-T" 2 "Hipertrofia v izquierda"
label values EKG ekg
more

* Variable enf_coronaria (estado de enfermedad coronaria por angiografia)
label define enf_coronaria 0 "< 50%" 1 ">50%"
label values enf_coronaria enf_coronaria
more

* Reviso como quedaron estas 4 variables con codigos
codebook sexo dolortorax EKG enf_coronaria
more

* Guardo la base de datos con los cambios realizados. No he realizado cambios en los datos, solamente en los rótulos, por lo cual considero que lo puedo guardar sobre el mismo archivo. 
save "Base completa1.dta", replace
more

*** FIN PUNTO 3
more

* PUNTO 4: Categorice la presión arterial sistólica deacuerdo a estas categorías:
* Hipotensión: <90 mmHg
* Tensión arterial normal: 90 - 119 mmHg **  Tome el primer rango del cuadro de referencia
* Prehipertensión: 120 - 139 mmHg ** Tome el primer rango del cuadro de referencia
* Hipertensión grado 1: 140 - 159 mmHg
* Hipertensión grado 2: 160 - 179 mmHg
* Crisis hipertensiva: >= 180 mmHg
more

* Primero reviso la variable PAS
codebook PAS 
*La variable PAS se encuentra en formato str3
more

* Debo convertir la variable PAS2 a una variable de tipo numerico
* Comando "destring"
destring PAS, generate(PAS2) force
more

* Reviso los valores string que se convirtieron en missing values
list Id PAS PAS2 if PAS2==.
more

* El valor correspondiente al Id 8617 "1o8" puedo convertirlo a 108 ya que puedo tener más seguridad de su valor origina
* Los valores 1A5 y NA se dejaran como missing values
replace PAS2 =108 if Id ==8617
list Id PAS PAS2 if PAS2==.
more

codebook PAS2
more

* Genero una nueva variable codificada
egen float PAS_cat = cut(PAS2), at(0 90 119 139 159 179 500) icodes
more

* Reviso que los valores se encuentren bien según los puntos de corte
sum PAS2
table PAS_cat, contents(min PAS2 max PAS2 )
* Nadie se encuentra en la categoría Hipotensión, los demás se encuentran bien clasificados
more

* Asigno rótulos a los valores de la variable PAS_cat
label define PAS 1 "PAS normal" 2 "Prehipertensión" 3 "HTA grado 1" 4 "HTA grado 2" 5 "Crisis hipertensiva"
label values PAS_cat PAS
more

tab PAS_cat
more

* Guardo la base de datos como nueva "Base completa 2"
save "Base completa2.dta"
more

*** FIN PUNTO 4
more

* PUNTO 5: Genere una variable que contenga la edad de los pacientes al momento de la angiografía coronaria
more

* Las variables fecha se encuentran en formatos diferentes a los identificados por stata

** Con base en la variable fecha_nac (mm/dd/yy), creo una variable en el formato fecha de stata
generate fecha_nac_cod=date(fecha_nac, "MDY")
format fecha_nac_cod %d
more

* Reviso la nueva variable
browse fecha_nac fecha_nac_cod
more

** Con base en la variable fecha_angio (dd/mm/yyyy) creo una variable en el formato fecha de stata
generate fecha_angio_cod=date(fecha_angio, "DMY")
format fecha_angio_cod %d
more

* Reviso la nueva variable
browse fecha_angio fecha_angio_cod
more

* Genero una nueva variable "edad_dias" (Edad en días al momento de la angiografía) 
gen edad_dias = fecha_angio_cod-fecha_nac_cod
more

* Genero una nueva variable "edad_años" (Edad en años al momento de la angiografía)
gen edad_años =  edad_dias/365.25
more 

* Reviso las variables
browse edad_dias edad_años
more

*Guardo nueva base de datos
save "BD Final.dta"

*** FIN PUNTO 5
more

* PUNTO 6: Describa los pacientes del estudio de acuerdo a la edad y sexo.
more 

* Distribución de los pacientes según el sexo
tab sexo
* El 32.3% de los pacientes pertenecen al género Femenino y 67.7 al género másculino. 
more

graph pie, over(sexo) plabel(_all percent) title(Distribución de los pacientes según el sexo)
more

* Distribución de la edad de los pacientes
sum edad_años
sum edad_años, d
* En promedio los pacientes tienen 54 años (SD 8.9), la menor edad encontrada es 29 años y la máxima es 77 años
more

histogram edad_años, bin(5) percent gap(10) addlabel ytitle(Porcentaje) xtitle(Edad (años)) title(Distribución Edad) 
more

* Distribución de la edad según el sexo
by sexo, sort : summarize edad_años
* En promedio las mujeres tienen 55 años de edad y los hombres 54 años. 
* No se registro el sexo de 3 pacientes.
more

graph box edad_años, over(sexo) ytitle(Edad (años)) title(Distribución de edad según sexo) 
more

*** FIN PUNTO 6
more

* PUNTO 7: Describa el diagnóstico de enfermedad coronaria de acuerdo al tipo de dolor torácico presentado
more

tabulate dolortorax enf_coronaria, row
more

*Interpretación:
* De los pacientes con angina típica el 69.6% tienen un estrechamiento <50% en la angiografía y el 30.4% mayor al 50%
* De los pacientes con angina atípica en el 81.2% se encontró un estrechamiento <50% y en el 18.8% mayor al 50%
* De los pacientes con dolor no anginoso en el 78.8% se encontró un estrechamiento <50% y en el 21.2% mayor al 50%
* De los pacientes asintomáticos el 26.6% tenían un estrechamiento <50% en la angiografía y en el 73.4% mayor al 50%
more

*** FIN PUNTO 7

*** FIN PARCIAL







 





