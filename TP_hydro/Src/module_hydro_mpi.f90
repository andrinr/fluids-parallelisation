module hydro_mpi

    use mpi
    integer :: ierror, nproc, myrank


contains

    subroutine init_mpi
        
        call MPI_COMM_SIZE(MPI_COMM_WORLD, nproc, ierror)
        call MPI_COMM_RANK(MPI_COMM_WORLD, myrank, ierror)

        print*, 'HYDRO_MPI.INIT_MPI || ', 'I am rank ', myrank, ' of ', nproc

    end subroutine init_mpi

    subroutine end_mpi

    end subroutine end_mpi

end module hydro_mpi
