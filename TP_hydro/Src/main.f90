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

   real(kind=prec_real)   :: dt, mydt, tps_elapsed, max_tps_elapsed, tps_cpu, t_deb, t_fin
   integer(kind=prec_int) :: nbp_init, nbp_final, nbp_max, freq_p

   ! Itialize MPI environment
   call MPI_INIT(ierror)

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
         call cmpdt(dt)
         if(nstep==0)dt=dt/2.
      endif

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
   if (.NOT. ptest) then
      call output(rank, coords, dimensions)
   end if

   call MPI_BARRIER(COMM_CART, ierror)

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

   call MPI_ALLREDUCE(tps_elapsed, max_tps_elapsed, 1, MPI_DOUBLE, MPI_MAX, COMM_CART, ierror)

   ! end mpi env
   !call end_mpi

   if (rank == 0 .AND. ptest) then
      call measurement(max_tps_elapsed, nproc)
   end if

   ! finallize mpi env
   call MPI_FINALIZE(ierror)
   
end program hydro_main
