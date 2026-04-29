# Script to test some details of the Zoorob paper
# requires to use their replication package to load teh "mort" object
library(data.table)
library(ggplot2)
library(geofacet)
library(fixest)
# first set the working driectory to the location of the replciation dataverse for 
# Zoorbo et al, and run this code below to import teh data and set up the mort file
## seizure panel
# you need to insert your working directory here (I deleted mine for security)
# the Zoorob replication folders shoudl all be completely inside this working directory
# if you don't structure it this way you'll need to slightly faff with the fread() function
setwd("/Users/Faustus/Stuart研 Dropbox/Stuart Gilmour/Research Current/Speculation/Oregon OD/fentanyl_oregon_replication_dataverse/replication_dataverse")
dat = fread("data/fentanyl_state_half_panel_complete.csv")
dat[, State := state.name[match(ST,state.abb)]]
dat[ST == "DC", State := "District of Columbia"]
dat = dat[!(ST %in% c("GU", "PR", "VI", "XX"))]
## nflis all
nflis_all = fread("data/alldrugs_state_half_panel.csv")
dat = merge(dat, nflis_all, by=c("ST", "Year", "half"), all.x=T)
dat[, nflis_fentanyl_percent_total := fentanyl_and_related_substances_seizure_count / alldrugs_seizure_count * 100 ]

## mortality data
mort = fread("data/udods_2018_sep2023.txt.txt")
mort = mort[, c("Occurrence State", "Occurrence State Code", "Month", "Month Code", "Deaths")]
mort[, Year:= as.numeric(substr(`Month Code`,1,4))]
pop = fread("data/pop_2018_sep2023.txt")
pop = pop[, c("Residence State", "Residence State Code", "Year", "Year Code", "Population")]
# merge deaths with pop data
mort = merge(mort, pop[,c("Residence State","Year Code", "Population")],
             by.x = c("Occurrence State", "Year"), by.y = c("Residence State", "Year Code"),
             all.x=T)
# impute mortality where suppressed bc <10 deaths
## for this reason there's gonna be slight (decimal point) differences in estimates between runs
mort[, Deaths := as.numeric(Deaths)]
mort[, Deaths_nosuppressed := ifelse(is.na(Deaths),round(runif(nrow(mort),0,9)),Deaths)]
# od death rate
mort[, od_death_rate_per100k := Deaths_nosuppressed / Population * 100000]
mort[, months_since := round(lubridate::time_length(as.Date(paste(`Month Code`,"/01",sep=""), "%Y/%m/%d") - min(as.Date(paste(`Month Code`,"/01",sep=""), "%Y/%m/%d")),unit="months"))]
## ind treated
mort$state = mort$`Occurrence State`
mort[, treatment := as.numeric((state == "Oregon" & months_since >= 37) |
                                 (state == "Washington" & months_since >= 38))]

## merge in fent
mort[, Month := lubridate::month(as.Date(paste(mort$`Month Code`,"/01",sep=""), "%Y/%m/%d"))]
mort[, half := ifelse(Month <= 6, 1, 2)]
# final dataset
mort = merge(mort, dat[, c("State", "Year", "half", "alldrugs_seizure_count", "nflis_fentanyl_percent_total", "fentanyl_and_related_substances_seizure_count")],
             all.x=T, by.x = c("Occurrence State","Year", "half"), by.y = c("State", "Year", "half"))

# now need to make a numeric variable of the states
loop.vec<-unique(mort$state)
m.vec<-seq(1:length(loop.vec))
state.code<-data.frame(loop.vec,m.vec)
names(state.code)<-c("state","mCode")
mort<-merge(mort,state.code,by.x="state",by.y="state")

# set the time variable
mort$time<-(mort$Year-2018)*12+mort$Month



# now change directory to make sure output files don't get mixed up with the replication dataverse files
setwd("")

# added by SG 2026/2/28
# loop through dropping a single control group and rerunning the bsaic model, extract 
# coefficient of treatment
loop.vec<-unique(mort$state)
out.vec<-rep(0,times=length(loop.vec))
out.sig<-rep(0,times=length(loop.vec))
for (i in 1:length(loop.vec)){
  
  pick.val<-loop.vec[i]
  mod.dat<-mort[Year<=2021&state!=pick.val]
  mod.t<-lm(od_death_rate_per100k ~ treatment+as.factor(state)+as.factor(mCode)+ nflis_fentanyl_percent_total, data=mod.dat)
  out.vec[i]<-mod.t$coefficients[2]
  out.sig[i]<-summary(mod.t)$coefficients[2,4]<0.05
}
hist(out.vec)

loop.vec<-unique(mort$state)
out.vec<-rep(0,times=length(loop.vec))
out.sig<-rep(0,times=length(loop.vec))
for (i in 1:length(loop.vec)){
  
  pick.val<-loop.vec[i]
  mod.dat<-mort[Year<=2021&state!=pick.val]
  mod.t<-lm(od_death_rate_per100k ~ treatment+as.factor(state)+as.factor(mCode), data=mod.dat)
  out.vec[i]<-mod.t$coefficients[2]
  out.sig[i]<-summary(mod.t)$coefficients[2,4]<0.05
}
hist(out.vec)

# so dropping a single state doesn't change the result much.

# 



# plotting fentanyl % for the key states
key.data<-mort[mort$state=="Oregon"|mort$state=="Washington"|mort$state=="Idaho"|mort$state=="California"|mort$state=="Nevada",]
key.oregon<-mort[mort$state=="Oregon",]
key.washington<-mort[mort$state=="Washington",]
key.idaho<-mort[mort$state=="Idaho",]
key.california<-mort[mort$state=="California",]
key.california<-mort[mort$state=="Nevada",]
state.vec<-unique(key.data$state)
plot(key.data$time,key.data$nflis_fentanyl_percent_total,type="n",
     ylab="Proportion",xlab="Time",xlim=c(0,60))
for (i in 1:length(state.vec)){
  data.t<-key.data[key.data$state==state.vec[i],]
  lines(data.t$time,data.t$nflis_fentanyl_percent_total,col=i,lwd=3)
  
}

legend(x=0,y=40,legend=state.vec,col=c(1:length(state.vec)),lwd=1,ncol=2,cex=0.5)
abline(v=38,col="gray87",lwd=2)


#### material below is reanalysis of Zoorob et al that was used in peer review but not
#### in the final paper
# try the analysis with these values
key.data$tVal=key.data$time-38
key.data$intVal=(key.data$time>=38)
key.data$intGroup=(key.data$state=="Oregon")
key.data$offS=log(key.data$Population)
# do the model
did.model<-glm(Deaths~tVal+intGroup+intVal+intVal:tVal+intGroup:tVal+intGroup:intVal
               +intGroup:intVal:tVal+offset(offS),family=poisson,data=key.data)

summary(did.model)
did.eff<-summary(did.model)$coefficients[7,1]
100*exp(did.eff)
# very similar to the ouptut from stata. Now add fentanyl
did.model<-glm(Deaths~tVal+intGroup+intVal+intVal:tVal+intGroup:tVal+intGroup:intVal
               +intGroup:intVal:tVal+offset(offS)+nflis_fentanyl_percent_total,family=poisson,data=key.data)
summary(did.model)
did.eff<-summary(did.model)$coefficients[8,1]
100*exp(did.eff)

# try with lm
did.lm1<-glm(od_death_rate_per100k~tVal+intGroup+intVal+intVal:tVal+intGroup:tVal+intGroup:intVal
             +intGroup:intVal:tVal,data=key.data)
summary(did.lm1)

# add fentanyl
did.lm1<-glm(od_death_rate_per100k~tVal+intGroup+intVal+intVal:tVal+intGroup:tVal+intGroup:intVal
             +intGroup:intVal:tVal+nflis_fentanyl_percent_total,data=key.data)
summary(did.lm1)

# apply the model from Zoorob.
# Oregon replication + extension
key.data$treat2<-key.data$treatment
key.data$treat2[key.data$state=="Washington"]<-0
oregon_original = feols(od_death_rate_per100k ~ treatment | state + mCode,
                        data=key.data[Year<=2021 & state != "Washington"])
oregon_nflis = feols(od_death_rate_per100k ~ treatment + nflis_fentanyl_percent_total |
                       state + mCode, data=key.data[Year<=2021 & state != "Washington"])
etable(oregon_original,oregon_nflis, digits=2)
# get ci
etable(oregon_original, oregon_nflis, digits=2, coefstat = 'confint')

# redo with washignton included in controls
oregon_original = feols(od_death_rate_per100k ~ treatment | state + mCode,
                        data=key.data[Year<=2021])
oregon_nflis = feols(od_death_rate_per100k ~ treatment + nflis_fentanyl_percent_total |
                       state + mCode, data=key.data[Year<=2021 ])
etable(oregon_original,oregon_nflis, digits=2)
# get ci
etable(oregon_original, oregon_nflis, digits=2, coefstat = 'confint')
