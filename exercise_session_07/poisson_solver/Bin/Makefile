############################ -*- Mode: Makefile -*- ###########################
## Makefile --- 
###############################################################################


#------------------
F90 = gfortran

# Fortran compilation options
#-----------------------------
CFLAGS = -O3

# Linker options
#---------------
LDFLAGS = -O3


# Sources directories
#--------------------
SRCDIR = ../Src

# Objects
#------------
OBJ = module_poisson_commons.o module_poisson_IO.o module_poisson_utils.o module_poisson_principal.o main.o

poisson:  $(OBJ)
	$(F90) $(LDFLAGS) $(OBJ) -o poisson

clean:
	rm -f *.o *.mod 

cleanall:
	rm -f *.o *.mod poisson

%.o:    $(SRCDIR)/%.f90
	$(F90) $(CFLAGS) -c $<



