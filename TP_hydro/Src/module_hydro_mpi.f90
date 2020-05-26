module hydro_mpi

    use mpi
    use hydro_commons
    use hydro_const
    use hydro_parameters
    
    integer :: ierror, nproc, COMM_CART
    integer :: ndims = 2
    integer :: rankl, rankr, rankt, rankb, rank
    integer :: slabimin, slabimax, slabjmin, slabjmax
    integer, dimension(2) :: dimensions, coords = (/0,0/)
    logical, dimension(2) :: periods = (/.False. , .False./)

    integer :: countj, counti
    integer :: nneighbours
    integer, dimension(4,4) :: receivingdomain, sendingdomain
    integer, dimension(4) :: counts, ranks


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

        call init_surround

        call MPI_BARRIER(COMM_CART, ierrror)


    end subroutine init_mpi

    subroutine init_surround

        countj = ((slabjmax+2) - (slabjmin-2))*2
        counti = ((slabimax+2) - (slabimin-2))*2

        ! order : left, right, top, bottom
        receivingdomain = RESHAPE(&
            (/slabimin, slabimin+1, slabjmin+2, slabjmax-2,&
            slabimax-1, slabimax, slabjmin+2, slabjmax-2,&
            slabimin+2, slabimax-2, slabjmin, slabjmin+1,&
            slabimin+2, slabimax-2, slabimax-1, slabimax/),&
            (/4,4/),ORDER = (/2, 1/)&
        )

        sendingdomain = RESHAPE(&
            (/slabimin+2, slabimin+3, slabjmin+2, slabjmax-2,&
            slabimax-3, slabimax-2, slabjmin+2, slabjmax-2,&
            slabimin+2, slabimax-2, slabjmin+2, slabjmin+3,&
            slabimin+2, slabimax-2, slabjmax-3, slabjmax-2/),&
            (/4,4/),ORDER = (/2, 1/)&
        )

        counts = (/countj, countj, counti, counti/)
        ranks = (/rankl, rankr, rankt, rankb/)

    end subroutine init_surround

    subroutine get_surround

        use hydro_commons
        use hydro_const
        use hydro_parameters
        
        integer :: d
        integer ::  reqind = 1
        integer, dimension(32) :: requests
        integer :: requestA, requestB
        integer :: tmp

        requests(:) = MPI_REQUEST_NULL

        ! Iterate over 4 directions
        
        do d=1,4
            if (ranks(d) .NE. -1) then
                do ivar=1,nvar
                
                    print*,requests(reqind)

                    if (.false.) then
                    call MPI_IRECV(&
                        uold(&
                            receivingdomain(d,1):&
                            receivingdomain(d,2),&
                            receivingdomain(d,3):&
                            receivingdomain(d,4),&
                            ivar&
                        ),&
                        counts(d), MPI_DOUBLE,&
                        ranks(d), 1, COMM_CART, requests(reqind), ierror&
                    )

                    !requests(reqind) = 1

                    reqind = reqind + 1
                    
                    call MPI_ISEND(&
                        uold(&
                            sendingdomain(d,1):&
                            sendingdomain(d,2),&
                            sendingdomain(d,3):&
                            sendingdomain(d,4),&
                            ivar&
                        ),&
                        counts(d), MPI_DOUBLE,&
                        ranks(d), 1, COMM_CART, requests(reqind), ierror&
                    )

                    !requests(reqind) = 1

                    reqind = reqind + 1

                    end if

                    !call MPI_WAIT(requestA, MPI_STATUSES_IGNORE, ierror)
                

                end do
            end if
        end do

        call MPI_WAITALL(32, requests, MPI_STATUSES_IGNORE, ierror)
    
    end subroutine get_surround

    subroutine reduce
        ! do stuff
    end subroutine reduce

end module hydro_mpi
