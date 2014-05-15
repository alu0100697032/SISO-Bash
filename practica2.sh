#!/bin/bash

#######################

anyoact=`date "+%Y"`
mesact=`date "+%m"`
diaact=`date "+%d"`

ls -li *.*|sort -nk 6 > sizeord.txt
tr -s [:blank:] ' '  < sizeord.txt > p1.txt
cut -f1,2,3,4,6,7,9 -d " " p1.txt > p2.txt
cut -f6 -d" " p2.txt > p3.txt


for i in `cat p3.txt` 
do
	anyo=`echo $i|cut -d "-" -f1`
	mes=`echo $i|cut -d "-" -f2`
	dia=`echo $i|cut -d "-" -f3`

	anyomod=$(($anyoact-$anyo))
	mesmod=$(($mesact-$mes))
	diamod=$(($diaact-$dia))
	echo "$anyomod-$mesmod-$diamod" >> fechamod.txt

done

paste -d " " fechamod.txt p2.txt > compl.txt
cut -d" " -f1,2,3,4,5,6,8 compl.txt > final.txt
echo "---A,M,D indican año,mes y día respectivamente."
echo "---L indica el número de links." 
echo "---Owner indica el propietario."
echo "---T indica el tamaño del archivo"
echo "A M D I-Nodo Permisos	L Owner  T  Archivo"
grep lrwxrwxrwx -v final.txt
echo "Softlinks:"
grep lrwxrwxrwx final.txt > infosoft.txt
grep lrwxrwxrwx final.txt|cut -d" " -f7 > soft.txt

for i in `cat soft.txt`
do
	if [ ! -s "$i" ] 
	then
		echo "Roto" >> estadolink.txt
	else
		echo "Activo" >> estadolink.txt
	fi		
done

paste -d " " infosoft.txt estadolink.txt|sort -nk 6

######eliminar ficheros creados######
rm fechamod.txt
rm estadolink.txt
#####################################

#########################################
###############directorios###############
#########################################

##### ls -la ../../practicas1-2/######

ls -Rl */|grep /:|tr '/' ':'|tr ':' ' ' > colnomdir.txt

#########tamaño del directori##############

for i in `cat colnomdir.txt`
do
	dir=`echo $i`
	ls -l $dir/ > lsdir.txt
	tr -s [:blank:] ' ' < lsdir.txt > lsord.txt
	cut -d " " -f5 lsord.txt > tam.txt 
	grep : -v tam.txt > tamdef.txt
	for i in `cat tamdef.txt`
	do 
		aux=`echo $i`
		tam=$(($tam+$aux))
	
	done
	
	echo "$tam"	>> coltamdir.txt
	tam=0
done 

###########Numero de softlinks###############

for i in `cat colnomdir.txt`
do
	dir=`echo $i`
	ls -l $dir/ > lsdir.txt
	tr -s [:blank:] ' ' < lsdir.txt > lsord.txt
	cut -d " " -f1,8 lsord.txt > slink.txt 
	grep lrwxrwxrwx slink.txt|cut -d" " -f2 >> nomlink.txt	
done	
	cat nomlink.txt|wc |tr -s [:blank:] ' '|cut -d " " -f2|grep 0 -v > numlink.txt
	rm nomlink.txt

############Archivos con más de una instancia#########


for i in `cat colnomdir.txt`
do
	dir=`echo $i`
	ls -l $dir/ > lsdir.txt
	tr -s [:blank:] ' ' < lsdir.txt > lsord.txt
	grep total -v lsord.txt|cut -d " " -f2 > hard.txt 
	for i in `cat hard.txt`
	do
		aux=`echo $i`
		if [ $aux -gt 1 ]
		then
			echo "$aux" >> nhard.txt
		fi
	done
	
done


if [ -e "nhard.txt" ]
then
	cat nhard.txt |wc -l > colnumhard.txt
	rm nhard.txt
fi

echo "Directorios:"
echo " ND    TAM  SF HL"
paste -d " " colnomdir.txt coltamdir.txt numlink.txt colnumhard.txt|sort -nk 2 -t " "

rm coltamdir.txt
###################################
###################################
###################################
