* Analysis file for the paper "Estimated effect of decriminalization on opioid overdose mortality rates in Oregon, USA"
* published at Academia Global and Public Health, 2026/4/28

* data obtained from CDC wonder without age or race categories

* first set the working directory and load the file
* this working directory will be set to blank in the github file, please fill in with your own
* you will need to put the data file "fullFile.dta" in this directory. 

* note that I use a custom theme for colors, so please change all colors to values of your own
* choice

cd "/Users/Faustus/Stuart研 Dropbox/Stuart Gilmour/Research Current/Speculation/Oregon OD/Final Github"
use fullFile,clear


/******************************************************
*
* Figure 1
*
*******************************************************/
twoway (line rate timeVal if stateVal==1,lcolor($gh6) lwidth(medthick)) ///
	(line rate timeVal if stateVal==2,lcolor($gh8) lwidth(medthick)) ///
	(line rate timeVal if stateVal==3,lcolor($gh10) lwidth(medthick)) ///
	(line rate timeVal if stateVal==5,lcolor($gh15) lwidth(medthick)) ///	
	(line rate timeVal if stateVal==4,lcolor($gh1) lwidth(thick) xline(22312,lcol(gs8))), ///
	legend(label(1 "California") label(2 "Idaho") ///
		label(3 "Nevada") label(4 "Washington") label(5 "Oregon")) ///
	xlabels(20089 20820 21550 22281 23011) xtitle("Year") ytitle("Rate per 100,000")
graph save Figure1,replace
graph export fig1.png,replace

* brief summary investigation - count number of recrods with a missing death
gen missVal=(deaths==.)
tab missVal
tab stateVal missVal, row
* it's about half of all observations for Idaho - this will be an issue
/* for the state-specific analysis of  Idaho, but will make little difference to the overall DiD analysis (since Idaho is a tiny % of total deaths)

In the paper we set Idaho's missing deaths to 0 - we will do a sensitivity analysis of the key results (not included in the paper or peer review) to confirm no effect of this assumption*/
/********************************************
*
* Estimation of changepoints using Log likelihood
*
*********************************************/

* first need to make the offset for the Poisson regression
gen offS=ln(pop)


** now do the log-likelihood trick
* replace early missing data in Idaho with 0s. Don't need to do this for 
* the formal regressions, but for collapsing the data we need to do this

replace deaths=0 if deaths==.

* in this series february 2021 is tBase==74

keep tImpl stepVal deaths offS tBase stateVal
save stateLvlSimp20260429,replace
* do each loop separately because it's late and I'm feeling brain dead after kickboxing
* first California
keep if stateVal==1
forvalues i=49(1)90 {
	
	gen step2=tBase>=`i'
	gen timeVar2=tBase-`i'
	* run the poisson model
	poisson deaths timeVar2 i.step2 i.step2#c.timeVar2 ,offset(offS)
	gen stepEff`i'=_b[1.step2]
	gen slopeEff`i'=_b[1.step2#c.timeVar2]
	gen ll`i'=e(ll)
	local ll1=e(ll)
	* run without step
	poisson deaths timeVar2,offset(offS) 
	local ll2=e(ll)
	gen llDiff`i'=`ll2'-`ll1'
	drop timeVar2
	drop step2
}
* extract the ll values and plot
keep if _n==1
keep ll* llDiff* stepEff* slope* 
gen idVal=1
reshape long ll llDiff stepEff slopeEff,i(idVal) j(stepPoint)
gen stateVal=1
save llMod1,replace

* repeat for 2, Idaho
use stateLvlSimp20260429,clear
* do each loop separately because it's late and I'm feeling brain dead after kickboxing
* first California
keep if stateVal==2
forvalues i=49(1)90 {
	
	gen step2=tBase>=`i'
	gen timeVar2=tBase-`i'
	* run the poisson model
	poisson deaths timeVar2 i.step2 i.step2#c.timeVar2 ,offset(offS)
	gen stepEff`i'=_b[1.step2]
	gen slopeEff`i'=_b[1.step2#c.timeVar2]
	gen ll`i'=e(ll)
	local ll1=e(ll)
	* run without step
	poisson deaths timeVar2,offset(offS) 
	local ll2=e(ll)
	gen llDiff`i'=`ll2'-`ll1'
	drop timeVar2
	drop step2
}
* extract the ll values and plot
keep if _n==1
keep ll* llDiff* stepEff* slope* 
gen idVal=1
reshape long ll llDiff stepEff slopeEff,i(idVal) j(stepPoint)
gen stateVal=2
save llMod2,replace

* now for 3, Nevada
use stateLvlSimp20260429,clear

keep if stateVal==3
forvalues i=49(1)90 {
	
	gen step2=tBase>=`i'
	gen timeVar2=tBase-`i'
	* run the poisson model
	poisson deaths timeVar2 i.step2 i.step2#c.timeVar2 ,offset(offS)
	gen stepEff`i'=_b[1.step2]
	gen slopeEff`i'=_b[1.step2#c.timeVar2]
	gen ll`i'=e(ll)
	local ll1=e(ll)
	* run without step
	poisson deaths timeVar2,offset(offS) 
	local ll2=e(ll)
	gen llDiff`i'=`ll2'-`ll1'
	drop timeVar2
	drop step2
}
* extract the ll values and plot
keep if _n==1
keep ll* llDiff* stepEff* slope* 
gen idVal=1
reshape long ll llDiff stepEff slopeEff,i(idVal) j(stepPoint)
gen stateVal=3
save llMod3,replace

* now for 4, Oregon
use stateLvlSimp20260429,clear

keep if stateVal==4
forvalues i=49(1)90 {
	
	gen step2=tBase>=`i'
	gen timeVar2=tBase-`i'
	* run the poisson model
	poisson deaths timeVar2 i.step2 i.step2#c.timeVar2 ,offset(offS)
	gen stepEff`i'=_b[1.step2]
	gen slopeEff`i'=_b[1.step2#c.timeVar2]
	gen ll`i'=e(ll)
	local ll1=e(ll)
	* run without step
	poisson deaths timeVar2,offset(offS) 
	local ll2=e(ll)
	gen llDiff`i'=`ll2'-`ll1'
	drop timeVar2
	drop step2
}
* extract the ll values and plot
keep if _n==1
keep ll* llDiff* stepEff* slope* 
gen idVal=1
reshape long ll llDiff stepEff slopeEff,i(idVal) j(stepPoint)
gen stateVal=4
save llMod4,replace

* finally 5, Washington
use stateLvlSimp20260429,clear

keep if stateVal==5
forvalues i=49(1)90 {
	
	gen step2=tBase>=`i'
	gen timeVar2=tBase-`i'
	* run the poisson model
	poisson deaths timeVar2 i.step2 i.step2#c.timeVar2 ,offset(offS)
	gen stepEff`i'=_b[1.step2]
	gen slopeEff`i'=_b[1.step2#c.timeVar2]
	gen ll`i'=e(ll)
	local ll1=e(ll)
	* run without step
	poisson deaths timeVar2,offset(offS) 
	local ll2=e(ll)
	gen llDiff`i'=`ll2'-`ll1'
	drop timeVar2
	drop step2
}
* extract the ll values and plot
keep if _n==1
keep ll* llDiff* stepEff* slope* 
gen idVal=1
reshape long ll llDiff stepEff slopeEff,i(idVal) j(stepPoint)
gen stateVal=5
save llMod5,replace
append using llMod1 llMod2 llMod3 llMod4
label values stateVal stateVal
save llSet20260429,replace

* plot
* first we need to convert the step point to a date
* note 2015/1 is 1 and 2021/2 is 74
gen timeVal=ym(2015,1)+stepPoint-1
format timeVal %tm
save llSet20260429,replace

* now make Figure 2
* because of California's scale we need to make two plots 
* Exclude California from the left panel

* note the editor asked for a special minus symbol, so we need to use the
* little trick of defining a local variable with it and fixing the ticks
local arrow=ustrunescape("\u2212")
twoway 	(line llDiff timeVal if stateVal==2,lcolor($gh8) lwidth(medthick)) ///
	(line llDiff timeVal if stateVal==3,lcolor($gh10) lwidth(medthick)) ///
	(line llDiff timeVal if stateVal==5,lcolor($gh15) lwidth(medthick)) ///
	(line llDiff timeVal if stateVal==4,lcolor($gh1) lwidth(thick) xline(733,lcolor(gs8))), ///
	legend(label(1 "Idaho") ///
		label(2 "Nevada") label(3 "Washington") label(4 "Oregon")) ///
	xtitle("Intervention point") ytitle("Log-likelihood difference") ///
	subtitle("Small states") ///
	ylabel(-150 "`arrow'150" -100 "`arrow'100" -50 "`arrow'50" 0 "0")
	graph save llDiffSmall,replace

* now do the California panel
* same annoying trick with the minus	
local arrow=ustrunescape("\u2212")	
twoway 	(line llDiff timeVal if stateVal==1,lcolor($gh8) lwidth(medthick) xline(733,lcolor(gs8))), ///
	xtitle("Intervention point") ytitle("Log-likelihood difference") subtitle("California") ///
	ylabel(-400 "`arrow'400" -300 "`arrow'300" -200 "`arrow'200" -100 "`arrow'100")
	graph save llDiffLarge,replace

* combine
graph combine llDiffSmall.gph llDiffLarge.gph
graph save figure2,replace
graph export figure2.png,replace	
* next find the minima and point of minimum for each (a manual search should do it)]
sort stateVal
by stateVal: egen maxLL=min(llDiff)
gen maxVal=(llDiff==maxLL)
keep if maxVal==1
* these are:
/*
December 2019 for Oregon - this is 21884
March 2020 for Washington, California - this is 21975
April 2020 for NEvada - this is 22006
APril 2021 for Idaho - this is 22371
*/
save bestDatePoints20260429,replace


/*************************************
*
* State-specific regressions
*
*************************************/



/* For each state we do a separate regression with the optimal changepoint, and plot accordingly
first need to convert these months of intervention into timeVal, which is a number starting at 2015/1 */

use fullFile,clear

/* generate the offset and the time steps for each state based on the optima identified in Figure 2*/
gen offS=ln(pop)
gen tStep1=(timeVal>=21884)
gen tStep2=(timeVal>=21975)
gen tStep3=(timeVal>=22006)
gen tStep4=(timeVal>=22371)
gen tVar1=tBase-(ym(2019,12)-ym(2015,1))+1
gen tVar2=tBase-(ym(2020,3)-ym(2015,1))+1
gen tVar3=tBase-(ym(2020,4)-ym(2015,1))+1
gen tVar4=tBase-(ym(2021,4)-ym(2015,1))+1
* now do separate models for each state
* copy-pasting model results to a new spreadsheet
* first Oregon
poisson deaths tVar1 i.tStep1 i.tStep1#c.tVar1 if stateVal==4,offset(offS)
predict pDeaths1
gen pRate1=100000*pDeaths1/pop if stateVal==4
* need lincoms for the changes in slope
lincom 1.tStep1#c.tVar1+tVar1,eform

* next California
poisson deaths tVar2 i.tStep2 i.tStep2#c.tVar2 if stateVal==1,offset(offS)
predict pDeathsCal
gen pRateCal=100000*pDeathsCal/pop if stateVal==1
lincom 1.tStep2#c.tVar2+tVar2,eform

* next Washington
poisson deaths tVar2 i.tStep2 i.tStep2#c.tVar2 if stateVal==5,offset(offS)
predict pDeathsWash
gen pRateWash=100000*pDeathsWash/pop if stateVal==5
lincom 1.tStep2#c.tVar2+tVar2,eform

* Nevada
poisson deaths tVar3 i.tStep3 i.tStep3#c.tVar3 if stateVal==3,offset(offS)
predict pDeathsNev
gen pRateNev=100000*pDeathsNev/pop if stateVal==3
lincom 1.tStep3#c.tVar3+tVar3,eform

* Finally Idaho
* note that I originally did this with missing values retained
poisson deaths tVar4 i.tStep4 i.tStep4#c.tVar4 if stateVal==2,offset(offS)
predict pDeathsId
gen pRateId=100000*pDeathsId/pop if stateVal==2
lincom 1.tStep4#c.tVar4+tVar4,eform
*let's make a panel plot with these dates
* for each of thse plots I want to make a second, single plot that includes the decriminalization point, which is 22312 xline(22312,lcol(gs8))

/***** Make plots S2 - S5 using these predicted values *******/
* note that we make figure S1 later in the code (coz we're dumb)
* but we make a plot for Oregon here anyway, to go in Figure 3 of the
* main text
* oh joy!
twoway (line rate timeVal if stateVal==4,lcolor($gh1) lwidth(thick)) ///
	(line pRate1 timeVal if stateVal==4,lcolor($gh1) lwidth(thick) xline(21884,lcol(gs8))), ///
	xlabels(20089 21550 23011) xtitle("Year") ytitle("Rate per 100,000") subtitle("Oregon") legend(off)
graph save OregonPlot,replace

* now prepare a figure with California and Washington together
* - this will be a panel of Figure 3
twoway (line rate timeVal if stateVal==1,lcolor($gh6) lwidth(thick) ) ///
	(line pRateCal timeVal if stateVal==1,lcolor($gh6) lwidth(thick) ) ///
  (line rate timeVal if stateVal==5,lcolor($gh15) lwidth(thick) ) ///
  (line pRateWash timeVal if stateVal==5,lcolor($gh15) lwidth(thick) xline(21975,lcol(gs8))), ///
	xlabels(20089 21550 23011)  xtitle("Year") ytitle("Rate per 100,000") subtitle("California and Washington") ///
	legend(off)
graph save CaliWashPlot,replace

*** california by itself for Figure S2
twoway (line rate timeVal if stateVal==1,lcolor($gh1) lwidth(thick) xline(22312,lcol(red%40))) ///
	(line pRateCal timeVal if stateVal==1,lcolor($gh1) lwidth(thick) xline(21975,lcol(gs8))), ///
	xlabels(20089 21550 23011)  xtitle("Year") ytitle("Rate per 100,000") legend(off)
graph save suppS2,replace
graph export suppS2.tif,replace
graph export suppS2.png,replace
	
*** Washington by itsel for Figure S3
twoway (line rate timeVal if stateVal==5,lcolor($gh1) lwidth(thick) xline(22312,lcol(red%40))) ///
	(line pRateCal timeVal if stateVal==5,lcolor($gh1) lwidth(thick) xline(21975,lcol(gs8))), ///
	xlabels(20089 21550 23011)  xtitle("Year") ytitle("Rate per 100,000") legend(off)
graph save suppS3,replace
graph export suppS3.tif,replace
graph export suppS3.png,replace		
	
twoway (line rate timeVal if stateVal==3,lcolor($gh10) lwidth(thick)) ///
	(line pRateNev timeVal if stateVal==3,lcolor($gh10) lwidth(thick) xline(22006,lcol(gs8))), ///
	xlabels(20089 21550 23011) xtitle("Year") ytitle("Rate per 100,000") subtitle("Nevada")	legend(off)
	graph save nevadaPlot,replace
	
** Nevada for Figure S4	
twoway (line rate timeVal if stateVal==3,lcolor($gh1) lwidth(thick) xline(22312,lcol(red%40)) ) ///
	(line pRateNev timeVal if stateVal==3,lcolor($gh1) lwidth(thick) xline(22006,lcol(gs8))), ///
	xlabels(20089 21550 23011) xtitle("Year") ytitle("Rate per 100,000") legend(off)	
	
graph save suppS4,replace
graph export suppS4.tif,replace
graph export suppS4.png,replace	

*Idaho	 for Figure S5
twoway (line rate timeVal if stateVal==2,lcolor($gh8) lwidth(thick)) ///
(line pRateId timeVal if stateVal==2,lcolor($gh8) lwidth(thick) xline(22371,lcol(gs8))), /// ///
	xlabels(20089 21550 23011) xtitle("Year") ytitle("Rate per 100,000") subtitle("Idaho")	legend(off)	
	graph save idahoPlot,replace
	
twoway (line rate timeVal if stateVal==2,lcolor($gh1) lwidth(thick) xline(22312,lcol(red%40)) ) ///
(line pRateId timeVal if stateVal==2,lcolor($gh1) lwidth(thick) xline(22371,lcol(gs8))), /// ///
	xlabels(20089 21550 23011) xtitle("Year") ytitle("Rate per 100,000") legend(off)	
	
graph save suppS5,replace
graph export suppS5.tif,replace
graph export suppS5.png,replace		
/********************************************
*
* Make Figure 3
*
********************************************/
	
graph combine oregonPlot.gph CaliWashPlot.gph nevadaPlot.gph idahoPlot.gph
graph save figure3,replace
graph export figure3.png,replace
graph export figure3.tif,replace

/*************************************
*
* Now make Figure S1
*
*************************************/
* first let's do the regression models
* these have a change in level adn trend at the point of the intervention
* tImpl is the true date of the decriminalization
* tStep1 is the best date for Oregon
poisson deaths tVar1 i.tStep1 i.tStep1#c.tVar1 if stateVal==4,offset(offS)
poisson deaths tImpl i.stepVal i.stepVal#c.tImpl if stateVal==4,offset(offS)

* likelihoods: -366.11501 vs. -378.19474. Can't compare these directly, but the former is clearly better
* now predict
predict pDeathsWrong
gen pRateWrong=100000*pDeathsWrong/pop if stateVal==4

*plot
twoway (line rate timeVal if stateVal==4,lcolor($gh1) lwidth(thick) ) ///
	(line pRate1 timeVal if stateVal==4,lcolor($gh1) lwidth(thick) xline(21884,lcol(gs8))) ///
	(line pRateWrong timeVal if stateVal==4,lcolor($gh2) lwidth(thick) xline(22312,lcol(red%40))), ///
	xlabels(20089 21550 23011) xtitle("Year") ytitle("Rate per 100,000") legend(label(1 "Observed") label(2 "Modeled 201912") label(3 "Modeled 202102") rows(1))
	
graph save suppS1,replace
graph export suppS1.png,replace
* so the best date is December 2019


/*************************************
*
* Finally we do two the DID model
*
**************************************/

* model 2 is a DiD model with Oregon against the other states, using the decrim starting point*/
* save the file we produced above, wiht all the rate estimates
save fullRegFile20260429,replace
** now do the difference in difference model
* we will be collapsing all non-Oregon states together, so we need to
* set missing deaths to be 0. This is only a very tiny % of total deaths
* - each month in California alone there are >150 deaths,
* so we expect that the <10 deaths in some months being set to 0 will 
* not change the total deaths of other states by much
replace deaths=0 if deaths==.
gen intVal=(stateVal==4)
collapse (sum) deaths pop,by(intVal timeVal)
sort intVal timeVal
by intVal: gen tBase=_n

* in this series february 2021 is tBase==74
gen tImpl=tBase-74
gen stepVal=tBase>=74
gen rate=100000*deaths/pop

* prepare S10
twoway (line rate timeVal if intVal==0,lcolor($gh2) lwidth(thick)) ///
	(line rate timeVal if intVal==1, lcolor($gh1) lwidth(thick) xline(22312,lcol(gs8))), ///
 legend(label(1 "Control states") label(2 "Oregon")) ///
 xlabels(20089 20820 21550 22281 23011) xtitle("Year") ytitle("Rate per 100,000")
graph save figureS10,replace
graph export figureS10.tif,replace
graph export figureS10.png,replace
gen offS=ln(pop)
* regression model

poisson deaths i.intVal tImpl i.stepVal i.intVal#c.tImpl i.stepVal#c.tImpl i.intVal#i.stepVal ///
	i.intVal#i.stepVal#c.tImpl,offset(offS) irr
save simpFile,replace

* redo, restricting to the period 2018 - 2023/feb
keep if tBase>=38&tBase<=98
poisson deaths i.intVal tImpl i.stepVal i.intVal#c.tImpl i.stepVal#c.tImpl i.intVal#i.stepVal ///
	i.intVal#i.stepVal#c.tImpl,offset(offS) irr

* get the lincoms
* first the level change
lincom 1.stepVal,irr
lincom 1.stepVal+1.stepVal#1.intVal,irr

* now the trends
* first control states before
lincom tImpl,irr
* next intervention state before
lincom tImpl+1.intVal#c.tImpl,irr

* theen control states after
lincom tImpl+1.stepVal#c.tImpl,irr

* oregon after
lincom tImpl+1.intVal#c.tImpl+1.stepVal#c.tImpl+1.intVal#1.stepVal#c.tImpl,irr


* I think with that all Stata work is done! Lastly do the joinpoint

* export data to excel I guess, to use in joinpoint
use fullRegFile20260429,clear
keep stateVal tBase deaths pop
* drop idaho, which joinpoint can't handle
drop if stateVal==2 
gen rate=100000*deaths/pop
replace rate=0 if rate==.
save basicJPFile20260429,replace
export excel jpFile20260429.xlsx,replace firstrow(variables)

/*****************************************
added on 2026/3/25
use negative binomial for sensitivity analysis in response to one reviewer

*****************************************/
use simpFile,clear

* neg bin model for hte entire time series
nbreg deaths i.intVal tImpl i.stepVal i.intVal#c.tImpl i.stepVal#c.tImpl i.intVal#i.stepVal ///
	i.intVal#i.stepVal#c.tImpl,offset(offS) irr
* basically no different from the Poisson model


/* A final task is to redo certain of these analyses using the complete data for Idaho to see if there is any difference. The key result we need to check is the DiD model, but the effect will be very small. This is done in a separate do file, since we didn't do it for the paper.
