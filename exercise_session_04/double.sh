if [ $# -eq 0 ]
	then
		echo "please specify input file"
else
	if [ -f $1 ]
		 then
			echo $1 exists
			while read line; do
				echo $line >> doubleOut.txt
				echo " " >> doubleOut.txt
			done < $1
	else
		echo $1 doesnt exist
	fi
fi


