module hydro_mpi

    use mpi
    use hydro_commons
    use hydro_const
    use hydro_parameters
    implicit none
    
    integer :: ierror, nproc, COMM_CART
    integer :: ndims = 2
    integer :: rankl, rankr, rankt, rankb, rank
    integer :: slabimin, slabimax, slabjmin, slabjmax = 0
    integer, dimension(2) :: dimensions, coords = (/0,0/)
    logical, dimension(2) :: periods = (/.FALSE. , .FALSE./)

    integer, dimension(4,4) :: receivingdomain, sendingdomain
    integer, dimension(4,8) :: receivingtypes, sendingtypes
    integer, dimension(4) :: ranks

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

        call MPI_CART_SHIFT(COMM_CART, 0, 1, rankl, rankr, ierror)
        call MPI_CART_SHIFT(COMM_CART, 1, 1, rankb, rankt, ierror)

        print*, 'HYDRO_MPI.INIT_MPI || ', 'I am rank ', rank, ' of ', nproc, 'and I communicate with', rankl, rankr, rankb, rankt

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

        call init_surround

        call MPI_BARRIER(COMM_CART, ierror)


    end subroutine init_mpi

    subroutine init_surround

        use hydro_commons
        use hydro_const
        use hydro_parameters
        implicit none

        integer :: d, ivar

        ranks = (/rankl, rankr, rankt, rankb/)

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
            if (ranks(d) .NE. MPI_PROC_NULL) then
                do ivar=1,nvar

                    !print*,'######'
                    !print*,rank, ranks(d), d
                    !print*,(/slabimax,slabjmax,nvar/)
                    !print*,(/receivingdomain(d,2)-receivingdomain(d,1)+1,receivingdomain(d,4)-receivingdomain(d,3)+1,1/)
                    !print*,(/receivingdomain(d,1)-1,receivingdomain(d,3)-1,ivar-1/)
                    
                    call MPI_TYPE_CREATE_SUBARRAY(&
                        3,(/slabimax,slabjmax,nvar/),& ! ndims, arraysize
                        (/receivingdomain(d,2)-receivingdomain(d,1)+1,receivingdomain(d,4)-receivingdomain(d,3)+1,1/),& ! subarray size
                        (/receivingdomain(d,1)-1,receivingdomain(d,3)-1,ivar-1/),& ! subarray start
                        MPI_ORDER_FORTRAN, MPI_DOUBLE, receivingtypes(d,ivar), ierror&
                    )

                    call MPI_TYPE_COMMIT(receivingtypes(d,ivar), ierror)

                    call MPI_TYPE_CREATE_SUBARRAY(&
                        3,(/slabimax,slabjmax,nvar/),& ! ndims, arraysize
                        (/sendingdomain(d,2)-sendingdomain(d,1)+1,sendingdomain(d,4)-sendingdomain(d,3)+1,1/),& ! subarray size
                        (/sendingdomain(d,1)-1,sendingdomain(d,3)-1,ivar-1/),& ! subarray start
                        MPI_ORDER_FORTRAN, MPI_DOUBLE, sendingtypes(d,ivar), ierror&
                    )

                    call MPI_TYPE_COMMIT(sendingtypes(d,ivar), ierror)
                end do
            end if
        end do

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

        ! Iterate over 2 directions along specified axis

        if (idim == 1) then
            dstart = 1
        else
            dstart = 3
        end if

        ! iterate over two directions in current axis
        do d=dstart,dstart+1
            ! check if neighbour is not border
            if (ranks(d) .NE. MPI_PROC_NULL) then
                ! iterate over all layers
                do ivar=1,nvar

                    reqind = reqind + 1

                    call MPI_IRECV(&
                        uold, 1, receivingtypes(d,ivar),&
                        ranks(d), 1, COMM_CART, request(reqind), ierror&
                    )

                    reqind = reqind + 1
                    
                    call MPI_ISEND(&
                        uold, 1, sendingtypes(d,ivar),&
                        ranks(d), 1, COMM_CART, request(reqind), ierror&
                    )

                end do
            end if
        end do

        call MPI_WAITALL(8*nvar, request, MPI_STATUSES_IGNORE, ierror)
    
    end subroutine get_surround

    subroutine end_mpi
        implicit none
    
        integer :: d, ivar

        do d=1,4 
            do ivar=1,nvar
                call MPI_TYPE_FREE(receivingtypes(d,ivar), ierror)
                call MPI_TYPE_FREE(sendingtypes(d,ivar), ierror)
            end do
        end do
    end subroutine end_mpi

end module hydro_mpi