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


  ! Setup local domain range : each process take care of a slab [myimin,myimax]x[1,ny]
  ! For example : nx=9, ny=6 with 3 processes
  !               rank 0 works with slab [1,3]x[1,6]
  !               rank 1 works with slab [4,6]x[1,6]
  !               rank 2 works with slab [7,9]x[1,6]
  ! The size of slabs in the x direction is stored in myn (myn=3 in this example)
  !
  !     | 0 | 0 | 0 || 1 | 1 | 1 || 2 | 2 | 2 |
  !     | 0 | 0 | 0 || 1 | 1 | 1 || 2 | 2 | 2 |
  !     | 0 | 0 | 0 || 1 | 1 | 1 || 2 | 2 | 2 |
  !     | 0 | 0 | 0 || 1 | 1 | 1 || 2 | 2 | 2 |
  !     | 0 | 0 | 0 || 1 | 1 | 1 || 2 | 2 | 2 |
  !     | 0 | 0 | 0 || 1 | 1 | 1 || 2 | 2 | 2 |
  !
  !
  ! I   : if nx/nproc is not integer, the last process can handle the remaining columns of the domain.
  ! II  : other option, the remaining columns of the domain can be shared between the processes.
  ! III : other (harder) approach : the domain could be decomposed in both x and y direction.

  print*, 'I am proc ',myrank,' and my x-domain goes from ',mymin(1),' to ',mymax(1)
  print*, 'I am proc ',myrank,' and my y-domain goes from ',mymin(2),' to ',mymax(2)
  
end subroutine init_mpi

end module poisson_mpi
