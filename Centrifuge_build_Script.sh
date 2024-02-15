#!/bin/bash

# make directory
mkdir database
cd database

centrifuge-download -P 16 -o taxonomy taxonomy
# centrifuge-download will download name.dmp and node.dmp file from NCBI taxonomy
# -P 50: Specifies the number of processes to use during the download
# -o is for output directory

centrifuge-download -P 16 -o library -d "bacteria,viral" refseq > seqid2taxid.map
 ## -d <domain> What domain to download. One or more of bacteria, 
 # viral, archaea, fungi, protozoa, invertebrate, plant, vertebrate_mammalian,
 # vertebrate_other (comma separated).
 ## -P <# no of threads>
 ##  refseq: Indicates that genomic sequences should be downloaded from the RefSeq database 


# add more fungi genome.(these fungi are known as human pathogens and were not present in refseq database )
# taxid was varified with edirect edirect_script.sh
# 17 species of fungi were added from genbank 
centrifuge-download -P 16 -o library -d "fungi" -t 746128,5059,5061,33178,5476,498019,42374,5478,4909,36911,5480,5482,5207,58839,5551,523103 genbank >> seqid2taxid.map


## Add Human genome
centrifuge-download -o library -d "vertebrate_mammalian" \
                    -a "Chromosome" -t 9606 -c 'reference genome' refseq >> seqid2taxid.map

#Combine all the fasta files in to one input-sequence file
#(combine all fasta files of bacteria)

find library/bacteria/ -name "*.fna" -print0 | xargs -0 cat > input-sequences.fna 
#cat bacteria/*.fna > input-sequences.fna
cat library/viral/*.fna >> input-sequences.fna
cat library/fungi/*.fna >> input-sequences.fna
cat library/vertebrate_mammalian/*.fna >> input-sequences.fna


# make new directory to store indxes build by centrifuge-build.
mkdir centrifuge_database

## Build index with centrifuge-build command with 50 threads
centrifuge-build -p 16 --conversion-table seqid2taxid.map \
                 --taxonomy-tree taxonomy/nodes.dmp --name-table taxonomy/names.dmp \
                 library/input-sequences.fna centrifuge_database/bfhv
                 
##### OR            
#centrifuge-build -a --bmax 1024 --conversion-table seqid2taxid.map \
 #                --taxonomy-tree taxonomy/nodes.dmp --name-table taxonomy/names.dmp \
    #             library/input-sequences.fna centrifuge_database/b+f+h+v               


                 
                 
                 