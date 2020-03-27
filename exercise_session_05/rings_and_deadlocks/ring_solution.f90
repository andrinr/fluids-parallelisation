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

    ! Here I use odd/even method + synchronous mode to communicate
    if (mod(myrank,2) .eq. 0) then
      call MPI_SSEND(send_buf, count, MPI_INTEGER, right_rank, tag_right, MPI_COMM_WORLD, ierror)
      call MPI_RECV(recv_buf, count, MPI_INTEGER, left_rank, tag_right, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierror)
    else 
      call MPI_RECV(recv_buf, count, MPI_INTEGER, left_rank, tag_right, MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierror)
      call MPI_SSEND(send_buf, count, MPI_INTEGER, right_rank, tag_right, MPI_COMM_WORLD, ierror)  
    end if

    ! Update sending message and sum up the received rank
    send_buf = recv_buf
    sum = sum + recv_buf
  end do

  ! Final output
  print*,'I am processor ',myrank,' out of ',size,' and the sum is ',sum 

  ! Finalize MPI environment
  call MPI_FINALIZE (ierror)

end program ring