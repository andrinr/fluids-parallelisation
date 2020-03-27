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
    use poisson_mpi

    implicit none

    ! Itialize MPI environment
    call MPI_INIT(ierror)

    ! read parameters from input file
    call read_params
    ! initialize MPI domains
    call init_mpi
    ! initialize variables according to inputs
    call init_poisson
    ! output the exact solution
    call output_exact

    ! loop until error tolerance is satisfied
    do
        ! output approximate solution each noutput iterations
        if(MOD(nstep,noutput)==0) then
            if (myrank == 0) then 
                print*,'New step, nstep = ',nstep,', diff = ',diff,', error = ',error
            end if 
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
    
    if (myrank==0) then
        print*, 'Done'
    end if
    
    call MPI_FINALIZE(ierror)

end program poisson_main