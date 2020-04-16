############################ -*- Mode: Makefile -*- ###########################
## Makefile --- 
###############################################################################


#------------------
F90 = gfortran

# Fortran compilation options
#-----------------------------
CFLAGS = -O3 -fopenmp

# Linker options
#---------------
LDFLAGS = -O3


# Sources directories
#--------------------
SRCDIR = ../Src

# Objects
#------------
OBJ = max.o

poisson:  $(OBJ)
	$(F90) $(LDFLAGS) $(OBJ) -o poisson

clean:
	rm -f *.o *.mod 

cleanall:
	rm -f *.o *.mod poisson

%.o:    $(SRCDIR)/%.f90
	$(F90) $(CFLAGS) -c $<



