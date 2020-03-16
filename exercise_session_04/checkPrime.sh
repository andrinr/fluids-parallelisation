is_prime () {
  
  if test `expr $number % 2` -eq 0
  then
    echo not prime, divisable by 2
    return 0
  fi

  if test `expr $number % 3` -eq 0
  then
    echo not prime, divisable by 3
    return 0
  fi

  i=1
  
  while [ $i -le  `expr $number / $i` ]
  do
    i=$(( $i + 6 ))
    if test `expr $number % $i` -eq 0
    then
      echo not prime, divisable by $i
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
