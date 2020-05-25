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

        slabimin = coords(1) * nx+4 / dimensions(1)
        slabimax = (coords(1) + 1) * nx / dimensions(1) + 4

        slabjmin = coords(2) * ny / dimensions(2)
        slabjmax = (coords(2) + 1) * ny / dimensions(2) + 4
        
        if (rankr == -1) then
            slabimax = nx + 4
        end if

        if (rankt == -1) then 
            slabjmax = ny + 4
        end if

        print*, 'HYDRO_MPI.INIT_MPI || ', 'My rank is', rank , 'and my slab reaches from', slabimin, slabjmin, 'to', slabimax, slabjmax

        call MPI_BARRIER(COMM_CART, ierrror)


    end subroutine init_mpi

    subroutine get_surround
        if (rankl .NE. -1) then
            call MPI_IRECV( &
                uold(slabimin, slabjmin : slabjmax),&
                slabjmax - slabjmin,&
                MPI_DOUBLE,&
                rankl,&
                1,&
                COMM_CART,&
                requests(reqind + 1),&
                ierror&
            )
            call MPI_ISEND(&
                uold(imin+1, jmin : jmax),&
                jmax - jmin,&
                MPI_DOUBLE,&
                myleft,&
                1,&
                COMM_CART,&
                requests(reqind + 2),&
                ierror&
            )

        end if

        if (rankr .NE. -1) then
            
        end if

        if (rankt .NE. -1) then
            
        end if

        if (rankb .NE. -1) then
            
        end if
    end subroutine get_surround

end module hydro_mpi
