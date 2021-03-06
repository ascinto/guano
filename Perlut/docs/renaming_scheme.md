# Renaming scheme

The initial names applied to the **.fastq** files automatically generated by NAU were simplified. The output from NAU for a file followed one of two naming conventions:

- `CONTROL-{SampleName}-xx-EN-USA-2017-076-JF_S{###}_L001_R1_001.fastq.gz` for mock community (positive) and negative control samples, with `SampleName` being specific to each sample, and `###` being either a two or three digit value assigned to the NAU sample sheet (effectively a redundant sample name they apply to each sample; shared with each forward and reverse **.fastq** file pair)
- `NHCS-{SampleName}-xx-VE-USA-2017-076-JF_S{###}_L001_R2_001.fastq.gz` for all true samples, following the same naming scheme as described above

The goal was to produce file names with the following scheme: `{SampleName}_{barcode}_L001_R{#}_001.fastq.gz`.

The following steps were applied to the files to achieve that:
> Note that raw files were downloaded to a subdirectory within the main project folder `Perlut`, thus these raw `.fastq.gz` files all reside in `.../path/to/Perlut/fqraw`  

Samples will start out looking something like this:
```
CONTROL-extBlankA07-xx-xx-USA-2017-076-JF_S38_L001_R1_001.fastq.gz
CONTROL-extBlankA07-xx-xx-USA-2017-076-JF_S38_L001_R2_001.fastq.gz
CONTROL-extBlankB11-xx-xx-USA-2017-076-JF_S47_L001_R1_001.fastq.gz
CONTROL-extBlankB11-xx-xx-USA-2017-076-JF_S47_L001_R2_001.fastq.gz
...
NHCS-une74-xx-VE-USA-2017-076-JF_S35_L001_R1_001.fastq.gz
NHCS-une74-xx-VE-USA-2017-076-JF_S35_L001_R2_001.fastq.gz
NHCS-une76-xx-VE-USA-2017-076-JF_S69_L001_R1_001.fastq.gz
NHCS-une76-xx-VE-USA-2017-076-JF_S69_L001_R2_001.fastq.gz
```

1. Start by stripping off all the parts of the `.fastq.gz` files you don't want.
```
for i in *.gz; do mv "$i" "$(echo "$i" | sed -e 's/NHCS-//' | sed -e 's/CONTROL-//' | sed -e 's/-.*._L/_L/' | sed -e 's/une/une-/' - )"; done
```
This should create a list of files that now look something like this:  

```
extBlankA07_L001_R1_001.fastq.gz
extBlankA07_L001_R2_001.fastq.gz
extBlankB11_L001_R1_001.fastq.gz
extBlankB11_L001_R2_001.fastq.gz
...
une-74_L001_R1_001.fastq.gz
une-74_L001_R2_001.fastq.gz
une-76_L001_R1_001.fastq.gz
une-76_L001_R2_001.fastq.gz
```

2. Create a text file which is just a list of those `fastq.gz` filenames as they currently exist (we'll use this list to build in a file used to substitute one list of names with another):  
```
find . -name "*.gz" | sort | sed -e 's|^\./||' > raw_filelist.txt
cat raw_filelist.txt > tmp_filelist.txt
```

3. Create a barcode list and replace `+` character with `-`. File was obtained from **Run Indexing QC** tab from [this sheet](https://docs.google.com/spreadsheets/d/1HM1Wlbai3aSHFAxqTNZ19zt7g_H8hf4ZlB8fvw4TlFQ/edit#gid=0). Copy the sample ID and barcode ID's from sheet and paste in new file called `tmp.txt`. Then create a `raw_barcodelist.txt` file to match our sorted list of downloaded .fastq.gz files. Using the new `raw_barcodelist.txt` file, used `sed` to replace the `+` character with a `-` delimiter:
```
nano tmp.txt
  # paste in two columns of data, then name, save, and quit program
sort -k1,1 tmp.txt | awk '{print $2}' | sed -i 's/+/-/' > raw_barcodelist.txt
```

4. Make duplicate of that barcode list, printing same value for a total of two identical strings among two rows.
```
perl -ne 'for$i(0..1){print}' raw_barcodelist.txt > tmp_barcodelist.txt
```

5. Create the left and right edges of the file list you want:
```
cut -d '_' -f 1 tmp_filelist.txt > left.txt
cut -d '_' -f 2-4 tmp_filelist.txt > right.txt
```

6. Now paste it all together to create the final filelist.txt you want to substitute with:
```
paste left.txt tmp_barcodelist.txt right.txt -d "_" > wanted_filelist.txt
```

7. Create a two-column text file containing the initial `tmp_filelist.txt` as the first column (the thing you are substituting), with the `final_filelist.txt` names you'll be replacing with:
```
paste tmp_filelist.txt wanted_filelist.txt > final_filelist.txt
```

8. Use that `final_filelist.txt` and pass this argument to rename all the files:
```
xargs -a final_filelist.txt -n 2 mv
```

This should rename all the files so that they now look something like this (compare to the inital structure from *step 1*:

```
extBlankA07_GTCTATGA-ACGACGTG_L001_R1_001.fastq.gz
extBlankA07_GTCTATGA-ACGACGTG_L001_R2_001.fastq.gz
extBlankB11_ACGCTACT-ATATACAC_L001_R1_001.fastq.gz
extBlankB11_ACGCTACT-ATATACAC_L001_R2_001.fastq.gz
...
une-74_CGAGCGAC-TAGTGTAG_L001_R1_001.fastq.gz
une-74_CGAGCGAC-TAGTGTAG_L001_R2_001.fastq.gz
une-76_GTCTGCTA-TAGTGTAG_L001_R1_001.fastq.gz
une-76_GTCTGCTA-TAGTGTAG_L001_R2_001.fastq.gz
```

Remove the unwanted `.txt` files from the directory and you're ready to start with the `amptk `pipeline:

```
rm *.txt
```
