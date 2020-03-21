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
  integer :: my_rank, n_proc, ierror, i, total, neigh, left

  ! Begin MPI
  call MPI_INIT(ierror)
  
  ! Get my_rank and n_proc
  call MPI_COMM_RANK(MPI_COMM_WORLD, my_rank, ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, n_proc, ierror)

  do i = 0, n_proc, +1
     
    neigh = modulo(my_rank + 1,  n_proc)
    call MPI_SEND(my_rank, 1, MPI_INT, neigh, 1, MPI_COMM_WORLD, ierror)

    neigh = modulo(my_rank - 1, n_proc)
    call MPI_RECV(left, 1, MPI_INT, neigh, 1, MPI_COMM_WORLD, ierror, MPI_STATUS_IGNORE)

    total = total + left
  end do
 
  write(*,*) 'I am processor', my_rank,' out of ', n_proc,'and the sum is', total

 
  call MPI_FINALIZE (ierror)

end program ring
