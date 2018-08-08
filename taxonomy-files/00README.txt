EPN, Fri Jan 26 09:05:44 2018
EPN, Tue Jan 30 06:02:39 2018 [microsporidia added]
EPN, Wed Feb 14 08:58:31 2018 [taxonomy]

-----------------------------------
TO update 
taxonomy_tree_ribodbmaker.txt 
and
taxonomy_tree_wlevels.txt 

> sh update-for-ribodbmaker.sh

> cat update-for-ribodbmaker.sh
#!/bin/bash

if [ ! "$BASH_VERSION" ] ; then
    echo "Please do not use sh to run this script ($0), just execute it directly, e.g.\n'update-for-ribodbmaker.sh'" 1>&2
    exit 1
fi


if [ ! "$VECPLUSDIR" ] ; then
    echo "The VECPLUSDIR environment variable is not set. Please set it to the directory where vecscreen_plus_taxonomy is installed, e.g.:\n'export VECPLUSDIR=/PATH-TO-VECPLUSTAXONOMY/'" 1>&2
    exit 1
fi

cp /am/ftp-private/ncbitax/taxdump_new.tar.gz .
gunzip -f taxdump_new.tar.gz
tar xf taxdump_new.tar
cut -f1,3,5 nodes.dmp > taxonomy_tree.txt
cut -f31 nodes.dmp > specified_column.txt
$VECPLUSDIR/scripts/assign_levels_to_taxonomy.pl --input_taxa taxonomy_tree.txt --outfile taxonomy_tree_wlevels.txt
paste taxonomy_tree_wlevels.txt specified_column.txt > taxonomy_tree_ribodbmaker.txt

----------------------------------
taxa_to_cover_v1.txt

Slightly modified version of the file "orders+detleflist.txt" posted
by Conrad Schoch to JIRA ticket TAXDATA-161 on 2/12/18.
https://jira.ncbi.nlm.nih.gov/browse/TAXDATA-161

Alejandro modified the file to resolve whitespace issues and renamed it.

original source:
/panfs/pan1/dnaorg/2018.01/18S/coverage_analysis/taxonomy_tree_wlevels.txt
-rw-r--r-- 1 schaffer oblast    19149 Feb 13 21:29 taxa_to_cover_v1.txt
------------------------------------
summarize_taxonomy_representatives.pl 

Written by Alejandro Schaffer.
Code to record which taxonomy ancestor representatives are covered in a set of sequences. 
A variant of check_taxonomy_representatives.pl that
outputs a summary as a second output file.

original source:
/panfs/pan1/dnaorg/2018.01/18S/coverage_analysis/taxonomy_tree_wlevels.txt
-rwxr-xr-x 1 schaffer oblast    14585 Feb 13 21:28 summarize_taxonomy_representatives.pl

=========================================
taxonomy-tree.20180123.txt

cp /am/ftp-private/ncbitax/taxdump.tar.gz .
gunzip /am/ftp-private/ncbitax/taxdump.tar.gz

ls -ltr taxdump.tar 
-rw-r--r-- 1 nawrocke oblast 677386240 Jan 23 09:49 taxdump.tar
tar xvf /am/ftp-private/ncbitax/taxdump.tar

cut -f1,3,5 nodes.dmp > taxonomy_tree.20180123.txt

original source:
/panfs/pan1/infernal/notebook/18_0112_rrna_18S/tax-analyses/taxonomy_tree.txt
-rw-r--r-- 1 nawrocke oblast 39326791 Jan 23 09:55 taxonomy_tree.20180123.txt

------------------------------------------
tax_info.118383.20180123.txt

command used to create the file:
srcchk -i 118383.list -f TaxID,taxname -o tax_info.118383.txt
 
original source:
panfs/pan1/infernal/notebook/18_0112_rrna_18S/tax-analyses/tax_info.118383.txt
> ls -ltr tax_info.118383.txt
-rw-r--r-- 1 nawrocke oblast 4896221 Jan 23 13:39 tax_info.118383.txt

Renamed with date:
> ls -ltr tax_info.118383.20180123.txt
-rw-r--r-- 1 nawrocke oblast 4896221 Jan 26 09:10 tax_info.118383.20180123.txt

--------------------------------------
tax_info.micro.687.20180129.txt

command used to create the file:
srcchk -i micro.687.list -f 'taxid,organism' > tax_info.micro.687.txt
 
original source:
/panfs/pan1/infernal/notebook/18_0112_rrna_18S/microsporidia-20180129
> ls -ltr tax_info.micro.687.txt 
-rw-r--r-- 1 nawrocke oblast 26351 Jan 29 20:33 tax_info.micro.687.txt

Renamed with date:
> ls -ltr tax_info.micro.687.20180129.txt 
-rw-r--r-- 1 nawrocke oblast 26351 Jan 30 05:52 tax_info.micro.687.20180129.txt

