# HP EX4

## Andrin Rehmann

### Exercise 1

My program somehow generates a Deadlock, not sure why. 

The first thread could add up all the ranks and then broadcast it to all others, we could use a divide and conquer algorithm, such that the threat, which has to do the maximum number of additions, only needs to perform O(log(n_ranks)) instead of O(n).



```fortran
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!
!!    Skeleton program for Ex. 5.1:
!!    Rings and deadlocks
!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
program ring
  
  use mpi

  implicit none
  
  ! Variables declaration
  integer :: my_rank, n_proc, ierror, i, total, neigh, send, receive

  ! Begin MPI
  call MPI_INIT(ierror)
  
  ! Get my_rank and n_proc
  call MPI_COMM_RANK(MPI_COMM_WORLD, my_rank, ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, n_proc, ierror)

  total = my_rank
  send = my_rank
  
  do i = 0, n_proc, +1
    IF (modulo(my_rank, 2) == 0) THEN
      neigh = modulo(my_rank + 1,  n_proc)
      call MPI_SEND(send, 1, MPI_INT, neigh, 1, MPI_COMM_WORLD, ierror)

      neigh = modulo(my_rank - 1, n_proc)
      call MPI_RECV(receive, 1, MPI_INT, neigh, 1, MPI_COMM_WORLD, ierror, MPI_STATUS_IGNORE)
    ELSE
      neigh = modulo(my_rank - 1, n_proc)
      call MPI_RECV(receive, 1, MPI_INT, neigh, 1, MPI_COMM_WORLD, ierror, MPI_STATUS_IGNORE)
      
      neigh = modulo(my_rank + 1,  n_proc)
      call MPI_SEND(send, 1, MPI_INT, neigh, 1, MPI_COMM_WORLD, ierror)

    END IF
    write(*,*) 'rank', my_rank, 'sent: ', send, 'and received: ', receive

    total = total + receive
    send = receive

  end do
 
  write(*,*) 'I am processor', my_rank,' out of ', n_proc,'and the sum is', total

 
  call MPI_FINALIZE (ierror)

end program ring

```



### Exercise 2

Implement a program which is working, but I guess I'm getting stack overflows everywhere. 

```fortran
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!
!!    Skeleton program for Ex. 5.1:
!!    Rings and deadlocks
!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
program euler
  
  use mpi

  implicit none
  
  ! Variables declaration
  integer my_rank, n_proc, ierror
  integer N, part, rest, i, divisor, divisorTotal
  double precision subsum, total

  ! Variable initialisation
  total = 0.
  subsum = 1.
  divisor = 1
  divisorTotal = 1
   N = 1000000000

  ! Begin MPI
  call MPI_INIT(ierror)
  
  ! Get my_rank and n_proc
  call MPI_COMM_RANK(MPI_COMM_WORLD, my_rank, ierror)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, n_proc, ierror)
 
  IF (my_rank == 0) THEN
    part = N / n_proc

    do i = 1, n_proc-1, +1
      call MPI_SEND(part, 1, MPI_LONG_LONG_INT, i, 1, MPI_COMM_WORLD, ierror)
    end do

    rest = N - n_proc*part
  ELSE
    call MPI_RECV(part, 1, MPI_LONG_LONG_INT, 0, 1, MPI_COMM_WORLD, ierror, MPI_STATUS_IGNORE)
  END IF
  write(*,*) 'subsum: ', divisor, subsum, part
  do i = part*my_rank, part*(my_rank + 1), +1
    divisor = divisor * 1./i
    subsum = subsum + subsum * divisor
  end do

  write(*,*) 'subsum: ', subsum, 'current: ', divisor
  
  IF (my_rank == 0) THEN
    do i = 1, n_proc-1, +1
      call MPI_RECV(divisor, 1, MPI_LONG_LONG_INT , i, 1, MPI_COMM_WORLD, ierror, MPI_STATUS_IGNORE)
      divisorTotal = divisorTotal * divisor
      call MPI_RECV(subsum, 1, MPI_DOUBLE , i, 2, MPI_COMM_WORLD, ierror, MPI_STATUS_IGNORE)
      total = total + subsum * 1. / divisorTotal
    end do

    write(*,*) 'Euler approximation: ', total
  ELSE
    call MPI_SEND(divisor, 1, MPI_LONG_LONG_INT , 0, 1, MPI_COMM_WORLD, ierror)
    call MPI_SEND(subsum, 1, MPI_DOUBLE , 0, 2, MPI_COMM_WORLD, ierror)
  END IF

  call MPI_FINALIZE (ierror)

end program euler

```

### Exercise 3

Completed the subroutines, but I only get one output file

```fortran
subroutine jacobi_step
    use poisson_commons
    use poisson_parameters
    use poisson_utils  

    ! Save the current estimate. 
    uold = unew

    ! Compute a new estimate.
    do j = 1, jmax
        do i = 1, imax
            unew ( i, j ) = forth * ( uold(i-1,j) + uold(i+1,j) + uold(i,j-1) + uold(i,j+1) - f(i,j))
        end do
    end do

    ! compute difference and errors
    udiff = unew - uold
    diff = mat_norm(udiff)
    udiff = unew - uexact
    error = mat_norm(udiff)

end subroutine jacobi_step

subroutine init_f
    use poisson_commons
    use poisson_parameters
    use poisson_utils
    !
    !  The "boundary" entries of f will store the boundary values of the solution.
    !
    !  The "interior" entries of f store the source term 
    !  of the Poisson equation.
    !

    do j = 1, jmax
        y = real ( j - 1,kind=prec_real) / real ( ny - 1,kind=prec_real)
        do i = 1, imax
            x = real ( i - 1,kind=prec_real) / real ( nx - 1,kind=prec_real)
            ! check boundary conditions
            if (i == 1 .or. i == imax .or. j == 1 .or. j == jmax) then
               f(i,j) = boundary ( x, y )
            else
               f(i,j) = source_term ( x, y )
            end if
        end do
    end do

end subroutine init_f
```

