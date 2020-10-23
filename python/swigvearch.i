%module swigvearch

#define VEARCH_VERSION_MAJOR 0
#define VEARCH_VERSION_MINOR 3
#define VEARCH_VERSION_PATCH 0

%{
#define SWIG_FILE_WITH_INIT
#define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION
#include <numpy/arrayobject.h>
%}

%include <stdint.i>
typedef int64_t size_t;

#define __restrict

%{
#include "gamma_api.h"
%}

%include "gamma_api.h"



%include <std_string.i>
%include <std_vector.i>
#include "gamma_api.h"
#include <stdio.h>
#include <vector>
#include <stdlib.h>
%inline%{
    void *swigInitEngine(unsigned char *pConfig, int len){
        char* config_str = (char*)pConfig;
        void* engine = Init(config_str, len);
        return engine;
    }

    int swigClose(void *engine){
        int res = Close(engine);
        return res;
    }

    int swigCreateTable(void *engine, unsigned char *pTable, int len){
        char *table_str = (char*)pTable;
        return CreateTable(engine, table_str, len);
    }

    int swigAddOrUpdateDoc(void *engine, unsigned char *pDoc, int len){
        char *doc_str = (char*)pDoc; 
        return AddOrUpdateDoc(engine, doc_str, len);
    }

    int swigUpdateDoc(void *engine, unsigned char *pDoc, int len){
        char *doc_str = (char*)pDoc;
        return UpdateDoc(engine, doc_str, len);
    }
   

    int swigDeleteDoc(void *engine,unsigned char *docid, int len){
        char *doc_id = (char*)docid;
        return DeleteDoc(engine, doc_id, len);
    }

    std::vector<unsigned char> swigGetEngineStatus(void *engine){
        char *status_str = NULL;
        int len = 0;
        GetEngineStatus(engine, &status_str, &len);
        std::vector<unsigned char> vec_status(len);
        memcpy(vec_status.data(), status_str, len);
        free(status_str);
        status_str = NULL;
        return vec_status;
    }

    std::vector<unsigned char> swigGetDocByID(void *engine, char *docid, int docid_len){
        char *doc_id = (char*)docid;
        char *doc_str = NULL;
        int len = 0;
        int res = GetDocByID(engine, doc_id, docid_len, &doc_str, &len);
        if(res == 0){
            std::vector<unsigned char> vec_doc(len);
            memcpy(vec_doc.data(), doc_str, len);
            free(doc_str);
            doc_str = NULL;
            return vec_doc;
        }
        else{
            std::vector<unsigned char> vec_doc(1);
            return vec_doc;
        }
    }
    
    std::vector<unsigned char> swigGetDocByDocID(void *engine, int docid){
        char *doc_str = NULL;
        int len = 0;
        int res = GetDocByDocID(engine, docid, &doc_str, &len);
        if(res == 0){
            std::vector<unsigned char> vec_doc(len);
            memcpy(vec_doc.data(), doc_str, len);
            free(doc_str);
            doc_str = NULL;
            return vec_doc;
        }
        else{
            std::vector<unsigned char> vec_doc(1);
            return vec_doc;
        }
    }

    int swigBuildIndex(void* engine){
        return BuildIndex(engine);
    }

    int swigDump(void* engine){
        return Dump(engine);
    }

    int swigLoad(void* engine){
        return Load(engine);
    }

    std::vector<unsigned char> swigSearch(void* engine, unsigned char* pRequest, int req_len){
        char* request_str = (char*)pRequest;
        char* response_str = NULL;
        int res_len = 0;
        int code_response = Search(engine, request_str, req_len, &response_str, &res_len);
        if(code_response == 0){    
            std::vector<unsigned char> vec_res(res_len);
            memcpy(vec_res.data(), response_str, res_len);
            free(response_str);
            response_str = NULL;
            return vec_res;
        }else{
            std::vector<unsigned char> vec_res(1);
            return vec_res;
        }
    }

    int swigDelDocByQuery(void* engine, unsigned char *pRequest, int len){
        char* request_str = (char*)pRequest;
        return DelDocByQuery(engine, request_str, len);
    }
    
    unsigned char* swigGetVectorPtr(std::vector<unsigned char> &v){
        return v.data();
    }
%}


void *memcpy(void *dest, const void *src, size_t n);


/*******************************************************************
 * Types of vectors we want to manipulate at the scripting language
 * level.
 *******************************************************************/
// simplified interface for vector
namespace std {

    template<class T>
    class vector {
    public:
        vector();
        void push_back(T);
        void clear();
        T * data();
        size_t size();
        T at (size_t n) const;
        void resize (size_t n);
        void swap (vector<T> & other);
    };
};


%template(IntVector) std::vector<int>;
%template(LongVector) std::vector<long>;
%template(ULongVector) std::vector<unsigned long>;
%template(CharVector) std::vector<char>;
%template(UCharVector) std::vector<unsigned char>;
%template(FloatVector) std::vector<float>;
%template(DoubleVector) std::vector<double>;

/*******************************************************************
 * Python specific: numpy array <-> C++ pointer interface
 *******************************************************************/

%{
PyObject *swig_ptr (PyObject *a)
{
    if(!PyArray_Check(a)) {
        PyErr_SetString(PyExc_ValueError, "input not a numpy array");
        return NULL;
    }
    PyArrayObject *ao = (PyArrayObject *)a;

    if(!PyArray_ISCONTIGUOUS(ao)) {
        PyErr_SetString(PyExc_ValueError, "array is not C-contiguous");
        return NULL;
    }
    void * data = PyArray_DATA(ao);
    if(PyArray_TYPE(ao) == NPY_FLOAT32) {
        return SWIG_NewPointerObj(data, SWIGTYPE_p_float, 0);
    }
    //if(PyArray_TYPE(ao) == NPY_FLOAT64) {
    //    return SWIG_NewPointerObj(data, SWIGTYPE_p_double, 0);
    //}
    if(PyArray_TYPE(ao) == NPY_INT32) {
        return SWIG_NewPointerObj(data, SWIGTYPE_p_int, 0);
    }
    if(PyArray_TYPE(ao) == NPY_UINT8) {
        return SWIG_NewPointerObj(data, SWIGTYPE_p_unsigned_char, 0);
    }
    if(PyArray_TYPE(ao) == NPY_INT8) {
        return SWIG_NewPointerObj(data, SWIGTYPE_p_char, 0);
    }
    if(PyArray_TYPE(ao) == NPY_UINT64) {
#ifdef SWIGWORDSIZE64
        return SWIG_NewPointerObj(data, SWIGTYPE_p_unsigned_long, 0);
#else
        return SWIG_NewPointerObj(data, SWIGTYPE_p_unsigned_long_long, 0);
#endif
    }
    if(PyArray_TYPE(ao) == NPY_INT64) {
#ifdef SWIGWORDSIZE64
        return SWIG_NewPointerObj(data, SWIGTYPE_p_long, 0);
#else
        return SWIG_NewPointerObj(data, SWIGTYPE_p_long_long, 0);
#endif
    }
    PyErr_SetString(PyExc_ValueError, "did not recognize array type");
    return NULL;
}

%}

%init %{
    import_array();
%}

// return a pointer usable as input for functions that expect pointers
PyObject *swig_ptr (PyObject *a);

%define REV_SWIG_PTR(ctype, numpytype)

%{
PyObject * rev_swig_ptr(ctype *src, npy_intp size) {
    return PyArray_SimpleNewFromData(1, &size, numpytype, src);
}
%}

PyObject * rev_swig_ptr(ctype *src, size_t size);

%enddef

REV_SWIG_PTR(float, NPY_FLOAT32);
REV_SWIG_PTR(int, NPY_INT32);
REV_SWIG_PTR(unsigned char, NPY_UINT8);
REV_SWIG_PTR(int64_t, NPY_INT64);
REV_SWIG_PTR(uint64_t, NPY_UINT64);
