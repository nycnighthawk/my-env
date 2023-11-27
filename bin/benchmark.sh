command -v sysbench \
&& sysbench cpu --threads=10 run \
&& sysbench threads --threads=10 run \
&& sysbench fileio --file-test-mode=seqrewr --threads=10 prepare \
&& sysbench fileio --file-test-mode=seqrewr --threads=10 run \
&& sysbench fileio --file-test-mode=rndrw --threads=10 run \
&& sysbench fileio cleanup
