#CXX=nvcc
#CXXFLAGS=-std=c++11 -O3

#all: a3

#clean:
#	rm -rf a3

CXX=g++
NVCC=nvcc
CXXFLAGS=-std=c++11 -O3
NVCCFLAGS=-std=c++11 -O3

# Object files
OBJ = a3_main.o a3.o

# Rule to make the executable
a3: $(OBJ)
	$(NVCC) $(NVCCFLAGS) -o a3 $(OBJ)

# Rule to make the a3_main object file
a3_main.o: a3.cpp a3.hpp
	$(CXX) $(CXXFLAGS) -c a3.cpp -o a3_main.o

# Rule to make the a3 object file
a3.o: a3.cu a3.hpp
	$(NVCC) $(NVCCFLAGS) -c a3.cu -o a3.o

# Rule to clean
clean:
	rm -f a3 $(OBJ)

