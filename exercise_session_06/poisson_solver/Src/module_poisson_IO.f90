!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -*- Mode: F90 -*- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! module_poisson_IO.f90 --- 
!!!!
!! subroutine read_params
!! subroutine output_exact
!! subroutine output 
!! subroutine title
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module poisson_IO

contains

subroutine read_params
  use poisson_parameters
    implicit none

    ! Local variables
    character(LEN=80) :: infile

    ! Namelists
    namelist/mesh/nx,ny
    namelist/jacobi/noutput,nstep_max,tolerance

    ! Read input file
    infile="../Input/input.nml"
    open(1,file=infile)
    read(1,NML=mesh)
    read(1,NML=jacobi)
    close(1)
end subroutine read_params

subroutine output_exact
    use poisson_commons
    use poisson_parameters
    use poisson_mpi

    implicit none

    ! Local variables
    character(LEN=80) :: filename

    character(len=8) :: fmt ! format descriptor
    character(len=5) :: x1
    fmt = '(I5.5)' ! an integer of width 5 with zeros at the left

    write (x1,fmt) myrank ! converting integer to string using a 'internal file'

    filename='../Output/exact_solution_'//trim(x1)

    open(10,file=filename,form='unformatted')
    write(10)myn(1),myn(2)
    write(10)real(uexact(mymin(1):mymax(1),mymin(2):mymax(2)),kind=prec_output)
    close(10)

end subroutine output_exact

subroutine output
    use poisson_commons
    use poisson_parameters
    use poisson_mpi

    implicit none

    ! Local variables
    character(LEN=80) :: filename
    character(LEN=5)  :: char,charpe
    integer(kind=prec_int) :: nout, MYPE
    MYPE=myrank

    ! Output approximate solution at iteration nout
    nout=nstep/noutput
    call title(nout,char)
    call title(MYPE,charpe)
    filename='../Output/output_'//TRIM(char)//'.'//TRIM(charpe)
    open(10,file=filename,form='unformatted')
    rewind(10)
    write(10)real(nstep,kind=prec_output),real(diff,kind=prec_output),real(error,kind=prec_output)
    write(10)myn(1),myn(2)
    write(10)real(uold(mymin(1):mymax(1),mymin(2):mymax(2)),kind=prec_output)
    close(10)

contains

subroutine title(n,nchar)
    use poisson_precision
    implicit none

    ! Format the title of the output file
    integer(kind=prec_int) :: n
    character(LEN=5) :: nchar
    character(LEN=1) :: nchar1
    character(LEN=2) :: nchar2
    character(LEN=3) :: nchar3
    character(LEN=4) :: nchar4
    character(LEN=5) :: nchar5

    if(n.ge.10000)then
        write(nchar5,'(i5)') n
        nchar = nchar5
    elseif(n.ge.1000)then
        write(nchar4,'(i4)') n
        nchar = '0'//nchar4
    elseif(n.ge.100)then
        write(nchar3,'(i3)') n
        nchar = '00'//nchar3
    elseif(n.ge.10)then
        write(nchar2,'(i2)') n
        nchar = '000'//nchar2
    else
        write(nchar1,'(i1)') n
        nchar = '0000'//nchar1
    endif
end subroutine title

end subroutine output

end module poisson_IO