!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!
!!    Solution for Ex. 5.1:
!!    Rings and deadlocks
!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

program ring
  
  use mpi

  implicit none
  
  ! Declaration of variables
  integer :: myrank, size, ierror
  integer :: left_rank, right_rank, send_buf, recv_buf, sum, n
  integer, parameter :: tag_right = 87
  integer :: count = 1

  integer :: req1, req2, code;
  integer, dimension(MPI_STATUS_SIZE) :: status;
  
  ! Init MPI environment
  call MPI_INIT(ierror)
  
  call MPI_COMM_RANK(MPI_COMM_WORLD, myrank, ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierror)

  ! Compute rank of neighbors
  right_rank = mod(myrank+1, size)
  left_rank = mod(myrank-1+size, size)

  ! Set first sending message: myrank
  send_buf = myrank

  ! Loop over number of processes
  call MPI_ALLREDUCE(send_buf, sum, 1, MPI_INTEGER, MPI_SUM, MPI_COMM_WORLD, code);

  ! Final output
  print*,'I am processor ',myrank,' out of ',size,' and the sum is ',sum 

  ! Finalize MPI environment
  call MPI_FINALIZE (ierror)

end program ring