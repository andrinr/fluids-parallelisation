module hydro_mpi

    use mpi
    use hydro_commons
    use hydro_parameters
    
    integer :: ierror, nproc, COMM_CART
    integer :: ndims = 2
    integer :: rankl, rankr, rankt, rankb, rank
    integer, dimension(2) :: dimensions, coords = (/0,0/)
    logical, dimension(2) :: periods = (/.False. , .False./)


contains

    subroutine init_mpi
        
        call MPI_COMM_SIZE(MPI_COMM_WORLD, nproc, ierror)
        call MPI_DIMS_CREATE(nproc, ndims, dimensions, ierror)
        call MPI_CART_CREATE(MPI_COMM_WORLD, ndims, dimensions, periods, .True., COMM_CART, ierror)
        call MPI_COMM_RANK(COMM_CART, rank, ierror)
        call MPI_CART_COORDS(COMM_CART, rank, ndims, coords, ierror)

        print*, 'HYDRO_MPI.INIT_MPI || ', 'I am rank ', rank, ' of ', nproc

        call MPI_CART_SHIFT(COMM_CART, 0, 1, rankl, rankr, ierror)
        call MPI_CART_SHIFT(COMM_CART, 1, 1, rankb, rankt, ierror)

        print*, 'HYDRO_MPI.INIT_MPI || ', 'I communicate with :' , rankl, rankr, rankb, rankt

        print*, 'HYDRO_MPI.INIT_MPI || ', 'The entire domain ranges from: ', nx , 'to', ny

    end subroutine init_mpi

    subroutine end_mpi

    end subroutine end_mpi

end module hydro_mpi
