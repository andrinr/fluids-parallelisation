# HP EX6

## Andrin Rehmann

### exercise 1

```fortran
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
```

This solution is better, because it is non blocking and thus faster. Here all processors can send their rank at the same time, as opposed to the previous solution, where n/2 processors have sent their rank first and then others followed.

#### Bonus

```fortran
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
```

### exercise 3

#### Initialization

```fortran
module poisson_mpi
  
  use mpi

  implicit none
  integer, parameter :: tag = 123
  integer :: myrank, nproc, ierror, COMM_CART
  integer :: ndims = 2
  integer :: myleft, myright,  mybot, mytop
  integer :: myn, rest
  integer, dimension(2) :: dimensions, coords, mymin, mymax = (/0,0/)
  logical, dimension(2) :: periods = (/.True. , .True./)
  logical :: boundary_left, boundary_right, boundary_bot, boundary_top
  logical :: reorder = .true.

  
contains

subroutine init_mpi

  use poisson_parameters

  call MPI_COMM_SIZE(MPI_COMM_WORLD, nproc, ierror)
  call MPI_DIMS_CREATE(nproc, ndims, dimensions, ierror)
  call MPI_CART_CREATE(MPI_COMM_WORLD, ndims, dimensions, periods, reorder, COMM_CART, ierror)
  call MPI_COMM_RANK(COMM_CART, myrank, ierror)
  call MPI_CART_COORDS(COMM_CART, myrank, dimensions, coords, ierror)

  if (myrank==0) then
    print *
    print *,' MPI Execution with ',nproc,' processes'
    print *,' Cartesian grid of size ', dimensions
    print *,' Starting time integration, nx = ',nx,' ny = ',ny
    print *
  endif

  print *,'I am proc ',myrank,' and my coordinates are ', coords

  !
  ! Setup ranks of left and right neighbors.
  ! If there is no neighbor in some <direction>,  boundary_<direction> must be .false.
  ! Otherwise, boundary_<direction> must be .true.
  !
  call MPI_CART_SHIFT(COMM_CART, 0, 1, myleft, myright, ierror)
  call MPI_CART_SHIFT(COMM_CART, 1, 1, mybot, mytop, ierror)

  boundary_right = .true.
  boundary_left = .true.

  ! Default slab size
  mymin(1) = coords(1) * nx / dimensions(1)
  mymin(2) = coords(2) * ny / dimensions(2)

  mymax(1) = ( 1 + coords(1) ) * nx / dimensions(1) - 1
  mymax(2) = ( 1 + coords(2) ) * ny / dimensions(2) - 1

  if (coords(1) == 0) then
    boundary_left = .false.
    ! Safe definition of neighbor rank : any communication will be ignored.
    myleft = MPI_PROC_NULL
  else if (coords(1) == dimensions(1) - 1) then
    boundary_right = .false.
    ! Safe definition of neighbor rank : any communication will be ignored.
    mytop = MPI_PROC_NULL
    mymax(1) = nx
  end if

  if (coords(2) == 0) then
    boundary_bot = .false.
    ! Safe definition of neighbor rank : any communication will be ignored.
    mybot = MPI_PROC_NULL
  else  if (coords(2) == dimensions(2) - 1) then
    boundary_right = .false.
    ! Safe definition of neighbor rank : any communication will be ignored.
    mytop = MPI_PROC_NULL
    mymax(2) = ny
  end if

  print*, 'I am proc ',myrank,' and my x-domain goes from ',mymin(1),' to ',mymax(1)
  print*, 'I am proc ',myrank,' and my y-domain goes from ',mymin(2),' to ',mymax(2)
  
end subroutine init_mpi

end module poisson_mpi
```



