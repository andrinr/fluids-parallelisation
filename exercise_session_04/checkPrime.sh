if !  [[ $1 =~ ^[0-9]+$ ]]
	then 
		echo integers only!
else
  END=$1
	for index in {2..$END}
	do
		echo $index
	done

fi
