This repository contains the data and code necessary to replicate the paper *Estimated effect of decriminalization on opioid overdose mortality rates in Oregon, USA*. Academia Global and Public Health. 2026. The paper can be found here: https://www.academia.edu/3071-0324/2/2/10.20935/AcadPHealth8252

This repository contains the supplementary files and the replication code. This document describes the content of the repository and adds some additional notes about handling the data.

# Introduction
This article uses mortality data from Oregon and its neighboring states to assess whether decriminalization of opioid possession in Oregon was associated with an increase in opioid overdose mortality rates. Data was downloaded from CDC Wonder, and a standard difference-in-difference model was applied to the mortality trend. The paper also uses two different methods (Joinpoint regression and a likelihood comparison) to identify the optimal changepoint in the mortality trend for each state. 

Because the reviewers asked for some additional analysis, the repository includes some R code that was used to do a perfunctory reanalysis of a paper by Zoorob et al, which we referenced, in particular to examine the fentanyl seizure data they used in their analysis. Finally, we made some assumptions about Idaho's mortality trend, and I have added a small analysis (in a separate do file) to confirm that the effect of those assumptions was minimal.

# Repository contents
The files contained in this repository and their contents are summarized in Table 1.

| File | File type | Contents |
| ---| --- | ---|
| Article.pdf | pdf file | The original article |
| Supplementary file.docx | Word document | Supplementary materials |
| fentanyl_oregon_replication_dataverse | Folders | Replication package for Zoorob et al |
| Supplementary File X1.xlsx | Excel file | DiD model outputs |
| fullFile.dta | Stata Data file | Basic mortality data |
| analysis file.do | Stata do file | Code for paper and Supplementary files |
| Fentanyl and zoorob reanalysis code.R | R script | Code for Zoorob reanalysis |
| joinpoint data.xlsx | Excel file | Data to use in the Joinpoint regression |

In order to reproduce Figures 1-3 and Tables 1 and 2 of the main text, as well as Figures S1-S5 and S10 of the Supplementary file, you simply need to place the Stata file *fullFile.dta* into a working directory and run the Stata do file *analysis file.do*. To produce Figure S11 you need to put the Zoorob replication package (*fentanyl_oregon_replication_dataverse*) into a working directory, and then run the R code *Fentanyl and zoorob reanalysis code.R*. 

To replicate the Joinpoint results, you need to download and install the Joinpoint software (from https://surveillance.cancer.gov/joinpoint/), and upload the Excel file *jpFile20260429.xlsx*. You can play around with changing the max number of joinpoints if you want. I don't know if Joinpoint produces different results on different computers, and I did it all in menus, so I don't include that replication process directly here (it's quite trivial though).

# About the Difference in difference model
The difference-in-difference (DiD) model used in this analysis is the formally correct, traditional DiD used by epidemiologists, which uses separate binary variables for intervention period and intervention group, along with their interaction. I have added to this a time trend, and all the interaction terms necessary to check for a change in trend associated with the intervention. This is a basic statistical method and requires no special explication. It enables us to test for a change in level *and* trend when the intervention occurs, along with non-parallel trends before *and* after the intervention begins.

I know that in some quarters people like to use two way fixed effect (TWFE) regressions for DiD models, along with all their variations, but I have not done so for two reasons:

1. They are always invalid when you have non-parallel trends (which we definitely have in this case)
2. They are generally bad statistics, they don't work, and they should be deprecated

You don't need any special statistics training to understand the output from the classical DiD model, but it involves lots of linear combinations, which can be a bit fiddly. Ganbatte!

# Stata file
The Stata do file requires only the input data file *fullFile.dta*. Put this in your working directory, set this working directory inside the do file, and you should be able to run through producing all the results without effort. Note that the file will produce a large amount of extra files, because it produces:
- some temporary data files used at various points
- a bunch of .gph files, some of which are combined to make other .gph files
- a bunch of .png files
- An excel output file (to upload to the Joinpoint regression)

It does *not* produce Supplementary File X1 (the excel file of results), which I prepared with good old-fashioned copy-paste from the results window, so please do that yourself.

Also please note I use a Studio Ghibli palette by default (see <a href="https://global-health-data-laboratory.ghost.io/scheme-ghibli-how-to-set-a-palette-in-stata/">here</a> for a guide to how to do this), which means my color options within the twoway commands are a bit bespoke. If you want to produce graphs in your own color scheme you'll need to fiddle with those parts of the twoway commands. Sorry!

Note that I have deleted the working directory from the Stata file (so it is just *cd ""*) for security reasons.

# R code
Two previous papers have studied the effect of decriminalization on mortality, which we referenced in the introduction. One of these, *Drug Decriminalization, Fentanyl, and Fatal Overdoses in Oregon*, by Zoorob et al (JAMA Network Open. 2024;7(9):e2431612), included fentanyl seizure data as part of its regression, and conducted a TWFE DiD model. We claimed in the introduction that this paper was flawed (due to the TWFE) and did not settle the question.

As part of the peer review process two reviewers disputed our claim that Zoorob et al's paper was flawed, and also asked us to defend our decision not to use fentanyl seizure data as a covariate in our analysis. In order to answer these questions we found a replication package for Zoorob et al, and wrote some R code (based on Zoorob's original code) to check their methods and the fentanyl data. This code produced Supplementary Figure S11. I include this R code in this repository. To use this R code, you need to put the entire replication package (all the folders and sub-folders) into your working directory, then put the working directory location in the first line of the R code. It should then produce Figure S11 by default, if you just run the whole file. Note that I have deleted my directory structure from the *setwd()* command, so please fill it in.

In response to the reviewer, we gave the following argument (copy-pasted here from our response to reviewers):

> Drug seizure data in the NFLIS does not have complete coverage, and may not be comparable between states. For example, only five sites of the Oregon State Police Forensic Division participate in the NFLIS, while in California the NFLIS covers state and city police departments, some offices of the Attorneys General, and some county sheriff’s departments (1) In Oregon, for example, only slightly more than 10% of all asset forfeitures are conducted by the jurisdiction that participates in NFLIS (2). In comparison with mortality data, which is complete, NFLIS data is not comparable between states, which might explain why (for example) Washington had a much higher proportion of seizures than California, since only the Washington State Patrol contributes to the database, while California police from all jurisdictions contribute.

In regard to other criticism of Zoorob, we did note that the results of the analysis used by Zoorob depend entirely on the choice of comparison states. Zoorob used all other US states as controls, while we used neighbors. The difference is large. I may include some of that analysis is an update to this document.

# A note on sensitivity analysis
Careful investigation of *fullFile.dta* will reveal that the data for Idaho has some missing values in some months. This is due to suppression of small death counts in the CDC Wonder data (deaths between 1-9 are set to missing). Most of the analyses conducted for this paper used those missing data as they were, without doing anything about them. Zoorob et al filled them in using a uniform random number between 1 and 9. There is another cute method you can use in which you construct a special distribution for the missing data (I need to publish a paper on this!) However, we didn't do anything with them, and did not apply Joinpoint analysis to Idaho. 

There are two steps in the analysis, however, where we set these missing values to 0. This *may* influence the Log-likelihod estimate for the change points in Figure 2, though I doubt it (in fact this analysis can be done with the missing data included, but for some stupid reason I didn't). Also, when we pool the neighboring states for the Difference in Difference model, we had to set these values to 0 so the *collapse* command would work. This slightly underestimates some death counts in the non-intervention states before 2019, but the effect should be tiny. For example there are usually >150 deaths in California, and <9 deaths in the missing cells, so setting them to 0 will underestimate total deaths by much less than 9/150. I don't think it matters.

After we completed peer review of this paper, we obtained a complete data set of mortality for all states (not from the Zoorob et al replication package). I will add this data to the repository and include a separate do file with a sensitivity analysis for this complete data. I will update this readme when I do this.

# A note on the peer review
This paper went out to 4 peer reviews and underwent two rounds of peer review. In response to the reviewers' points we had to:
- find the Zoorob et al replication package, reproduce their results and compare them with ours
- Do extensive additional literature review to find more information about the timing and impact of decriminalization
- Conduct several additional sensitivity analyses for our basic analysis

During this peer review the reviewers were thorough, attentive and interested, and it was a good experience that improved our paper significantly (thanks guys!) I may upload some of the work we did for these reviewers in a future update to this repository.

# References
1.	Division DC. NFLIS-DRUG 2022 annual report. Springfield, VA, USA: US Department of Justice; 2023.
2.	Sanchagrin K. Asset Forfeiture (2024) Report. Portland, Oregon, USA: State of Oregon; 2025.

