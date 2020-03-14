is_prime () {
  for i in $(seq 2 $number) 
  do
    echo $i
    if test `expr $number % $i` -eq 0
    then
      echo not prime
      return 0
    fi
    echo is prime
    return 1
  done    
}

if [[ $# == 0 ]]
  then
    read -p "Enter number:" number
else
  number=$1
fi

if ! [[ $number =~ ^[0-9]+$ ]]
  then
    echo integers only!
else
  is_prime
fi
