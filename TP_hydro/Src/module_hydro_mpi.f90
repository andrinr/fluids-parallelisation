module hydro_mpi

    use mpi
    use hydro_commons
    use hydro_parameters
    
    integer :: ierror, nproc, COMM_CART
    integer :: ndims = 2
    integer :: rankl, rankr, rankt, rankb, rank
    integer :: slabimin, slabimax, slabjmin, slabjmax
    integer, dimension(2) :: dimensions, coords = (/0,0/)
    logical, dimension(2) :: periods = (/.False. , .False./)


contains

    subroutine init_mpi
        
        call MPI_COMM_SIZE(MPI_COMM_WORLD, nproc, ierror)
        call MPI_DIMS_CREATE(nproc, ndims, dimensions, ierror)
        call MPI_CART_CREATE(MPI_COMM_WORLD, ndims, dimensions, periods, .True., COMM_CART, ierror)
        call MPI_COMM_RANK(COMM_CART, rank, ierror)
        call MPI_CART_COORDS(COMM_CART, rank, ndims, coords, ierror)

        print*, 'HYDRO_MPI.INIT_MPI || ', 'I am rank ', rank, ' of ', nproc, 'and my coords are', coords

        call MPI_CART_SHIFT(COMM_CART, 0, 1, rankl, rankr, ierror)
        call MPI_CART_SHIFT(COMM_CART, 1, 1, rankb, rankt, ierror)

        print*, 'HYDRO_MPI.INIT_MPI || ', 'I communicate with :' , rankl, rankr, rankb, rankt

        slabimin = coords(1) * nx / dimensions(1)
        slabimax = (coords(1) + 1) * nx / dimensions(1)

        slabjmin = coords(2) * ny / dimensions(2)
        slabjmax = (coords(2) + 1) * ny / dimensions(2)
        
        if (rankr == -1) then
            slabimax = nx
        end if

        if (rankt == -1) then 
            slabjmax = ny
        end if

        print*, 'HYDRO_MPI.INIT_MPI || ', 'My rank is', rank , 'and my slab reaches from', slabimin, slabjmin, 'to', slabimax, slabjmax

        call MPI_BARRIER(COMM_CART, ierrror)


    end subroutine init_mpi

    subroutine end_mpi

    end subroutine end_mpi

end module hydro_mpi
