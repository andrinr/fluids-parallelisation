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
OBJ = module_hydro_commun.o module_hydro_IO.o module_hydro_utils.o module_hydro_principal.o main.o

hydro:  $(OBJ)
	$(F90) $(LDFLAGS) $(OBJ) -o hydro 

clean:
	rm -f *.o *.mod 

cleanall:
	rm -f *.o *.mod hydro Hydro_out.*

%.o:    $(SRCDIR)/%.f90
	$(F90) $(CFLAGS) -c $<



