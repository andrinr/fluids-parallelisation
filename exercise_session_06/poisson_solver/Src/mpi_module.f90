module poisson_mpi
  
  use mpi

  implicit none
  integer, parameter :: tag = 123
  integer :: myrank, nproc, ierror, COMM_CART
  integer :: ndims = 2
  integer :: myleft, myright, mydown, myup
  integer :: myn, rest
  integer, dimension(2) :: dimensions, coords, mymin, mymax = (/0,0/)
  logical, dimension(2) :: periods = (/.True. , .True./)
  logical :: boundary_left, boundary_right, boundary_down, boundary_up
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
  call MPI_CART_SHIFT(COMM_CART, 1, 1, mydown, myup, ierror)

  boundary_right = .true.
  boundary_left = .true.
  boundary_down = .true.
  boundary_up = .true.

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
    myright = MPI_PROC_NULL
    mymax(1) = nx
  end if

  if (coords(2) == 0) then
    boundary_down = .false.
    ! Safe definition of neighbor rank : any communication will be ignored.
    mydown = MPI_PROC_NULL
  else  if (coords(2) == dimensions(2) - 1) then
    boundary_up = .false.
    ! Safe definition of neighbor rank : any communication will be ignored.
    myup = MPI_PROC_NULL
    mymax(2) = ny
  end if

  print*, 'I am proc ',myrank,' and my x-domain goes from ',mymin(1),' to ',mymax(1)
  print*, 'I am proc ',myrank,' and my y-domain goes from ',mymin(2),' to ',mymax(2)
  
end subroutine init_mpi

end module poisson_mpi
