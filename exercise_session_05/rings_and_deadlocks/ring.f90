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
  integer :: my_rank, n_proc, ierror, i, total, neigh, send, receive

  ! Begin MPI
  call MPI_INIT(ierror)
  
  ! Get my_rank and n_proc
  call MPI_COMM_RANK(MPI_COMM_WORLD, my_rank, ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, n_proc, ierror)

  total = my_rank
  send = my_rank
  
  do i = 0, n_proc, +1
    IF (modulo(my_rank, 2) == 0) THEN
      neigh = modulo(my_rank + 1,  n_proc)
      call MPI_SEND(send, 1, MPI_INT, neigh, 1, MPI_COMM_WORLD, ierror)

      neigh = modulo(my_rank - 1, n_proc)
      call MPI_RECV(receive, 1, MPI_INT, neigh, 1, MPI_COMM_WORLD, ierror, MPI_STATUS_IGNORE)
    ELSE
      neigh = modulo(my_rank - 1, n_proc)
      call MPI_RECV(receive, 1, MPI_INT, neigh, 1, MPI_COMM_WORLD, ierror, MPI_STATUS_IGNORE)
      
      neigh = modulo(my_rank + 1,  n_proc)
      call MPI_SEND(send, 1, MPI_INT, neigh, 1, MPI_COMM_WORLD, ierror)

    END IF
    write(*,*) 'rank', my_rank, 'sent: ', send, 'and received: ', receive

    total = total + receive
    send = receive

  end do
 
  write(*,*) 'I am processor', my_rank,' out of ', n_proc,'and the sum is', total

 
  call MPI_FINALIZE (ierror)

end program ring
