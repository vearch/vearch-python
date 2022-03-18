import vearch
import time
import numpy as np
print("create table")
engine = vearch.Engine("files", "logs")      
table = {
    "name" : "test_table",
    "engine" : {
        "index_size": 50000,
        "retrieval_type": "VEARCH",
        "retrieval_param": {
            "metric_type": "InnerProduct",
            "ncentroids": 512,
            "nsubvector": 256,
            "reordering": True
        }
    },
    "properties" : {
        "feature": {
            "type": "vector",
            "dimension": 512,
            "store_type": "Mmap"
        }
    }
}
engine.create_table(table)
print("add data")
add_num = 100000
X = np.random.rand(add_num, 512).astype('float32')
engine.add2(X)
print("search")
nprobe, rerank, query_num= 20, 100, 10
engine.set_nprobe(nprobe)
engine.set_rerank(rerank)
Q = np.random.rand(query_num, 512).astype('float32')
indexed_num = 0
while indexed_num != X.shape[0]:
    indexed_num = engine.get_status()['min_indexed_num']
    time.sleep(1)
engine.search2(Q, query_num)

