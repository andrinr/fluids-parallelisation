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
  integer :: my_rank, n_proc, ierror
  INTEGER (KIND=8) N, part, rest, i
  COMPLEX (KIND=16) subsum, total, current

  ! Begin MPI
  call MPI_INIT(ierror)
  
  ! Get my_rank and n_proc
  call MPI_COMM_RANK(MPI_COMM_WORLD, my_rank, ierror)
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

  current = 1
  do i = part*my_rank, part*(my_rank + 1), +1
    current = current * 1. / i
    subsum = subsum + subsum * current
  end do
  
  IF (my_rank == 0) THEN
    do i = 1, n_proc-1, +1
      call MPI_RECV(current, 1, MPI_LONG_DOUBLE, i, 1, MPI_COMM_WORLD, ierror, MPI_STATUS_IGNORE)
      call MPI_RECV(subsum, 1, MPI_LONG_DOUBLE, i, 2, MPI_COMM_WORLD, ierror, MPI_STATUS_IGNORE)
      
       
    end do
  ELSE
    call MPI_SEND(current, 1, MPI_LONG_DOUBLE, 0, 1, MPI_COMM_WORLD, ierror)
    call MPI_SEND(subsum, 1, MPI_LONG_DOUBLE, 0, 2, MPI_COMM_WORLD, ierror)
  END IF

  write(*,*) subsum
 
  call MPI_FINALIZE (ierror)

end program euler
