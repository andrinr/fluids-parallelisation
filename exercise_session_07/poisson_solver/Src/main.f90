!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -*- Mode: F90 -*- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! main.f90 --- 
!!!!
!! program poisson_main
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

program poisson_main
    use poisson_commons
    use poisson_parameters
    use poisson_IO
    use poisson_principal
    !$ use OMP_LIB

    implicit none

    real :: start_time, stop_time, elapsed
    integer :: nproc, iter

    ! read parameters from input file
    call read_params

    do iter = 1, 4
        diff=0.0
        error=0.0
        nx = nx * iter
        ny = ny * iter
        print*,'Starting integration, nx = ',nx,' ny = ',ny

        ! initialize variables according to inputs
        call init_poisson
        ! output the exact solution
        call output_exact

        call cpu_time(start_time)

        ! loop until error tolerance is satisfied
        do
            ! output approximate solution each noutput iterations
            if(MOD(nstep,noutput)==0)then
                print*,'New step, nstep = ',nstep,', diff = ',diff,', error = ',error
                call output
            end if

            ! use jacobi solver
            call jacobi_step
            nstep = nstep + 1

            ! check tolerance
            if ( diff <= tolerance ) then
                converged = .true.
                exit
            end if
        end do

        call cpu_time(stop_time)
        elapsed = stop_time - start_time
        nproc = OMP_GET_NUM_THREADS()

        print*,'nproc: ', nproc, ' elapsed: ', elapsed
        call timing(elapsed, nproc)
    end do


end program poisson_main