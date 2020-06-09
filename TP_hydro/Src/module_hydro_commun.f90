!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -*- Mode: F90 -*- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! module_hydro_commun.f90 --- 
!!!!
!! module hydro_precision
!! module hydro_commons
!! module hydro_parameters 
!! module hydro_const
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module hydro_precision
  integer, parameter :: prec_real=kind(1.d0)
  integer, parameter :: prec_int=4
  integer, parameter :: prec_output=4
end module hydro_precision

module hydro_commons
  use hydro_precision
  integer(kind=prec_int) :: imin,imax,jmin,jmax
  real(kind=prec_real),allocatable,dimension(:,:,:) :: uold
  real(kind=prec_real)   :: t=0.
  integer(kind=prec_int) :: nstep=0
  logical :: ptest = .FALSE.
end module hydro_commons

module hydro_parameters
  use hydro_precision
  integer(kind=prec_int) :: nx=2
  integer(kind=prec_int) :: ny=2
  integer(kind=prec_int) :: nvar=4
  real(kind=prec_real)   :: dx=1.0
  real(kind=prec_real)   :: tend=0.0
  real(kind=prec_real)   :: gamma=1.4d0
  real(kind=prec_real)   :: courant_factor=0.5d0
  real(kind=prec_real)   :: smallc=1.d-10
  real(kind=prec_real)   :: smallr=1.d-10
  integer(kind=prec_int) :: niter_riemann=10
  integer(kind=prec_int) :: iorder=2
  real(kind=prec_real)   :: slope_type=1.
  character(LEN=20)      :: scheme='muscl'
  integer(kind=prec_int) :: boundary_right=1
  integer(kind=prec_int) :: boundary_left =1
  integer(kind=prec_int) :: boundary_down =1
  integer(kind=prec_int) :: boundary_up   =1
  integer(kind=prec_int) :: noutput=100
  integer(kind=prec_int) :: nstepmax=1000000
end module hydro_parameters

module hydro_const
  use hydro_precision
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
  integer(kind=prec_int) :: ID=1
  integer(kind=prec_int) :: IU=2
  integer(kind=prec_int) :: IV=3
  integer(kind=prec_int) :: IP=4
end module hydro_const

module hydro_work_space
  use hydro_precision
  use hydro_parameters

  ! Work arrays
  real(kind=prec_real),dimension(:,:),pointer :: u,q,qxm,qxp,dq,qleft,qright,qgdnv,flux
  real(kind=prec_real),dimension(:)  ,pointer :: c
  real(kind=prec_real),dimension(:)  ,pointer :: rl,ul,pl,cl,wl
  real(kind=prec_real),dimension(:)  ,pointer :: rr,ur,pr,cr,wr
  real(kind=prec_real),dimension(:)  ,pointer :: ro,uo,po,co,wo
  real(kind=prec_real),dimension(:)  ,pointer :: rstar,ustar,pstar,cstar
  real(kind=prec_real),dimension(:)  ,pointer :: sgnm,spin,spout,ushock
  real(kind=prec_real),dimension(:)  ,pointer :: frac,scr,delp,pold
  integer(kind=prec_int),dimension(:),pointer :: ind,ind2
!$OMP THREADPRIVATE(u,q,qxm,qxp,dq,qleft,qright,qgdnv,flux, &
!$OMP c,rl,ul,pl,cl,wl,rr,ur,pr,cr,wr,ro,uo,po,co,wo,ind,ind2, &
!$OMP rstar,ustar,pstar,cstar,sgnm,spin,spout,ushock,frac,scr,delp,pold) 

contains

  subroutine allocate_work_space(ii1,ii2,ngrid)
    implicit none

    ! Dummy arguments
    integer(kind=prec_int), intent(in) :: ii1,ii2,ngrid
  
    allocate(u  (ii1:ii2,1:nvar))
    allocate(q  (ii1:ii2,1:nvar))
    allocate(dq (ii1:ii2,1:nvar))
    allocate(qxm(ii1:ii2,1:nvar))
    allocate(qxp(ii1:ii2,1:nvar))
    allocate(c  (ii1:ii2))
    allocate(qleft (1:ngrid,1:nvar))
    allocate(qright(1:ngrid,1:nvar))
    allocate(qgdnv (1:ngrid,1:nvar))
    allocate(flux  (1:ngrid,1:nvar))
    allocate(rl    (1:ngrid), ul   (1:ngrid), pl   (1:ngrid), cl    (1:ngrid))
    allocate(rr    (1:ngrid), ur   (1:ngrid), pr   (1:ngrid), cr    (1:ngrid))
    allocate(ro    (1:ngrid), uo   (1:ngrid), po   (1:ngrid), co    (1:ngrid))
    allocate(rstar (1:ngrid), ustar(1:ngrid), pstar(1:ngrid), cstar (1:ngrid))
    allocate(wl    (1:ngrid), wr   (1:ngrid), wo   (1:ngrid))
    allocate(sgnm  (1:ngrid), spin (1:ngrid), spout(1:ngrid), ushock(1:ngrid))
    allocate(frac  (1:ngrid), scr  (1:ngrid), delp (1:ngrid), pold  (1:ngrid))
    allocate(ind   (1:ngrid), ind2 (1:ngrid))
  end subroutine allocate_work_space

  subroutine deallocate_work_space()
    deallocate(u,q,dq,qxm,qxp,c,qleft,qright,qgdnv,flux)
    deallocate(rl,ul,pl,cl)
    deallocate(rr,ur,pr,cr)  
    deallocate(ro,uo,po,co)  
    deallocate(rstar,ustar,pstar,cstar)
    deallocate(wl,wr,wo)
    deallocate(sgnm,spin,spout,ushock)
    deallocate(frac,scr,delp,pold)
    deallocate(ind,ind2)    
  end subroutine deallocate_work_space
end module hydro_work_space
