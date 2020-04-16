!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -*- Mode: F90 -*- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! module_poisson_principal.f90 ---
!!!!
!! subroutine init_poisson
!! subroutine jacobi_step
!! subroutine init_f
!! subroutine init_exact
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module poisson_principal

contains

    subroutine init_poisson
        use poisson_commons
        use poisson_parameters
        use poisson_utils
        use poisson_mpi

        implicit none

        ! X axis
        if (boundary_left .eqv. .true.) then
            imin = mymin(1) - 1
        else
            imin = mymin(1)
        end if
        if (boundary_right .eqv. .true.) then
            imax = mymax(1) + 1
        else
            imax = mymax(1)
        end if
        ! Y axis
        if (boundary_down .eqv. .true.) then
            jmin = mymin(2) - 1
        else
            jmin = mymin(2)
        end if
        if (boundary_up .eqv. .true.) then
            jmax = mymax(2) + 1
        else
            jmax = mymax(2)
        end if

        dx = 1.0D+00 / real ( nx - 1, kind=prec_real)
        dy = 1.0D+00 / real ( ny - 1, kind=prec_real)

        ! initiliaze f, uexact, uold, unew
        allocate(f(imin:imax,jmin:jmax))
        call init_f

        allocate(uexact(imin:imax,jmin:jmax))
        call init_exact

        allocate(uold(imin:imax,jmin:jmax))
        allocate(unew(imin:imax,jmin:jmax))
        allocate(udiff(imin:imax,jmin:jmax))

        uold(imin:imax,jmin:jmax) = f(imin:imax,jmin:jmax)
        unew(imin:imax,jmin:jmax) = uold(imin:imax,jmin:jmax)

    end subroutine init_poisson

    subroutine jacobi_step
        use poisson_commons
        use poisson_parameters
        use poisson_utils
        use poisson_mpi

        !integer :: code
        real(kind=prec_real) :: localdiff = 0.0
        real(kind=prec_real) :: localerror = 0.0

        ! Save the current estimate.
        uold = unew

        !call halo

        ! Compute a new estimate.
        !print*,'I get there'
        do j = jmin, jmax
            do i = imin, imax
                if ( i == 1 .or. i == nx .or. j == 1 .or. j == ny ) then
                    unew(i,j) = f(i,j)
                else
                    unew(i,j) = 0.25 * ( uold(i-1,j) + uold(i,j+1) + uold(i,j-1) + uold(i+1,j) - f(i,j) * dx * dy )
                end if
            end do
        end do

        !print*,'and there'

        ! Compute difference and errors /!\ on the entire domain /!\
        ! The routine mat_norm2 returns the sum of the components squared of a matrix
        udiff = unew - uold
        localdiff = mat_norm2(udiff( imin : imax, jmin : jmax ))
        udiff = unew - uexact
        localerror = mat_norm2(udiff( imin: imax, jmin : jmax ))

        call MPI_ALLREDUCE(localdiff, diff, 1, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD, ierror)
        call MPI_ALLREDUCE(localerror, error, 1, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD, ierror)

        print*,'mine ', localdiff, ' global: ', diff
        print*,'mine ', localerror, ' global: ', error

        diff = sqrt (diff)
        error = sqrt (error)

        print*,'mine ', localdiff, ' global: ', diff
        print*,'mine ', localerror, ' global: ', error

    end subroutine jacobi_step

    subroutine init_f
        use poisson_commons
        use poisson_parameters
        use poisson_utils
        use poisson_mpi
        !
        !  The "boundary" entries of F will store the boundary values of the solution.
        !
        !  The "interior" entries of F store the source term
        !  of the Poisson equation.
        !

        do j = jmin, jmax
            y = real ( j - 1,kind=prec_real) / real ( ny - 1,kind=prec_real)
            do i = imin, imax
                x = real ( i - 1,kind=prec_real) / real ( nx - 1,kind=prec_real)
                if ( i == 1 .or. i == nx .or. j == 1 .or. j == ny ) then
                    f(i,j) = boundary(x,y)
                else
                    f(i,j) = source_term ( x, y )
                endif
            end do
        end do
    end subroutine init_f

    subroutine init_exact
        use poisson_commons
        use poisson_parameters
        use poisson_utils
        use poisson_mpi

        ! initialize exact solution (given the source function)
        do j = jmin, jmax
            y = real ( j - 1,kind=prec_real) / real ( ny - 1,kind=prec_real)
            do i = imin, imax
                x = real ( i - 1,kind=prec_real) / real ( nx - 1,kind=prec_real)
                uexact(i,j) = exact_solution ( x, y )
            end do
        end do
    end subroutine init_exact

end module poisson_principal
