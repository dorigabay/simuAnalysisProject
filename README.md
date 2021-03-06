# The simuAnalysisPoject

A python package to analyze computational simulations of protein dynamics results from either the atomistic (XTC file format) or the coarse-grain models (DAT file format). This tool calculates the mean Radius of Gyration (RG), the distance between two specified residues, and the approximate FRET measurement for each simulation time point. It saves all the repeated results in one CSV file. Also, the tool enables you to predict the Length Scaling Exponent (LSE, or Flory calculation of the exponent) by fitting Flory’s formula with the results: 

<img src="/pics/flory_formula.JPG" width="100">

For the coarse grain model, this tool takes any depth of the directory, searches for the output of Koby’s Lab coarse-grained simulation program, and exports the analysis results in a new directory with the same tree structure as the input directory. \
For the atomistic model, this tool takes all the XTC files in the input directory and considers them as repeats of the same experiment.

## Configuration file:
First, make sure to have a configuration file in the directory of results to be analyzed.\
Configuration file name does not matter, only **its suffix needs to be '.config'**\
The configuration file should be written with a row for each sequence to be analyzed, as follows: sequenceName,residue1position,residue2position\
Example:
~~~
seq1,1,12
seq2,1,12
seq3,1,12
~~~
If you know the estimated Length Scaling Exponent, and you want to calculate the FRET measurements then you should add a 4th column:
~~~
seq1,1,12,0.77
~~~
Sequences names should be precise as typed in the command.


## Installation:

Clone GitHub repository to your local machine with the following command:
``` r
git clone https://github.com/dorigabay/simuAnalysisProject.git
```
Next, make sure you have all the dependencies for this tool (check: dependencies.txt)
You can add an alias to this tool by editing your .bashrc script:
``` r
vi ~/.bashrc
```
And then add the line:
``` r
alias simuAnalysis='python3 theRepoPath/simuAnalysis.py'
```

## How to use the tool:

You can download an example results for short simulations of small proteins (12 residues) [(from here)](https://download-directory.github.io/?url=https%3A%2F%2Fgithub.com%2Fdorigabay%2Fdorigabay.github.io%2Ftree%2Fmain%2FsimuAnalysisProject%2FExample). Those are simulations results which ran under both the atomistic and the coarse-grain model. 

### Coarse-grain analysis
simuAnalysis will search for the output directories which were given by the simulation program, and will unzip the files and convert them, if it hasn’t been made yet.
In order to analyze the coarse results you can simply type:
``` r
simuAnalysis --simulationType coarse --d pathToThisRepo/Example/coarse
```
The analysis products will be saved as CSV files in a new directory named AnalyzedData, which has the same tree structure as the input directory, to preserve the order of directories to different experiments. If wanted you can change the output path by adding ```--outputDir``` argument:
``` r
simuAnalysis --simulationType coarse --d pathToThisRepo/Example/coarse --outputDir newPath
```
In order to trim the beginning or the end of the simulation you can add ```--start``` or ```--end``` or both:
``` r
simuAnalysis --simulationType coarse --d pathToThisRepo/Example/coarse --start nStep --end nStep
```

### Atomistic analysis
For the simple analysis of atomistic XTC files, simply type:
``` r
simuAnalysis --simulationType atomistic --d pathToThisRepo/Example/atomistic/seq1 --seqName seq1
```
The analysis products will be saved as CSV files in a new directory named AnalyzedData, if wanted you can change the output path by adding ```-out``` argument:
``` r
simuAnalysis --simulationType atomistic --d pathToThisRepo/Example/atomistic/seq1 --seqName seq1 --outputDir newPath
```
In order to trim the beginning or the end of the simulation you can add ```--start``` or ```--end``` or both:
``` r
simuAnalysis --simulationType atomistic --d pathToThisRepo/Example/atomistic/seq1 --seqName seq1 --start nStep --end nStep
```
Additional to those calculations that are also available for the coarse-grain model, simuAnalysis provides a function to estimate FRET measurement (If the Flory Exponent is already known). The value of the exponent needs to be added to the configuration file, as the third element of the query sequence (already been added to the example). With the command use: ``` --calcFRET```. The results will be added to the CSV output file.\
\
If the expected Flory Exponent of the sequence isn’t yet known, you can try to extimate it by using ```--calcLSE.``` This will make simuAnalysis to spit out a figure with the Flory formula fitted to the observed results. If the fitted curve is firmly satisfying, the exponent can be extracted manually (denoted as the parameter ‘b’). 
