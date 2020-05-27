!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -*- Mode: F90 -*- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! module_hydro_utils.f90 --- 
!!!!
!! subroutine make_boundary(idim)
!! subroutine constoprim(u,q,c)
!! subroutine eos(rho,eint,p,c)
!! subroutine trace(q,dq,c,qxm,qxp,dtdx)
!! subroutine slope(q,dq)
!! subroutine riemann(qleft,qright,qgdnv, &
!!            & rl,ul,pl,cl,wl,rr,ur,pr,cr,wr,ro,uo,po,co,wo, &
!!            & rstar,ustar,pstar,cstar,sgnm,spin,spout, &
!!            & ushock,frac,scr,delp,pold,ind,ind2)
!! subroutine cmpflx(qgdnv,flux)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module hydro_utils

contains

subroutine make_boundary(idim)
  use hydro_commons
  use hydro_const
  use hydro_parameters
  use hydro_mpi
  implicit none

  ! Dummy arguments
  integer(kind=prec_int), intent(in) :: idim
  ! Local variables
  integer(kind=prec_int) :: ivar,i,i0,j,j0
  real(kind=prec_real)   :: sign
!!$ integer(kind=prec_int) :: ijet
!!$ real(kind=prec_real) :: djet,ujet,pjet

  if(idim==1)then
     
     ! Left boundary
      if (rankl == MPI_PROC_NULL) then
         do ivar=1,nvar
            do i=1,2           
               sign=1.0
               ! different boundary conditions as specified in the input file
               ! we could possibly add another boundary condition for MPI comm?
               if(boundary_left==1)then
                  i0=5-i
                  if(ivar==IU)sign=-1.0
               else if(boundary_left==2)then
                  i0=3
               else
                  i0=nx+i
               end if
               do j=jmin+2,jmax-2
                  uold(i,j,ivar)=uold(i0,j,ivar)*sign
               end do
            end do
         end do
      end if
      
     ! Right boundary
      if (rankr == MPI_PROC_NULL) then
         do ivar=1,nvar
            do i=nx+3,nx+4
               sign=1.0
               if(boundary_right==1)then
                  i0=2*nx+5-i
                  if(ivar==IU)sign=-1.0
               else if(boundary_right==2)then
                  i0=nx+2
               else
                  i0=i-nx
               end if
               do j=jmin+2,jmax-2
                  uold(i,j,ivar)=uold(i0,j,ivar)*sign
               end do
            end do
         end do
      end if

  else

     ! Lower boundary
      if (rankb == MPI_PROC_NULL) then
         do ivar=1,nvar
            do j=1,2           
               sign=1.0
               if(boundary_down==1)then
                  j0=5-j
                  if(ivar==IV)sign=-1.0
               else if(boundary_down==2)then
                  j0=3
               else
                  j0=ny+i
               end if
               do i=imin+2,imax-2
                  uold(i,j,ivar)=uold(i,j0,ivar)*sign
               end do
            end do
         end do
      end if

!!$        djet=1.0
!!$        ujet=300.
!!$        pjet=1.0
!!$        ijet=imax-20 
!!$        do ivar=1,nvar
!!$           do j=1,2           
!!$              do i=ijet,imax-2
!!$                 uold(i,j,1)=djet
!!$                 uold(i,j,2)=0.
!!$                 uold(i,j,3)=djet*ujet
!!$                 uold(i,j,4)=pjet/(gamma-1)+0.5*djet*ujet**2
!!$              end do
!!$           end do
!!$        end do

     ! Upper boundary
      if (rankt == MPI_PROC_NULL) then
         do ivar=1,nvar
            do j=ny+3,ny+4
               sign=1.0
               if(boundary_up==1)then
                  j0=2*ny+5-j
                  if(ivar==IV)sign=-1.0
               else if(boundary_up==2)then
                  j0=ny+2
               else
                  j0=j-ny
               end if
               do i=imin+2,imax-2
                  uold(i,j,ivar)=uold(i,j0,ivar)*sign
               end do
            end do
         end do
      end if

  end if
end subroutine make_boundary


subroutine constoprim(u,q,c)
  use hydro_commons
  use hydro_const
  use hydro_parameters
  implicit none

  ! Dummy arguments
  real(kind=prec_real), dimension(:,:), intent(in)   :: u
  real(kind=prec_real), dimension(:,:), intent(out)  :: q
  real(kind=prec_real), dimension(:)  , intent(out)  :: c
  ! Local variables
  integer(kind=prec_int) :: i,IN,ijmax,ijmin
  real(kind=prec_real)   :: eken
  real(kind=prec_real), dimension(1:size(c)) :: e

  ! ::: .....::::: convert to non-conservation form and compute
  ! ::: .....::::: pressure via equation of state
  ijmin = 1
  ijmax=size(c)
  do i = ijmin, ijmax
     q(i,ID) = max(u(i,ID),smallr)
     q(i,IU) = u(i,IU)/q(i,ID)
     q(i,IV) = u(i,IV)/q(i,ID)
     eken = half*(q(i,IU)**2+q(i,IV)**2)
     q(i,IP) = u(i,IP)/q(i,ID) - eken     
  end do

  if (nvar > 4) then
     do IN = 5, nvar
        do i = ijmin, ijmax
           q(i,IN) = u(i,IN)/q(i,ID)
        end do
     end do
  end if

  do i = ijmin, ijmax
     e(i)=q(i,IP)
  end do
  call eos(q(1:ijmax,ID),e,q(1:ijmax,IP),c(1:ijmax))
end subroutine constoprim


subroutine eos(rho,eint,p,c)
  use hydro_const
  use hydro_parameters
  implicit none

  ! Dummy arguments
  real(kind=prec_real), dimension(:), intent(in)  :: rho,eint
  real(kind=prec_real), dimension(:), intent(out) :: p,c
  ! Local variables
  integer(kind=prec_int) :: k
  real(kind=prec_real)   :: smallp

  smallp = smallc**2/gamma
  do k = 1, size(rho)
     p(k) = (gamma - one)*rho(k)*eint(k)
     p(k) = max(p(k),rho(k)*smallp)
     c(k) = sqrt(gamma*p(k)/rho(k))
  end do
end subroutine eos


subroutine trace(q,dq,c,qxm,qxp,dtdx)
  use hydro_commons
  use hydro_const
  use hydro_parameters
  implicit none

  ! Dummy arguments
  real(kind=prec_real), intent(in) :: dtdx
  real(kind=prec_real), dimension(:,:), intent(in)  :: q
  real(kind=prec_real), dimension(:,:), intent(out) :: dq,qxm,qxp 
  real(kind=prec_real), dimension(:),   intent(in)  :: c 
  ! Local variables
  integer(kind=prec_int) :: i,IN,ijmin,ijmax
  real(kind=prec_real)   :: cc,csq,r,u,v,p,a
  real(kind=prec_real)   :: dr,du,dv,dp,da
  real(kind=prec_real)   :: alpham,alphap,alpha0r,alpha0v
  real(kind=prec_real)   :: spminus,spplus,spzero
  real(kind=prec_real)   :: apright,amright,azrright,azv1right,acmpright
  real(kind=prec_real)   :: apleft,amleft,azrleft,azv1left,acmpleft
  real(kind=prec_real)   :: zerol,zeror,project

  ijmin = 1
  ijmax = size(c)
  ! compute slopes
  dq = zero
  if (iorder .ne. 1) then
     call slope(q,dq)
  endif

  if(scheme=='muscl')then ! MUSCL-Hancock method
     zerol=-100./dtdx
     zeror=+100./dtdx
     project=one
  endif
  if(scheme=='plmde')then ! standard PLMDE
     zerol=zero
     zeror=zero
     project=one  
  endif
  if(scheme=='collela')then ! Collela's method
     zerol=zero
     zeror=zero
     project=zero
  endif

  do i = ijmin+1, ijmax-1
     
     cc = c(i)
     csq = cc**2
     r = q(i,ID)
     u = q(i,IU)
     v = q(i,IV)
     p = q(i,IP)
     
     dr = dq(i,ID)
     du = dq(i,IU)
     dv = dq(i,IV)
     dp = dq(i,IP)
     
     alpham  = half*(dp/(r*cc) - du)*r/cc
     alphap  = half*(dp/(r*cc) + du)*r/cc
     alpha0r = dr - dp/csq
     alpha0v = dv
     
     ! Right state
     spminus = (u-cc)*dtdx+one
     spplus  = (u+cc)*dtdx+one
     spzero  =  u    *dtdx+one
     if((u-cc)>=zeror)spminus=project
     if((u+cc)>=zeror)spplus =project
     if( u    >=zeror)spzero =project
     apright   = -half*spplus *alphap
     amright   = -half*spminus*alpham
     azrright  = -half*spzero *alpha0r
     azv1right = -half*spzero *alpha0v     
     qxp(i,ID) = r + (apright + amright + azrright)
     qxp(i,IU) = u + (apright - amright           )*cc/r
     qxp(i,IV) = v + (azv1right                   )
     qxp(i,IP) = p + (apright + amright           )*csq
     
     ! Left state
     spminus = (u-cc)*dtdx-one
     spplus  = (u+cc)*dtdx-one
     spzero  =  u    *dtdx-one
     if((u-cc)<=zerol)spminus=-project
     if((u+cc)<=zerol)spplus =-project
     if( u    <=zerol)spzero =-project
     apleft   = -half*spplus *alphap
     amleft   = -half*spminus*alpham
     azrleft  = -half*spzero *alpha0r
     azv1left = -half*spzero *alpha0v
     qxm(i,ID) = r + (apleft + amleft + azrleft)
     qxm(i,IU) = u + (apleft - amleft          )*cc/r
     qxm(i,IV) = v + (azv1left                 )
     qxm(i,IP) = p + (apleft + amleft          )*csq
     
  end do

  if (nvar>4)then
     do IN = 5, nvar
        do i = ijmin+1, ijmax-1
           
           u  =  q(i,IU)
           a  =  q(i,IN)
           da = dq(i,IN)
           ! Right state
           spzero = u*dtdx+one
           if(u>=zeror)spzero=project
           acmpright = -half*spzero*da
           qxp(i,IN) = a + acmpright
           ! Left state
           spzero = u*dtdx-one
           if(u<=zerol)spzero=-project
           acmpleft = -half*spzero*da
           qxm(i,IN) = a + acmpleft
           
        end do
     end do
  end if
end subroutine trace



subroutine slope(q,dq)
  use hydro_commons
  use hydro_const
  use hydro_parameters
  implicit none

  ! Dummy arguments
  real(kind=prec_real), dimension(:,:), intent(in)  :: q
  real(kind=prec_real), dimension(1:size(q,1),1:nvar), intent(out) :: dq
  ! Local arrays
  integer(kind=prec_int) :: i,n,ijmin,ijmax
  real(kind=prec_real)   :: dsgn,dlim,dcen,dlft,drgt,slop

  ijmin = 1
  ijmax = size(q,1)
  do n = 1, nvar
     do i = ijmin+1, ijmax-1        
        dlft = slope_type*(q(i  ,n) - q(i-1,n))
        drgt = slope_type*(q(i+1,n) - q(i  ,n))
        dcen = half*(dlft+drgt)/slope_type
        dsgn = sign(one, dcen)
        slop = min(abs(dlft),abs(drgt))
        dlim = slop
        if((dlft*drgt)<=zero)dlim=zero
        dq(i,n) = dsgn*min(dlim,abs(dcen))
     end do
  end do  
end subroutine slope



subroutine riemann(qleft,qright,qgdnv, &
                 & rl,ul,pl,cl,wl,rr,ur,pr,cr,wr,ro,uo,po,co,wo, &
                 & rstar,ustar,pstar,cstar,sgnm,spin,spout, &
                 & ushock,frac,scr,delp,pold,ind,ind2)
  use hydro_const
  use hydro_parameters
  implicit none

  ! Dummy arguments
  real(kind=prec_real),dimension(:,:), intent(in)  :: qleft,qright
  real(kind=prec_real),dimension(:,:), intent(out) :: qgdnv
  real(kind=prec_real),dimension(:),   intent(out) :: rl,ul,pl,cl,wl
  real(kind=prec_real),dimension(:),   intent(out) :: rr,ur,pr,cr,wr
  real(kind=prec_real),dimension(:),   intent(out) :: ro,uo,po,co,wo
  real(kind=prec_real),dimension(:),   intent(out) :: rstar,ustar,pstar,cstar
  real(kind=prec_real),dimension(:),   intent(out) :: sgnm,spin,spout,ushock
  real(kind=prec_real),dimension(:),   intent(out) :: frac,scr,delp,pold  
  integer(kind=prec_int),dimension(:), intent(out) :: ind,ind2
  ! Local variables
  real(kind=prec_real)   :: smallp,gamma6,ql,qr,usr,usl,wwl,wwr,smallpp
  integer(kind=prec_int) :: i,j,in,n,iter,n_new,nface

  ! Constants
  nface=size(rl)
  smallp = smallc**2/gamma
  smallpp = smallr*smallp
  gamma6 = (gamma+one)/(two*gamma)

  ! Pressure, density and velocity
  do i=1,nface
     rl(i)=MAX(qleft (i,ID),smallr)
     ul(i)=    qleft (i,IU)
     pl(i)=MAX(qleft (i,IP),rl(i)*smallp)
     rr(i)=MAX(qright(i,ID),smallr)
     ur(i)=    qright(i,IU)
     pr(i)=MAX(qright(i,IP),rr(i)*smallp)
  end do

  ! Lagrangian sound speed
  do i=1,nface
     cl(i) = gamma*pl(i)*rl(i)
     cr(i) = gamma*pr(i)*rr(i)
  end do

  ! First guess
  wl = sqrt(cl); wr = sqrt(cr)
  pstar = ((wr*pl+wl*pr)+wl*wr*(ul-ur))/(wl+wr)
  pstar = MAX(pstar,0.d0)
  pold = pstar
  n = nface
  do i = 1,n
     ind(i)=i
  end do

  ! Newton-Raphson iterations to find pstar at the required accuracy
  do iter = 1,niter_riemann 
     do i=1,n
        wwl=sqrt(cl(ind(i))*(one+gamma6*(pold(i)-pl(ind(i)))/pl(ind(i))))
        wwr=sqrt(cr(ind(i))*(one+gamma6*(pold(i)-pr(ind(i)))/pr(ind(i))))
        ql=two*wwl**3/(wwl**2+cl(ind(i)))
        qr=two*wwr**3/(wwr**2+cr(ind(i)))
        usl=ul(ind(i))-(pold(i)-pl(ind(i)))/wwl
        usr=ur(ind(i))+(pold(i)-pr(ind(i)))/wwr
        delp(i)=MAX(qr*ql/(qr+ql)*(usl-usr),-pold(i))
     end do
     do i=1,n
        pold(i)=pold(i)+delp(i)
     end do
     ! Convergence indicator
     do i=1,n 
        uo(i)=ABS(delp(i)/(pold(i)+smallpp))
     end do
     n_new=0
     do i=1,n
        if(uo(i)>1.d-06)then
           n_new=n_new+1
           ind2(n_new)=ind (i)
           po  (n_new)=pold(i)
        end if
     end do
     j=n_new
     do i=1,n
        if(uo(i)<=1.d-06)then
           n_new=n_new+1
           ind2(n_new)=ind (i)
           po  (n_new)=pold(i)
        end if
     end do
     ind (1:n)=ind2(1:n)
     pold(1:n)=po  (1:n)
     n=j
  end do

  do i=1,nface
     pstar(ind(i))=pold(i)
  end do
  do i=1,nface
     wl(i) = sqrt(cl(i)*(one+gamma6*(pstar(i)-pl(i))/pl(i)))
     wr(i) = sqrt(cr(i)*(one+gamma6*(pstar(i)-pr(i))/pr(i)))
  end do
  do i=1,nface
     ustar(i) = half*(ul(i) + (pl(i)-pstar(i))/wl(i) + &
          &           ur(i) - (pr(i)-pstar(i))/wr(i) )
  end do

  do i=1,nface
     sgnm(i) = sign(one,ustar(i))
  end do

  do i=1,nface
     if(sgnm(i)==one)then
        ro(i) = rl(i)
        uo(i) = ul(i)
        po(i) = pl(i)
        wo(i) = wl(i)
     else
        ro(i) = rr(i)
        uo(i) = ur(i)
        po(i) = pr(i)
        wo(i) = wr(i)
     end if
  end do
  do i=1,nface
     co(i) = max(smallc,sqrt(abs(gamma*po(i)/ro(i))))
  end do

  do i=1,nface
     rstar(i) = ro(i)/(one+ro(i)*(po(i)-pstar(i))/wo(i)**2)
     rstar(i) = max(rstar(i),smallr)
  end do
  do i=1,nface
     cstar(i) = max(smallc,sqrt(abs(gamma*pstar(i)/rstar(i))))
  end do
  
  do i=1,nface
     spout (i) = co   (i)    - sgnm(i)*uo   (i)
     spin  (i) = cstar(i)    - sgnm(i)*ustar(i)
     ushock(i) = wo(i)/ro(i) - sgnm(i)*uo   (i)
  end do
  do i=1,nface
     if(pstar(i)>=po(i))then
        spin (i) = ushock(i)
        spout(i) = ushock(i)
     end if
  end do
  do i=1,nface
     scr(i) = MAX(spout(i)-spin(i),smallc+ABS(spout(i)+spin(i)))
  end do
  do i=1,nface
     frac(i) = (one + (spout(i) + spin(i))/scr(i))*half
     frac(i) = max(zero,min(one,frac(i)))
  end do
  
  do i=1,nface
     qgdnv(i,ID) = frac(i)*rstar(i) + (one - frac(i))*ro(i)
     qgdnv(i,IU) = frac(i)*ustar(i) + (one - frac(i))*uo(i)
     qgdnv(i,IP) = frac(i)*pstar(i) + (one - frac(i))*po(i)
  end do
  do i=1,nface
     if(spout(i)<zero)then
        qgdnv(i,ID) = ro(i)
        qgdnv(i,IU) = uo(i)
        qgdnv(i,IP) = po(i)
     end if
  end do
  do i=1,nface
     if(spin(i)>zero)then
        qgdnv(i,ID) = rstar(i)
        qgdnv(i,IU) = ustar(i)
        qgdnv(i,IP) = pstar(i)
     end if
  end do

  ! transverse velocity
  do i=1,nface
     if(sgnm(i)==one)then
        qgdnv(i,IV) = qleft (i,IV)
     else
        qgdnv(i,IV) = qright(i,IV)
     end if
  end do

  ! other passive variables
  if (nvar > 4) then
     do in = 4,nvar
        do i=1,nface
           if(sgnm(i)==one)then
              qgdnv(i,in) = qleft (i,in)
           else
              qgdnv(i,in) = qright(i,in)
           end if
        end do
     end do
  end if
end subroutine riemann


subroutine cmpflx(qgdnv,flux)
  use hydro_parameters
  use hydro_const
  implicit none

  ! Dummy arguments
  real(kind=prec_real), dimension(:,:), intent(in)  :: qgdnv
  real(kind=prec_real), dimension(:,:), intent(out) :: flux
  ! Local variables
  integer(kind=prec_int) :: i,IN,nface
  real(kind=prec_real) :: entho,etot,ekin

  nface=size(flux,1)
  entho=one/(gamma-one)

  ! Compute fluxes
  do i=1,nface

     ! Mass density
     flux(i,ID) = qgdnv(i,ID)*qgdnv(i,IU)

     ! Normal momentum
     flux(i,IU) = flux(i,ID)*qgdnv(i,IU)+qgdnv(i,IP)

     ! Transverse momentum 1
     flux(i,IV) = flux(i,ID)*qgdnv(i,IV)

     ! Total energy
     ekin = half*qgdnv(i,ID)*(qgdnv(i,IU)**2+qgdnv(i,IV)**2)
     etot = qgdnv(i,IP)*entho + ekin
     flux(i,IP) = qgdnv(i,IU)*(etot+qgdnv(i,IP))

     ! Other advected quantities
     if (nvar>42) then
        do IN = 5, nvar
           flux(i,IN) = flux(i,ID)*qgdnv(i,IN)
        end do
     end if

  end do
end subroutine cmpflx

end module hydro_utils
