# Run mfinder to find motifs in an integrated network
# In this script $1 will be the sRNAs network and $2 the TF network
# Generate a simple 2 columns file for the sRNAs (remove self loops as well)
cut -f 1,3 -d " " $1 | tr " " "\t" | awk '$1!=$2 {print $0}' |sort |uniq >! sRNA_net.txt
# Do the same for the TFs
cut -f 1,3 -d " " $2 | tr " " "\t" | awk '$1!=$2 {print $0}' |sort |uniq >! TF_net.txt

# Generate indices for the nodes
cat sRNA_net.txt TF_net.txt | tr "\t" "\n" | sort | uniq | cat -n | awk '{print $2"\t"$1}' >! prot2index.txt
~assafp/E_coli/Network/bin/mfinder_progs/buildHashFromFile.pl prot2index.txt 0  1 prot2index.hash 0
~assafp/E_coli/Network/bin/mfinder_progs/transGene2Ind.pl sRNA_net.txt prot2index.hash
~assafp/E_coli/Network/bin/mfinder_progs/transGene2Ind.pl TF_net.txt  prot2index.hash
# Mark the sRNA network as 2 and TF as 1
cat sRNA_net.txt.ind |awk '{print $1"\t"$2"\t"2}' >! sRNA_net.net
cat TF_net.txt.ind | awk '{print $1"\t"$2"\t"1}' >! TF_net.net
# Integrate the networks 
cat *.net >! integrated_net.net.run
# Search for motifs of 3 edges using 100 shuffles
nohup ~assafp/E_coli/Network/bin/mfinder_progs/mfinder045r integrated_net.net.run -s 3 -r 100 -stvedc 2 -stmd -stvd -f integrated_motifs_s3_r100.out &
