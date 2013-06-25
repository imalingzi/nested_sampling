import sys
import numpy as np
cimport numpy as np

cdef extern:
    void compute_dos(long double* gl, int N, double P, double K)

cdef extern:
    void compute_dos_imp(long double* gl, int N, double P, double K)

cdef extern:
    void renorm_energies(long double* El, int N, long double Emin)
    
cdef extern: 
    void heat_capacity_loop(long double* El, long double* gl, double* Cvl, int N, double Tmin, double Tmax, int nT, double ndof)
    
def compute_cv_c(np.ndarray[long double, ndim=1, mode="c"] E_list,
                 double P, double K, double Tmin, double Tmax,
                 int nT, double ndof, int imp):
    cdef long double Emin
    cdef int N
    cdef np.ndarray[long double, ndim=1, mode="c"] dos_list
    cdef np.ndarray[double, ndim=1, mode="c"] cv_list
    Emin = E_list[-1]
    N = np.size(E_list)
    dos_list = np.zeros(N)
    cv_list = np.zeros(nT)
        
    renorm_energies(<long double*>E_list.data, N, Emin)
    
    if imp == 0:
        compute_dos(<long double*>dos_list.data, N, P, K)
    else:
        compute_dos_imp(<long double*>dos_list.data, N, P, K)
            
    heat_capacity_loop(<long double*>E_list.data,<long double*>dos_list.data,<double*>cv_list.data, N, Tmin, Tmax, nT, ndof)
    
    return cv_list

cdef extern:
    double heat_capacity(long double* El, long double* gl, int N, double T, double ndof)
    
def compute_cv_c_single(np.ndarray[long double, ndim=1, mode="c"] E_list, 
                      double K, double P, double T, double ndof, int imp):
    cdef long double Emin
    cdef int N
    cdef np.ndarray[long double, ndim=1, mode="c"] dos_list
    Emin = E_list[-1]
    N = np.size(E_list)
    dos_list = np.zeros(N)
    
    renorm_energies(<long double*>E_list.data, N, Emin)
    if (P == 1) or (imp == 0): 
        compute_dos(<long double*>dos_list.data, N, P, K)
    else:
        compute_dos_imp(<long double*>dos_list.data, N, P, K)
    return heat_capacity(<long double*>E_list.data,<long double*>dos_list.data, N, T, ndof)