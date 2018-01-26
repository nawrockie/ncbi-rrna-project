# EPN, Fri Jan 26 09:05:44 2018

taxonomy-tree.20180123.txt

cp /am/ftp-private/ncbitax/taxdump.tar.gz .
gunzip /am/ftp-private/ncbitax/taxdump.tar.gz

ls -ltr taxdump.tar 
-rw-r--r-- 1 nawrocke oblast 677386240 Jan 23 09:49 taxdump.tar
tar xvf /am/ftp-private/ncbitax/taxdump.tar

cut -f1,3,5 nodes.dmp > taxonomy_tree.20180123txt

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
