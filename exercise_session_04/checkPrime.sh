if !  [[ $1 =~ ^[0-9]+$ ]]
	then 
		echo integers only!
else
	for index in {2..$1}
	do
		echo "$index"
	done
fi
