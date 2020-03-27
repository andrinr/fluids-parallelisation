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
  do n = 0, size-1
    call MPI_IRECV( recv_buf, count, MPI_INTEGER, left_rank, tag_right, MPI_COMM_WORLD, req1, code);
    call MPI_ISEND( send_buf, count, MPI_INTEGER, right_rank, tag_right, MPI_COMM_WORLD, req2, code);

    ! Update sending message and sum up the received rank
    call MPI_Wait(req1, status, code);
    call MPI_Wait(req2, status, code);
    print*,recv_buf, send_buf
    send_buf = recv_buf
    sum = sum + recv_buf
  end do

  ! Final output
  print*,'I am processor ',myrank,' out of ',size,' and the sum is ',sum 

  ! Finalize MPI environment
  call MPI_FINALIZE (ierror)

end program ring