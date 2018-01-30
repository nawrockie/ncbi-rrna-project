EPN, Fri Jan 26 09:14:41 2018
EPN, Tue Jan 30 05:56:56 2018 [microsporidia addition]

4 sets of files:
1. 118383.20180110
2. 81505.20180112 (subset of 1)
3. 48786.20180119 (subset of 2)

4. micro.687.20180129.fa
------------------
1. 118383.20180110: 

118,383 sequences that survived this idfetch (same as Entrez as far as
I know) query: 

idfetch -dn -c2 -q "Eukaryota[orgn] AND
1500:10000[slen] AND (18S[ti] OR small subunit ribosomal RNA[ti]) NOT
WGS[filter] NOT mRNA[filter] NOT mitochondrion[filter] NOT
plastid[filter] NOT chloroplast[filter] NOT plastid[ti] NOT
chloroplast[ti] NOT mitochondrial[ti] NOT REfSeq[filter] NOT (5.8s[ti]
OR internal[ti]) NOT 28S[ti] NOT TLS[ti]" -n > $1

This returns GIs, they were then used to fetch the sequences with
idfetch like this:
idfetch -t 5 -c 1 -G

Then sequence names were shorted to just accession.version with this
script: 
> ls -ltr fasta-long2short-names.pl 
-rw-r--r-- 1 nawrocke oblast 289 Jan 30 05:59 fasta-long2short-names.pl

And the names of the sequences in that file were saved:
> esl-seqstat -a 118383.20180110.fa | grep ^= | awk '{ print $2 }' > 118383.20180110.list

> ls -ltr 118383.20180110.list 
-rw-r--r-- 1 nawrocke oblast 1297105 Jan 26 09:19 118383.20180110.list

--

> esl-seqstat 118383.20180110.fa
Format:              FASTA
Alphabet type:       DNA
Number of sequences: 118383
Total # residues:    210830805
Smallest:            1500
Largest:             9943
Average length:      1780.9

> ls -ltr 118383.20180110.fa
-rw-r--r-- 1 nawrocke oblast 224388984 Jan 26 09:18 118383.20180110.fa
> gzip 118383.20180110.fa
> ls -ltr 118383.20180110.fa.gz
-rw-r--r-- 1 nawrocke oblast 24047143 Jan 26 09:18 118383.20180110.fa.gz

----------------------
2. 81505.20180112: 

81,505 sequences, a subset of the 118,383 sequences that survived: 

118,383 seqs returned from idfetch/Entrez query
95,970 remain after filtering for formal names
81,525 remain after filtering for seqs with 0 ambiguous nts
81,505 remain after removing seqs with non-weak VecScreen matches

> ls -ltr 81505.20180112.list 
-rw-r--r-- 1 nawrocke oblast 893971 Jan 26 09:20 81505.20180112.list

> esl-seqstat 81505.20180112.fa
Format:              FASTA
Alphabet type:       DNA
Number of sequences: 81505
Total # residues:    144882317
Smallest:            1500
Largest:             9943
Average length:      1777.6
> ls -ltr 81505.20180112.fa
-rw-r--r-- 1 nawrocke oblast 154286848 Jan 26 09:30 81505.20180112.fa
> gzip 81505.20180112.fa
> ls -ltr 81505.20180112.fa.gz
-rw-r--r-- 1 nawrocke oblast 16522292 Jan 26 09:30 81505.20180112.fa.gz

-----------------------
3. 48786.20180119: 

48,786 sequences, a subset of the 81,505 sequences that survived: 

[See /panfs/pan1/infernal/notebook/18_0112_rrna_18S/00LOG.txt for more
details, this sequence set was referred to as: bg60-81505-x12.48786 in
those notes.]

81,505 remain after removing seqs with non-weak VecScreen matches
66,590 pass ribotyper and ribolengthchecker with options listed below
48,786 remain after removing seqs that do not extend to within 60
       positions of the Rfam 5' and 3' model boundary

ribotyper.pl options:
1. --inaccept ssu.euk.accept: only seqs with top hit to the SSU-euk
   18S model will pass
2. --lowppossc 0.75: strict score requirement, only hits with 0.75
   bits per position
   will pass, 0.5 is the default.
4. --tcov 0.99: very strict requirement of 99% coverage (99% of the
   sequence must
   be covered by the top hit)
5. --multfail: any sequence with > 1 hit will fail (includes >90% of
   group I intron containing seqs)
6. --difffail: sequence for which the difference between the scores of
   the top two hits of models from different domains is very low (<
   0.1 bits per position) will fail (there were very few of these).

ribolengthchecker takes all sequences that pass ribotyper, run with
above options, and removes more sequences. Specifically any sequence
that is classified as 'full-extra' or 'full-ambig' is removed, such
that only 'full-exact' and 'partial' sequences remain (definitions
below).

ribolengthchecker.pl length definitions:
'full-exact': spans full model and no 5' or 3' inserts
              and no indels in first or final 10 model positions
'full-extra': spans full model but has 5' and/or 3' inserts
'full-ambig': spans full model and no 5' or 3' inserts
              but has indel(s) in first and/or final 10 model positions
'partial:' does not span full model

<[(sequence-files)]> ls -ltr 48786.20180119.list
-rw-r--r-- 1 nawrocke oblast 534666 Jan 26 10:03 48786.20180119.list

<[(sequence-files)]> esl-seqstat 48786.20180119.fa
Format:              FASTA
Alphabet type:       DNA
Number of sequences: 48786
Total # residues:    86981242
Smallest:            1502
Largest:             2584
Average length:      1782.9
<[(sequence-files)]> ls -ltr 48786.20180119.fa
-rw-r--r-- 1 nawrocke oblast 92563050 Jan 26 09:21 48786.20180119.fa
<[(sequence-files)]> gzip 48786.20180119.fa
<[(sequence-files)]> ls -ltr 48786.20180119.fa.gz
-rw-r--r-- 1 nawrocke oblast 9698627 Jan 26 09:21 48786.20180119.fa.gz

---------------------------------
4. micro.687.20180129: 

687 sequences that survived this idfetch (same as Entrez as far as
I know) query: 

idfetch -dn -c2 -q "txid6029[Organism:exp] AND 1100:18000 [slen] (18S [ti] OR small subunit ribosomal RNA [ti]) NOT WGS [filter] NOT mRNA [filter] NOT \"mitochondrion\"[Filter] NOT plastid [filter] NOT chloroplast [filter] NOT plastid [ti] NOT chloroplast [ti] NOT mitochondrial [ti] NOT RefSeq [filter] NOT (5.8S [ti] OR internal [ti]) NOT 28S [ti] NOT WGS NOT mRNA NOT "mitochondrion"[Filter] NOT RefSeq [filter] NOT TLS [ti]" -n

This returns GIs, they were then used to fetch the sequences with
idfetch like this:
idfetch -t 5 -c 1 -G

Then sequence names were shorted to just accession.version with this
script: 
> ls -ltr fasta-long2short-names.pl 
-rw-r--r-- 1 nawrocke oblast 289 Jan 30 05:59 fasta-long2short-names.pl

And the names of the sequences in that file were saved:
> esl-seqstat -a micro.687.fa | grep ^= | awk '{ print $2 }' > micro.687.list

--
> ls -ltr micro.687.20180129.list 
-rw-r--r-- 1 nawrocke oblast 7507 Jan 30 05:56 micro.687.20180129.list

<[(sequence-files)]> esl-seqstat micro.687.20180129.fa
Format:              FASTA
Alphabet type:       DNA
Number of sequences: 687
Total # residues:    865010
Smallest:            1100
Largest:             4319
Average length:      1259.1

> ls -ltr micro.687.20180129.fa
-rw-r--r-- 1 nawrocke oblast 943633 Jan 30 05:56 micro.687.20180129.fa
> gzip micro.687.20180129.fa
> ls -ltr micro.687.20180129.fa.gz
-rw-r--r-- 1 nawrocke oblast 120894 Jan 30 05:56 micro.687.20180129.fa.gz

----------------------
