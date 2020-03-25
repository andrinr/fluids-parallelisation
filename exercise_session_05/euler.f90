!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!
!!    Skeleton program for Ex. 5.1:
!!    Rings and deadlocks
!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
program euler
  
  use mpi

  implicit none
  
  ! Variables declaration
  integer my_rank, n_proc, ierror
  integer N, part, rest, i, divisor, divisorTotal
  double precision subsum, total

  ! Variable initialisation
  total = 0.
  subsum = 1.
  divisor = 1
  divisorTotal = 1

  ! Begin MPI
  call MPI_INIT(ierror)
  
  ! Get my_rank and n_proc
  call MPI_COMM_RANK(MPI_COMM_WORLD, my_rank, ierror)c
  call MPI_COMM_SIZE(MPI_COMM_WORLD, n_proc, ierror)

  N = 1000000000
 
  IF (my_rank == 0) THEN
    part = N / n_proc

    do i = 1, n_proc-1, +1
      call MPI_SEND(part, 1, MPI_LONG_LONG_INT, i, 1, MPI_COMM_WORLD, ierror)
    end do

    rest = N - n_proc*part
  ELSE
    call MPI_RECV(part, 1, MPI_LONG_LONG_INT, 0, 1, MPI_COMM_WORLD, ierror, MPI_STATUS_IGNORE)
  END IF
  write(*,*) 'subsum: ', divisor, subsum, part
  do i = part*my_rank, part*(my_rank + 1), +1
    divisor = divisor * 1./i
    subsum = subsum + subsum * divisor
  end do

  write(*,*) 'subsum: ', subsum, 'current: ', divisor
  
  IF (my_rank == 0) THEN
    do i = 1, n_proc-1, +1
      call MPI_RECV(divisor, 1, MPI_LONG_LONG_INT , i, 1, MPI_COMM_WORLD, ierror, MPI_STATUS_IGNORE)
      divisorTotal = divisorTotal * divisor
      call MPI_RECV(subsum, 1, MPI_DOUBLE , i, 2, MPI_COMM_WORLD, ierror, MPI_STATUS_IGNORE)
      total = total + subsum * 1. / divisorTotal
    end do

    write(*,*) 'Euler approximation: ', total
  ELSE
    call MPI_SEND(divisor, 1, MPI_LONG_LONG_INT , 0, 1, MPI_COMM_WORLD, ierror)
    call MPI_SEND(subsum, 1, MPI_DOUBLE , 0, 2, MPI_COMM_WORLD, ierror)
  END IF

  call MPI_FINALIZE (ierror)

end program euler
