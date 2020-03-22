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

  INTEGER (KIND = 8) N, part, rest, i
  ! Begin MPI
  call MPI_INIT(ierror)
  
  ! Get my_rank and n_proc
  call MPI_COMM_RANK(MPI_COMM_WORLD, my_rank, ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, n_proc, ierror)

  N = 1000000000
 
  IF (my_rank == 0) THEN
    part = N / n_proc
    rest = N - n_proc*part

    do i = 1, n_proc, +1
      call MPI_SEND(part, 1, MPI_LONG_LONG_INT, i, MPI_COMM_WORLD, ierror)
    end do
  ELSE
    call MPI_RECV(part, 1, MPI_LONG_LONG_INT, 0, MPI_COMM_WORLD, ierror)
  END IF

  write(*,*) part
 
  call MPI_FINALIZE (ierror)

end program euler
