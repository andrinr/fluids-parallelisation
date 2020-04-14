!! ===================================================
!! 
!! This simple program reads the file 'num.txt' and
!! computes its maximal value and how many 0 are there
!!
!! ===================================================

program max
  
  implicit none

  ! Declarations
  integer, parameter :: n = 1000000, truen0 = 646016
  integer :: maxvalue, tmp, i, n0
  integer, dimension(n) :: dat

  ! Read data from file and store it into dat array
  open(1, file='num.txt')
  do i = 1, n
    read(1,*)tmp
    dat(i)=tmp
  end do

  ! Initialization of values
  maxvalue = 0
  n0 = 0
  
  ! First Loop
  !   find max value by looping on the whole array   
  do i = 1, n
    if (dat(i) .gt. maxvalue) then
      maxvalue = dat(i)
    end if
  end do

  ! Second Loop
  !   each time a 0 is present, increase the counter
  do i = 1,n
    if (dat(i) == 0) then
      n0 = n0 + 1
    end if
  end do

  ! Outputs
  print*,'My Number of 0  : ',n0
  print*,'True number of 0: ',truen0
  print*,'My max value: ',maxvalue
  print*,'maxval(dat):  ',maxval(dat)
  
end program max
