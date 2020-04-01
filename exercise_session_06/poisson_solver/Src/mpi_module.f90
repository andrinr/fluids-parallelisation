module poisson_mpi
  
  use mpi

  implicit none
  integer, parameter :: tag = 123
  integer :: myrank, nproc, ierror
  integer :: ndims = 2
  integer :: myleft, myright
  integer :: myimin, myimax, myn, rest
  logical :: boundary_left, boundary_right
  
contains

subroutine init_mpi

  use poisson_parameters

  call MPI_COMM_SIZE(MPI_COMM_WORLD, nproc, ierror)
  call MPI_DIMS_CREATE(size, ndims, dims)
  call MPI_CART_CREATE(MPI_COMM_WORLD, ndims, dims, periods, reorder, COMM_CART, ierror)
  call MPI_COMM_RANK(COMM_CART, myrank, ierror)

  if (myrank==0) then
    print *
    print *,' MPI Execution with ',nproc,' processes'
    print *,' Starting time integration, nx = ',nx,' ny = ',ny
    print *
  endif

  !
  ! Setup ranks of left and right neighbors.
  ! If there is no neighbor in some <direction>,  boundary_<direction> must be .false.
  ! Otherwise, boundary_<direction> must be .true.
  ! 
  myleft = myrank - 1
  myright = myrank + 1
  boundary_right = .true.
  boundary_left = .true.
  
  if (myrank == 0) then
    boundary_left = .false.
    ! Safe definition of neighbor rank : any communication will be ignored.
    myleft = MPI_PROC_NULL
  else if (myrank == nproc-1) then
    boundary_right = .false.
    ! Safe definition of neighbor rank : any communication will be ignored.
    myright = MPI_PROC_NULL
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
  myimin=1
  myimax=1
  print*, 'I am proc ',myrank,' and my x-domain goes from ',myimin,' to ',myimax
  
end subroutine init_mpi

end module poisson_mpi
