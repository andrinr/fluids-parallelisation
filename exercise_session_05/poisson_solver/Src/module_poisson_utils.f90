!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -*- Mode: F90 -*- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! module_poisson_utils.f90 --- 
!!!!
!! function boundary
!! function source_term
!! function exact_solution
!! function mat_norm
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module poisson_utils

contains

function boundary (x,y)
    use poisson_parameters
    use poisson_const
    implicit none

    ! Dummy arguments
    real(kind=prec_real) boundary
    real(kind=prec_real), intent(in)  :: x
    real(kind=prec_real), intent(in)  :: y

    ! Dirichlet boundary conditions
    boundary = 0.0

    return

end function boundary

function source_term ( x, y )
    use poisson_parameters
    use poisson_const

    implicit none

    real(kind=prec_real) source_term
    real(kind=prec_real), intent(in)  :: x
    real(kind=prec_real), intent(in)  :: y

    ! source terms 
    source_term = 8*pi*pi * sin( 2.0*pi*x) * sin( 2.0*pi*y)

    return

end function source_term

function exact_solution ( x, y )
    use poisson_parameters
    use poisson_const
    implicit none

    real(kind=prec_real) exact_solution
    real(kind=prec_real), intent(in)  :: x
    real(kind=prec_real), intent(in)  :: y

    ! exact solutions to Poisson eq. with source terms 
    exact_solution = - sin(2.0*pi * x) * sin(2.0*pi * y)
  return
end function exact_solution

function mat_norm (mat)
    use poisson_commons
    use poisson_parameters

    implicit none

    real(kind=prec_real) mat(nx,ny)
    real(kind=prec_real) mat_norm
    ! norm of a matrix
    mat_norm = sqrt ( sum ( mat(1:nx,1:ny)**2 ) / real ( nx * ny,kind=prec_real) )

    return
end function mat_norm

end module poisson_utils
