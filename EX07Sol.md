# HP EX7

## Andrin Rehmann

### exercise 1

This will solve the issue:

```fortran
! Second Loop
  !   each time a 0 is present, increase the counter
  !$OMP PARALLEL PRIVATE(rank)
  rank = OMP_GET_THREAD_NUM()
  !$OMP DO
  do i = 1,n
    if (dat(i) == 0) then
      !$OMP ATOMIC
      n0 = n0 + 1
    end if
  end do
  !$OMP END DO
  !$OMP END PARALLEL
```

Or using reduction:

```fortran
  ! Second Loop
  !   each time a 0 is present, increase the counter
  !$OMP PARALLEL PRIVATE(rank)
  rank = OMP_GET_THREAD_NUM()
  !$OMP DO REDUCTION(+:n0)
  do i = 1,n
    if (dat(i) == 0) then
      n0 = n0 + 1
    end if
  end do
  !$OMP END DO
  !$OMP END PARALLEL
```

### exercise 2

Added following tags to the makefile:

```makefile
# Fortran compilation options
#-----------------------------
CFLAGS = -O3 -fopenmp

# Linker options
#---------------
LDFLAGS = -O3 -fopenmp
```

Added following commands to module_poisson_principal.f90 and mat_norm

```fortran
! Compute a new estimate.
!$OMP PARALLEL
!$OMP DO
do j = jmin, jmax
    do i = imin, imax
        if ( i == 1 .or. i == nx .or. j == 1 .or. j == ny ) then
            unew(i,j) = f(i,j)
        else
            unew(i,j) = 0.25 * ( uold(i-1,j) + uold(i,j+1) + uold(i,j-1) + uold(i+1,j) - f(i,j) * dx * dy )
        end if

    end do
end do
!$OMP END DO
!$OMP END PARALLEL
```

```fortran
!$OMP PARALLEL
!$OMP DO
do i = 1, nx
    do j = 1, ny
    	mat_norm = mat_norm + mat(i,j)*mat(i,j)
    end do
end do
!$OMP END DO
!$OMP END PARALLEL

mat_norm = sqrt(mat_norm)
```



### exercise 3

Unfortunately still couldn't get task6 running since I used the cartesian portioning which turned out to be very complicated. 

Also havn't found the time to make the plots yet. 


