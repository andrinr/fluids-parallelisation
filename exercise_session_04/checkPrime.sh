is_prime () {
  i=1
  root= bc -l <<< "sqrt($number)"
  root= bc -l <<< "($root+1.0)/1"  
  echo $root
  
  while [ $i -lt $root ]
  do
    i=$(( $i + 1 ))
    if test `expr $number % $i` -eq 0
    then
      echo not prime 
      return 0
    fi
  done
  echo is prime
  return 1
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
