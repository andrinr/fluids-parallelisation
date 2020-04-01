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
  integer :: source, dest, send_buf, recv_buf, sum, n
  integer, parameter :: tag_right = 87
  integer :: count = 1

  integer :: comm_old, ndims, COMM_CART
  integer :: req1, req2, code
  integer, dimension(MPI_STATUS_SIZE) :: status
  integer, dimension(2) :: dims

  logical, dimension(2) :: periods
  logical reorder

  ! can have new ranks
  reorder = .True.
  ! number of dimensions
  ndims = 1
  ! not sure?
  periods = (/ .True., .True. /)

  ! Init MPI environment
  call MPI_INIT(ierror)
  
  ! call MPI_COMM_RANK(MPI_COMM_WORLD, myrank, ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierror)
  call MPI_DIMS_CREATE(size, ndims, dims)
  call MPI_CART_CREATE(MPI_COMM_WORLD, ndims, dims, periods, reorder, COMM_CART, ierror)
  call MPI_COMM_RANK(COMM_CART, myrank, ierror)

  call MPI_CART_SHIFT(COMM_CART, 0, 1, source, dest, ierror)

  print*,'I am processor ',myrank,' out of ',size,' and my coord is ',dims
  ! Set first sending message: myrank
  send_buf = myrank

  ! Loop over number of processes
  do n = 0, size-1
    call MPI_IRECV( recv_buf, count, MPI_INTEGER, source, tag_right, MPI_COMM_WORLD, req1, code);
    call MPI_ISEND( send_buf, count, MPI_INTEGER, dest, tag_right, MPI_COMM_WORLD, req2, code);

    ! Update sending message and sum up the received rank
    call MPI_Wait(req1, status, code);
    call MPI_Wait(req2, status, code);

    send_buf = recv_buf
    sum = sum + recv_buf
  end do

  ! Final output
  print*,'I am processor ',myrank,' out of ',size,' and the sum is ',sum 

  ! Finalize MPI environment
  call MPI_FINALIZE (ierror)

end program ring