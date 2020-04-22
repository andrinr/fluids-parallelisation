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
    implicit none

    ! Output exact solution
    character(LEN=80) :: filename
    filename='../Output/exact_solution'
    open(10,file=filename,form='unformatted')
    print*,'Outputting array of size=',nx,ny
    write(10)nx,ny
    write(10)real(uexact(imin:imax,jmin:jmax),kind=prec_output)
    close(10)

end subroutine output_exact

subroutine timing(elapsed, nproc)
    use poisson_commons
    use poisson_parameters
    implicit none
    integer :: nproc
    real :: elapsed
    open(11,file='../Ouput/timing', form='unformatted')
    write(11) elapsed, nproc, nx, ny
    close(11)
end subroutine timing

subroutine output
    use poisson_commons
    use poisson_parameters
    implicit none

    ! Local variables
    character(LEN=80) :: filename
    character(LEN=5)  :: char,charpe
    integer(kind=prec_int) :: nout,MYPE=0

    ! Output approximate solution at iteration nout
    nout=nstep/noutput
    call title(nout,char)
    call title(MYPE,charpe)
    filename='../Output/output_'//TRIM(char)//'.'//TRIM(charpe)
    open(10,file=filename,form='unformatted')
    rewind(10)
    print*,'Outputting array of size=',nx,ny
    write(10)real(nstep,kind=prec_output),real(diff,kind=prec_output),real(error,kind=prec_output)
    write(10)nx,ny
    write(10)real(uold(imin:imax,jmin:jmax),kind=prec_output)
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