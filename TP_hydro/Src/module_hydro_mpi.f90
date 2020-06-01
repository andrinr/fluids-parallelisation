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

        countj = (slabjmax-4)*2
        counti = (slabimax-4)*2

        ! order : left, right, top, bottom
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

        ! order : left, right, top, bottom
        !receivingdomain = RESHAPE(&
        !    (/1, 1, 3, 4,&
        !    1, 1, 3, 4,&
        !    1, 2, 3, 3,&
        !    1, 2, 3, 3/),&
        !    (/4,4/),ORDER = (/2, 1/)&
        !)
!
        !sendingdomain = RESHAPE(&
        !    (/1, 1, 3, 4,&
        !    1, 1, 3, 4,&
        !    1, 2, 3, 3,&
        !    1, 2, 3, 3/),&
        !    (/4,4/),ORDER = (/2, 1/)&
        !)

        counts = (/countj, countj, counti, counti/)
        !counts = (/2, 2, 2, 2/)
        ranks = (/rankl, rankr, rankt, rankb/)

    end subroutine init_surround

    subroutine get_surround(idim)

        use hydro_commons
        use hydro_const
        use hydro_parameters
        implicit none

        integer(kind=prec_int), intent(in) :: idim
        
        ! Warning: initialisation only happens once !!
        integer :: d, dstart, ivar, reqind, tmp, rowtype
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

                call check(d)

                if (idim == 1) then
                    call MPI_TYPE_VECTOR(2,counts(d),counts(d), MPI_DOUBLE, rowtype, ierror)
                else
                    call MPI_TYPE_VECTOR(counts(d),2,counts(d), MPI_DOUBLE, rowtype, ierror)
                end if

                call MPI_TYPE_COMMIT(rowtype, ierror)
                
                do ivar=1,nvar

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
                        RESHAPE(uold(&
                            sendingdomain(d,1):&
                            sendingdomain(d,2),&
                            sendingdomain(d,3):&
                            sendingdomain(d,4),&
                            ivar&
                        ),(/counts(d)/)),&
                        counts(d), MPI_DOUBLE,&
                        ranks(d), 1, COMM_CART, request(reqind), ierror&
                    )

                end do
            end if
        end do

        call MPI_WAITALL(8*nvar, request, MPI_STATUSES_IGNORE, ierror)
    
    end subroutine get_surround

    subroutine check(d)

        use hydro_commons
        use hydro_const
        use hydro_parameters
        implicit none

        integer, dimension(2) :: shapesending
        integer, dimension(2) :: shapereceiving
        integer, intent(in) :: d

        if (d == 1 .OR. d == 2) then
            print*,'x-dir'
        else
            print*,'y-dir'
        end if

        print*,nx,ny,slabimax,slabjmax
        print*,'HYDRO_MPI.GET_SURROUND || proc', rank, 'receiving: ',ranks(d),&
            receivingdomain(d,1), receivingdomain(d,2), receivingdomain(d,3), receivingdomain(d,4)
        print*,'HYDRO_MPI.GET_SURROUND || proc', rank, 'sending: ',ranks(d),&
            sendingdomain(d,1), sendingdomain(d,2), sendingdomain(d,3), sendingdomain(d,4)

        print*,SHAPE(uold) 

        shapesending = SHAPE(uold(&
            sendingdomain(d,1):&
            sendingdomain(d,2),&
            sendingdomain(d,3):&
            sendingdomain(d,4),&
        1))

        shapereceiving = SHAPE(uold(&
            receivingdomain(d,1):&
            receivingdomain(d,2),&
            receivingdomain(d,3):&
            receivingdomain(d,4),&
        1))


        if (shapereceiving(1) .NE. shapesending(1) .OR. shapereceiving(2) .NE. shapesending(2)) then
            print*,'HYDRO_MPI.CHECK || WARNING: shape mismatch'
        end if

        if (sendingdomain(d,2) > nx+4 .OR. sendingdomain(d,4) > ny+4) then
            print*,'HYDRO_MPI.CHECK || WARNING: sending max out of bounds'
            print*,'proc',rank,'exptected',sendingdomain(d,2),'actual',nx+4
            print*,'proc',rank,'exptected',sendingdomain(d,4),'actual',ny+4
        end if

        if (receivingdomain(d,2) > nx+4 .OR. receivingdomain(d,4) > ny+4) then
            print*,'HYDRO_MPI.CHECK || WARNING: receiving max out of bounds'
            print*,'proc',rank,'exptected',receivingdomain(d,2),'actual',nx+4
            print*,'proc',rank,'exptected',receivingdomain(d,4),'actual',ny+4
        end if

    end subroutine check


end module hydro_mpi
