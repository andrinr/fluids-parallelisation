!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -*- Mode: F90 -*- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! main.f90 --- 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

program hydro_main
  use hydro_commons
  use hydro_parameters
  use hydro_IO
  use hydro_principal
  use hydro_mpi

  implicit none

  real(kind=prec_real)   :: dt, tps_elapsed, tps_cpu, t_deb, t_fin
  integer(kind=prec_int) :: nbp_init, nbp_final, nbp_max, freq_p
  integer :: i

  ! Itialize MPI environment
  call MPI_INIT(ierror)

  ! Initialize clock counter
  call system_clock(count_rate=freq_p, count_max=nbp_max)
  call system_clock(nbp_init)
  call cpu_time(t_deb)

  ! Read run parameters
  call read_params

  ! init MPI
  call init_mpi

  ! Initialize hydro grid
  ! TODO: could be broadcasted
  call init_hydro

  do i=1,2
  call get_surround
  end do

  if (.false.) then

  print*,'Starting time integration, nx = ',nx,' ny = ',ny  

  ! Main time loop
  do while (t < tend .and. nstep < nstepmax)

     ! Output results
     if(MOD(nstep,noutput)==0)then
        call output
      end if

     ! Compute new time-step, only for even time steps
     if(MOD(nstep,2)==0 .and. rank == 0 )then
        call cmpdt(dt)
        ! safety marigin for start
        if(nstep==0)dt=dt/2.
     endif

     call MPI_BCAST(dt, 1, MPI_DOUBLE, 0, COMM_CART, ierror)

     ! print*, 'MAIN || ', 'I am rank ', rank, ' of ', nproc, ' and dt is ', dt

     !call get_surround
     ! Directional splitting
     if(MOD(nstep,2)==0)then
        ! x sweep
        call godunov(1,dt)
        ! y sweep
        call godunov(2,dt)
     else
        ! y sweep
        call godunov(2,dt)
        ! x sweep
        call godunov(1,dt)
     end if

     nstep=nstep+1
     t=t+dt
     !write(*,'("step=",I6," t=",1pe10.3," dt=",1pe10.3)')nstep,t,dt

  end do

   end if

  ! Final output
  call output

  ! add comment

  ! Timing
  call cpu_time(t_fin)
  call system_clock(nbp_final)
  tps_cpu=t_fin-t_deb
  if (nbp_final>nbp_init) then
     tps_elapsed=real(nbp_final-nbp_init)/real(freq_p)
  else
     tps_elapsed=real(nbp_final-nbp_init+nbp_max)/real(freq_p) 
  endif  
  print *,'Temps CPU (s.)     : ',tps_cpu
  print *,'Temps elapsed (s.) : ',tps_elapsed

  call MPI_FINALIZE(ierror)
  
end program hydro_main
