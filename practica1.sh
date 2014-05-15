#!/bin/bash

#primero calcular los dias del 1 de enero de 1970 hasta hoy
dia=`date +%s`
dia=$(($dia / 86400))

#se comprueba si no se le pasa parámetros

if [ $# -eq 0 ] 
then
	for i in `cat Shadow`
	do
		##Calculamos el Tiempo de Validez
		c3=`echo $i|cut -d ":" -f 3`
		c5=`echo $i|cut -d ":" -f 5`
		aux=$(($c5+$c3-0))
		if [ $dia -gt $aux ]
		then
			TV=0
		else
			TV=$(($c5+$c3-$dia))
		fi
		##Añadimos el nuevo campo a la variable que almacena Shadow
		cont=`echo "$cont$i:$cont1:$TV@"`
	done
	
	##	Mostramos Los campos de: usuario, UID, tiempo de validez y ##
	##	el tiempo que le queda antes de que el sistema avise de que #
	##	hay que cambiar la contraseña								#
	
	cont=`echo $cont|tr '@' '\n'`
	echo "--US equivale a usuario--"
	echo "--CP equivale a aviso de cambio de contraseña--"
	echo "--TV equivale a tiempo de validez--"
	echo "--UID equivale a ID de usuario--" 
	echo "US  CP  TV  UID"
	echo "$cont"|cut -d ":" -f1,6,11 > tmp.txt
	cat passwd|cut -d ":" -f3 >tmp1.txt
	paste -d ":" tmp.txt tmp1.txt|sort -nk 3 -t ":"
	rm tmp.txt && rm tmp1.txt
	echo " "
fi

###############################################
################## OPCIONAL####################
###############################################

#### Usuarios sin clave o con * o ! dentro de la clave ####

echo "Usuarios sin clave, con ! o * en dentro de la clave:"
echo " "
tr '*' '!' < Shadow > tmp.txt 
grep NP Shadow > usersnp.txt
cut -d ":" -f1 usersnp.txt
grep ! tmp.txt > usersnp.txt
cut -d ":" -f1 usersnp.txt
echo " "

for parametro in $*
do
	case $parametro in
	
	#################################################
	
	-shell) 
	if [ -shell = $1 ];
	then 
		nombreShell=$2
	elif [ -shell = $3 ];
	then
		nombreShell=$4
	elif [ -shell = $5 ];
	then 
		nombreShell=$6
	elif [ -shell = $7 ];
	then
		nombreShell=$8		
	fi
	grep $2 passwd > encontrado.txt
	echo "Usuarios que usan la shell $nombreShell:"
	cut -d":" -f1 encontrado.txt
	;;
	
	#################################################
	
	-no_shell) 
	if [ -no_shell = $1 ];
	then 
		nombreShell=$2
	elif [ -no_shell = $3 ];
	then
		nombreShell=$4
	elif [ -no_shell = $5 ];
	then 
		nombreShell=$6
	else 
		nombreShell=$8		
	fi	
	grep -v $2 passwd > noencontrado.txt
	echo "Usuarios que no usan la shell $nombreShel:"
	echo " "
	cut -d":" -f1 noencontrado.txt
	echo " "
	;;
	
	#################################################
	
	-day) 
	if [ -day = $1 ];
	then 
		N=$2
	elif [ -day = $3 ];
	then
		N=$4
	elif [ -day = $5 ];
	then 
		N=$6
	else 
		N=$8		
	fi
	for i in `cat Shadow`
	do
		
		c3=`echo $i|cut -d ":" -f 3`
		c5=`echo $i|cut -d ":" -f 5`
		
		## Comprobamos que el tiempo de validez no sea negativo
		## en caso de serlo lo igualamos a "0"
		
		#~ aux=$(($c5+$c3-0))
		#~ if [ $aux -gt $dia ]
		#~ then
			#~ TV=0
		#~ else
			#~ TV=$(($dia-($c5+$c3)))
		#~ fi
		
		aux=$(($c5+$c3-0))
		if [ $dia -gt $aux ]; then
			TV=0
		else
			 TV=$(($c5+$c3-$dia))
		fi
		#############################
		#############################
		#############################

		cont=`echo "$cont$i:$cont1:$TV@"`
	done
	
	## Se lista a todos los usuarios a los que les quedan
	## menos de N días de validez de contraseña.

	
	cont=`echo $cont|tr '@' '\n'`
	echo "$cont"|cut -d ":" -f1,11 > tmp.txt
		echo "Usuarios a los que les quedan menos de $N días de validez a su contraseña:"
		echo " "
	for i in `cat tmp.txt`
	do
		camp1=`echo $i|cut -d":" -f1`
		x=`echo $i|cut -d ":" -f2`
		if [ $N -gt $x ] 
		then
			echo "|-$camp1-|"
		fi
		
	done	
	echo " "
	;;
	
	###################################################
	################## OPCIONAL #######################
	###################################################
	
	-change) 
	if [ -change = $1 ];
	then 
		N=$2
	elif [ -change = $3 ];
	then
		N=$4
	elif [ -change = $5 ];
	then 
		N=$6
	else 
		N=$8		
	fi
	echo "Usuarios que han cambiado la contraseña antes de $N días:"
	echo " "
	for i in `cat Shadow`
	do
		camp3=`echo $i|cut -d ":" -f3`   ###camp3:días desde el 1 de enero del 1970 
		aux=$(($dia-$camp3))			 ###en que la contraseña fue cambiada 
		camp1=`echo $i|cut -d ":" -f1`	 ###por última vez.
	
		if [ $N -gt $aux ]
		then
			echo "|-$camp1-|"
		fi
		
	done	
	echo " "
	;;
	
	esac
done


