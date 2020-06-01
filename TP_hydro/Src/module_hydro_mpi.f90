module hydro_mpi

    use mpi
    implicit none
    
    integer :: ierror, nproc, COMM_CART
    integer :: ndims = 2
    integer :: rankl, rankr, rankt, rankb, rank
    integer :: slabimin, slabimax, slabjmin, slabjmax = 0
    integer, dimension(2) :: dimensions, coords = (/0,0/)
    logical, dimension(2) :: periods = (/.FALSE. , .FALSE./)

    integer, dimension(4,4) :: receivingdomain, sendingdomain
    integer, dimension(4) :: receivingtypes, sendingtypes, ranks

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

        slabimin = 1
        slabimax = nx / dimensions(1) + 4

        slabjmin = 1
        slabjmax = ny / dimensions(2) + 4

        if (rankr == MPI_PROC_NULL) then
            slabimax = nx - (dimensions(1) -1) *  nx / dimensions(1) + 4
        end if

        if (rankt == MPI_PROC_NULL) then 
            slabjmax = ny - (dimensions(2) -1) *  ny / dimensions(2) + 4
        end if

        print*, 'HYDRO_MPI.INIT_MPI || ', 'rank', rank , 'slab', slabimin, slabjmin, 'to', slabimax, slabjmax

        call init_surround

        call MPI_BARRIER(COMM_CART, ierror)


    end subroutine init_mpi

    subroutine init_surround

        implicit none

        integer :: d

        ! order(x,:) : left, right, top, bottom
        ! order(:,x) : imin, imax, jmin, jmax
        receivingdomain = RESHAPE(&
            (/1, 2,                     3, slabjmax-2,&
            slabimax-1, slabimax,       3, slabjmax-2,&
            3, slabimax-2,              1, 2,&
            3, slabimax-2,              slabjmax-1, slabjmax/),&
            (/4,4/),ORDER = (/2, 1/)&
        )

        sendingdomain = RESHAPE(&
            (/3, 4,                     3, slabjmax-2,&
            slabimax-3, slabimax-2,     3, slabjmax-2,&
            3, slabimax-2,              3, 4,&
            3, slabimax-2,              slabjmax-3, slabjmax-2/),&
            (/4,4/),ORDER = (/2, 1/)&
        )

        ! create subarray dataypes because rows from a 2D array cannot be sent directly
        do d=1,4 
            call MPI_TYPE_CREATE_SUBARRAY(&
                2,(/slabimax,slabjmax/),&
                (/receivingdomain(d,2)-receivingdomain(d,1),receivingdomain(d,4)-receivingdomain(d,3)/),&
                (/receivingdomain(d,1),receivingdomain(d,3)/),&
                MPI_ORDER_FORTRAN, MPI_DOUBLE, receivingtypes(d), ierror&
            )
            call MPI_TYPE_CREATE_SUBARRAY(&
                2,(/slabimax,slabjmax/),&
                (/sendingdomain(d,2)-sendingdomain(d,1),sendingdomain(d,4)-sendingdomain(d,3)/),&
                (/sendingdomain(d,1),sendingdomain(d,3)/),&
                MPI_ORDER_FORTRAN, MPI_DOUBLE, sendingtypes(d), ierror&
            )

            call MPI_TYPE_COMMIT(receivingtypes(d), ierror)
            call MPI_TYPE_COMMIT(sendingtypes(d), ierror)
        end do

        ranks = (/rankl, rankr, rankt, rankb/)

    end subroutine init_surround

    subroutine get_surround(idim)

        use hydro_commons
        use hydro_const
        use hydro_parameters
        implicit none

        integer(kind=prec_int), intent(in) :: idim
        
        ! Warning: initialisation only happens once !!
        integer :: d, dstart, ivar, reqind, tmp
        integer, dimension(8*nvar) :: request

        reqind = 0
        request = MPI_REQUEST_NULL

        ! Iterate over 2 directions along axis

        if (idim == 1) then
            dstart = 1
        else
            dstart = 3
        end if

        do d=dstart,dstart+1
            if (ranks(d) .NE. MPI_PROC_NULL) then
                do ivar=1,nvar

                    reqind = reqind + 1

                    call MPI_IRECV(&
                        uold, 1, receivingtypes(d),&
                        ranks(d), 1, COMM_CART, request(reqind), ierror&
                    )

                    reqind = reqind + 1
                    
                    call MPI_ISEND(&
                        uold, 1, sendingtypes(d),&
                        ranks(d), 1, COMM_CART, request(reqind), ierror&
                    )

                end do
            end if
        end do

        call MPI_WAITALL(8*nvar, request, MPI_STATUSES_IGNORE, ierror)
    
    end subroutine get_surround

    subroutine end_mpi
        implicit none
    
        integer :: d

        do d=1,4 
            call MPI_TYPE_FREE(receivingtypes(d), ierror)
            call MPI_TYPE_FREE(sendingtypes(d), ierror)
        end do
    end subroutine end_mpi

end module hydro_mpi
