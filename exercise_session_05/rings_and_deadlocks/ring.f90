!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!
!!    Skeleton program for Ex. 5.1:
!!    Rings and deadlocks
!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
program ring
  
  use mpi

  implicit none
  
  ! Variables declaration
  integer :: my_rank, n_proc, ierror

  ! Begin MPI
  call MPI_INIT(ierror)
  
  ! Get my_rank and n_proc
  call MPI_COMM_RANK(MPI_COMM_WORLD, my_rank, ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, n_proc, ierror)
  

  write(*,*) 'I am processor ',my_rank,' out of ',n_proc

  call MPI_FINALIZE (ierror)

end program ring