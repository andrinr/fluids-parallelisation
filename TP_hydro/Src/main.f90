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

  real(kind=prec_real)   :: dt, mydt, tps_elapsed, tps_cpu, t_deb, t_fin
  integer(kind=prec_int) :: nbp_init, nbp_final, nbp_max, freq_p
  integer :: providedsupportlevel


  ! Itialize MPI environment
  !call MPI_INIT(ierror)
  call MPI_INIT_THREAD(1,providedsupportlevel,ierror)
  print*,"Provided mpi thread support level: ", providedsupportlevel

  ! Initialize clock counter
  call system_clock(count_rate=freq_p, count_max=nbp_max)
  call system_clock(nbp_init)
  call cpu_time(t_deb)

  ! Read run parameters
  call read_params

  ! Initialize mpi
  call init_mpi

  ! Initialize hydro grid
  call init_hydro

  print*,'Starting time integration, nx = ',nx,' ny = ',ny  

  ! Main time loop
  do while (t < tend .and. nstep < nstepmax)

     ! Output results
     if(MOD(nstep,noutput)==0)then
         write(*,'("step=",I6," t=",1pe10.3," dt=",1pe10.3)')nstep,t,dt
        call output(rank, coords, dimensions)
      end if

     ! Compute new time-step
     if(MOD(nstep,2)==0)then
        call cmpdt(mydt)
        if(nstep==0)mydt=mydt/2.
     endif

     !call MPI_BCAST(dt, 1, MPI_DOUBLE, 0, COMM_CART, ierror)
     call MPI_ALLREDUCE(mydt, dt, 1, MPI_DOUBLE, MPI_MIN, COMM_CART, ierror)

     ! Directional splitting
     if(MOD(nstep,2)==0)then
        call godunov(1,dt)
        call godunov(2,dt)
     else
        call godunov(2,dt)
        call godunov(1,dt)
     end if

     nstep=nstep+1
     t=t+dt

  end do

  ! Final output
  call output(rank, coords, dimensions)

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

  ! end mpi env
  !call end_mpi

  ! finallize mpi env
  call MPI_FINALIZE(ierror)
  
end program hydro_main
