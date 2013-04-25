# Import the Python-level symbols of numpy
import numpy as np

# Import the C-level symbols of numpy
cimport numpy as np

cimport cython # to disable bounds checks
# Numpy must be initialized. When using numpy from C or Cython you must
# _always_ do that, or you will have segfaults
np.import_array()


from libcpp.vector cimport vector
from libcpp cimport bool

cdef extern from "cpp/Munkres.h":
    cdef cppclass Munkres:
        Munkres()
        vector[vector[int]] solve(vector[vector[double]] x)

@cython.boundscheck(False)
def munkres(np.ndarray[np.double_t,ndim=2] A):
    '''
    calculate the minimum cost assigment of a cost matrix (must be numpy.double type)
    '''
    cdef int x = A.shape[0]
    cdef int y = A.shape[1]
    cdef Munkres* munk = new Munkres()
    cdef np.ndarray rslt = np.zeros([x, y], dtype=np.bool)
    cdef vector[vector[double]] cost
    for i in range(x):
        cost.push_back(vector[double]())
        for j in range(y):
            cost[i].push_back(A[i,j])
        
    cdef vector[vector[int]] ans = munk.solve(cost)
    del munk
    for i in range(x):
        for j in range(y):
            rslt[i,j] = ans[i][j]
    return rslt

@cython.boundscheck(False)
def max_cost_munkres(np.ndarray[np.double_t,ndim=2] A, double max_cost):
    cdef int x = A.shape[0]
    cdef int y = A.shape[1]
    cdef unsigned int i,j
    cdef Munkres* munk = new Munkres()
    cdef np.ndarray rslt = np.zeros([x, y], dtype=np.bool)
    cdef vector[vector[double]] cost
    for i in range(x):
        cost.push_back(vector[double]())
        for j in range(y):
            cost[i].push_back(A[i,j])
        for j in range(x):
            cost[i].push_back(max_cost)
        
    cdef vector[vector[int]] ans = munk.solve(cost)
    for i in range(x):
        for j in range(y):
            rslt[i,j] = ans[i][j]
    return rslt