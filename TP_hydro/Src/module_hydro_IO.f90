!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -*- Mode: F90 -*- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! module_hydro_IO.f90 --- 
!!!!
!! subroutine read_params
!! subroutine output 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module hydro_IO
   integer :: totalx, totaly

contains

subroutine read_params(input_file_name)
  use hydro_parameters
  implicit none

  ! Local variables
  integer(kind=prec_int) :: narg,iargc
  CHARACTER(len=32) :: input_file_name

  ! Namelists
  namelist/run/nstepmax,tend,noutput
  namelist/mesh/nx,ny,dx,boundary_left,boundary_right,boundary_down,boundary_up
  namelist/hydro/gamma,courant_factor,smallr,smallc,niter_riemann, &
       &         iorder,scheme,slope_type

   totalx = nx
   totaly = ny
!   narg = iargc()
!   IF(narg .NE. 1)THEN
!      write(*,*)'You should type: a.out input.nml'
!      write(*,*)'File input.nml should contain a parameter namelist'
!      STOP
!   END IF
!   CALL getarg(1,infile)
  infile="../Input/" + input_file_name + "nml"
  print*,"Reading: ", infile
  open(1,file=infile)
  read(1,NML=run)
  read(1,NML=mesh)
  read(1,NML=hydro)
  close(1)
end subroutine read_params


subroutine output(rank, coords, dimensions)
  use hydro_commons
  use hydro_parameters
  implicit none

  ! Local variables
  character(LEN=80) :: filename
  character(LEN=5)  :: char,charpe
  integer(kind=prec_int) :: nout,rank
  integer, dimension(2) :: coords, dimensions

  nout=nstep/noutput
  call title(nout,char)
  call title(rank,charpe)
  filename='../Output/output_'//TRIM(char)//'.'//TRIM(charpe)
  open(10,file=filename,form='unformatted')
  rewind(10)
  print*,'Outputting array of size=',nx,ny,nvar
  write(10)real(t,kind=prec_output),real(gamma,kind=prec_output)
  write(10)nx,ny,nvar,nstep, coords(1), coords(2), dimensions(1), dimensions(2)
  write(10)real(uold(imin+2:imax-2,jmin+2:jmax-2,1:nvar),kind=prec_output)
  close(10)

contains

subroutine title(n,nchar)
  use hydro_precision
  implicit none

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

subroutine measurement(elapsedtime, nproc)

   use hydro_commons
   use hydro_parameters
   implicit none

   character(LEN=80) :: filename
   real(kind=prec_real) :: elapsedtime
   integer :: type = 0
   integer(kind=prec_int) :: nproc, nthread

   !nthread = OMP_NUM_THREADS

   filename='../Analysis/measurements'
   open(10,file=filename,form='unformatted', position="append")
   write(10)real(elapsedtime,kind=prec_output)
   write(10)nproc, totalx, totaly
   close(10)

end subroutine measurement


end module hydro_IO
