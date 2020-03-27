!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -*- Mode: F90 -*- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! module_poisson_commons.f90 --- 
!!!!
!! module poisson_precision
!! module poisson_commons
!! module poisson_parameters 
!! module poisson_const
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module poisson_precision
    integer, parameter :: prec_real=kind(1.d0)
    integer, parameter :: prec_int=4
    integer, parameter :: prec_output=4
end module poisson_precision

module poisson_commons
    use poisson_precision
    real(kind=prec_real),allocatable,dimension(:,:) :: uold, udiff, unew, uexact, f

    logical                :: converged=.false.

    integer(kind=prec_int) :: imin,imax,jmin,jmax
    integer(kind=prec_int) :: nstep=0
    integer(kind=prec_int) :: i=0
    integer(kind=prec_int) :: j=0

    real(kind=prec_real)   :: diff=0.0, mydiff=0.0
    real(kind=prec_real)   :: error=0.0, myerror=0.0
    real(kind=prec_real)   :: x=0.0
    real(kind=prec_real)   :: y=0.0
end module poisson_commons

module poisson_parameters
    use poisson_precision
    integer(kind=prec_int) :: nx=2
    integer(kind=prec_int) :: ny=2
    integer(kind=prec_int) :: nstep_max=1000000

    real(kind=prec_real)   :: tolerance = 0.000001D+00
    real(kind=prec_real)   :: dx=1.0
    real(kind=prec_real)   :: dy=1.0

    integer(kind=prec_int) :: function=1
    integer(kind=prec_int) :: noutput=100

end module poisson_parameters

module poisson_const
    use poisson_precision
    real(kind=prec_real)   :: zero = 0.0
    real(kind=prec_real)   :: one = 1.0
    real(kind=prec_real)   :: two = 2.0
    real(kind=prec_real)   :: three = 3.0
    real(kind=prec_real)   :: four = 4.0
    real(kind=prec_real)   :: two3rd = 0.6666666666666667d0
    real(kind=prec_real)   :: half = 0.5
    real(kind=prec_real)   :: third = 0.33333333333333333d0
    real(kind=prec_real)   :: forth = 0.25
    real(kind=prec_real)   :: sixth = 0.16666666666666667d0
    real(kind=prec_real)   :: pi = 3.141592653589793D+00

end module poisson_const