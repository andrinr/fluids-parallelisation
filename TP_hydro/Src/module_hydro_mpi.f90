module hydro_mpi

    use mpi
    implicit none
    
    integer :: ierror, nproc, COMM_CART
    integer :: ndims = 2
    integer :: rankl, rankr, rankt, rankb, rank
    integer :: slabimin, slabimax, slabjmin, slabjmax = 0
    integer, dimension(2) :: dimensions, coords = (/0,0/)
    logical, dimension(2) :: periods = (/.FALSE. , .FALSE./)

    integer :: countj, counti
    integer :: nneighbours = 0
    integer, dimension(4,4) :: receivingdomain, sendingdomain
    integer, dimension(4) :: counts, ranks

    logical :: VERBOSE = .TRUE.


contains

    subroutine init_mpi

        use hydro_commons
        use hydro_parameters
        implicit none
        
        call MPI_COMM_SIZE(MPI_COMM_WORLD, nproc, ierror)
        call MPI_DIMS_CREATE(nproc, ndims, dimensions, ierror)
        call MPI_CART_CREATE(MPI_COMM_WORLD, ndims, dimensions, periods, .TRUE., COMM_CART, ierror)
        call MPI_COMM_RANK(COMM_CART, rank, ierror)
        call MPI_CART_COORDS(COMM_CART, rank, ndims, coords, ierror)

        print*, 'HYDRO_MPI.INIT_MPI || ', 'I am rank ', rank, ' of ', nproc, 'and my coords are', coords

        call MPI_CART_SHIFT(COMM_CART, 0, 1, rankl, rankr, ierror)
        call MPI_CART_SHIFT(COMM_CART, 1, 1, rankb, rankt, ierror)

        print*, 'HYDRO_MPI.INIT_MPI || ', 'I communicate with :' , rankl, rankr, rankb, rankt

        slabimin = coords(1) * nx / dimensions(1) + 1
        slabimax = (coords(1) + 1) * nx / dimensions(1) + 4

        slabjmin = coords(2) * ny / dimensions(2) + 1
        slabjmax = (coords(2) + 1) * ny / dimensions(2) + 4

        if (rankr == MPI_PROC_NULL) then
            slabimax = nx + 4
        end if

        if (rankt == MPI_PROC_NULL) then 
            slabjmax = ny + 4
        end if

        print*, 'HYDRO_MPI.INIT_MPI || ', 'rank', rank , 'slab', slabimin, slabjmin, 'to', slabimax, slabjmax

        call init_surround

        call MPI_BARRIER(COMM_CART, ierror)


    end subroutine init_mpi

    subroutine init_surround

        implicit none

        countj = ((slabjmax-2) - (slabjmin+2))*2+2
        counti = ((slabimax-2) - (slabimin+2))*2+2

        ! order : left, right, top, bottom
        receivingdomain = RESHAPE(&
            (/slabimin, slabimin+1, slabjmin+2, slabjmax-2,&
            slabimax-1, slabimax, slabjmin+2, slabjmax-2,&
            slabimin+2, slabimax-2, slabjmin, slabjmin+1,&
            slabimin+2, slabimax-2, slabjmax-1, slabjmax/),&
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

        print*,'HYDRO_MPI.INIT_SURROUND || proc', rank, 'sizes: ', counts(1), counts(2), counts(3), counts(4)

    end subroutine init_surround

    subroutine get_surround

        use hydro_commons
        use hydro_const
        use hydro_parameters
        implicit none
        
        ! Warning: initialisation only happens once !!
        integer :: d, ivar, reqind, tmp
        integer, dimension(8*nvar) :: request

        reqind = 0
        request = MPI_REQUEST_NULL

        ! Iterate over 4 directions
        
        do d=1,4
            if (ranks(d) .NE. MPI_PROC_NULL) then

                if (VERBOSE) then 
                    print*,'HYDRO_MPI.GET_SURROUND || proc', rank ,'comm with', ranks(d)

                    print*,'HYDRO_MPI.GET_SURROUND || proc', rank, 'receiving: ', receivingdomain(d,1), receivingdomain(d,2), receivingdomain(d,3), receivingdomain(d,4)
                    print*,'HYDRO_MPI.GET_SURROUND || proc', rank, 'sending: ', sendingdomain(d,1), sendingdomain(d,2), sendingdomain(d,3), sendingdomain(d,4)

                    print*,'HYDRO_MPI.GET_SURROUND || proc', rank, 'expected size: ', counts(d)

                    print*,'HYDRO_MPI.GET_SURROUND || proc', rank, 'actual size rec: ', SIZE(uold(&
                        receivingdomain(d,1):&
                        receivingdomain(d,2),&
                        receivingdomain(d,3):&
                        receivingdomain(d,4),&
                        1))

                    print*,'HYDRO_MPI.GET_SURROUND || proc', rank, 'actual size send: ', SIZE(uold(&
                        sendingdomain(d,1):&
                        sendingdomain(d,2),&
                        sendingdomain(d,3):&
                        sendingdomain(d,4),&
                        1))
                end if

                do ivar=1,nvar

                    !if (.FALSE.) then 

                    reqind = reqind + 1

                    call MPI_IRECV(&
                        uold(&
                            receivingdomain(d,1):&
                            receivingdomain(d,2),&
                            receivingdomain(d,3):&
                            receivingdomain(d,4),&
                            ivar&
                        ),&
                        counts(d), MPI_DOUBLE,&
                        ranks(d), 1, COMM_CART, request(reqind), ierror&
                    )

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
                        ranks(d), 1, COMM_CART, request(reqind), ierror&
                    )

                    !end if

                end do
            end if
        end do

        ! DEBUGING
        ! print*,size(request)
        ! print*,size(request(1:reqind))
        ! print*,reqind
        !do d=1,reqind
        !    print*,request(d)
        !end do
        ! DEBUGING

        !call MPI_WAITALL(32, request, MPI_STATUSES_IGNORE, ierror)
    
    end subroutine get_surround

end module hydro_mpi
