#==============================================================================================
# WILL THE CUSTOMER DEFAULT ON THE LOAN?
#==============================================================================================


#INTRODUCTION
#=============================================================================================

 




#1. DATA (GERMAN CREDIT DATA)
#=============================================================================================

setwd('C:\\Users\\Anugya\\Desktop\\Term 2\\Model Interpretation\\Dataset')
credit = read.csv("germancredit.csv")
View(credit)



#2. Get a basic understanding of the dataset
#=============================================================================================

dim(credit)
str(credit)

table(credit$Default_)



#3. ANALYZE THE BAD RATE ACCROSS SEVERAL INDIVIDUAL VARIABLES
#=============================================================================================


require(sqldf)

#Bad rate for credit history

sqldf("SELECT history, round(avg(Default_)*100,2) AS 'Bad Rate',
      (100 - round(avg(Default_)*100,2)) AS 'Good Rate',
      COUNT(*) AS 'No of Applicants'
      FROM credit GROUP BY history")



#A better way...
#Export the tables in an excel workbook in separate worksheets

library(xlsx)
wb = createWorkbook()

for(i in 2:ncol(credit))
{
  if(is.factor(credit[,i]))
  {
    
    varname = names(credit)[i]
    
    sheet = createSheet(wb, varname)
    
    string = paste("SELECT", varname, ", round(avg(Default_)*100,2) AS 'Bad Rate', (100 - round(avg(Default_)*100,2)) AS 'Good Rate' FROM credit GROUP BY", varname)
    
    addDataFrame(sqldf(string), sheet = sheet, startColumn = 2, row.names = F)
    
  }
}

saveWorkbook(wb, "Bad Rate.xlsx")





#3. EXPLORING THE DATA VISUALLY
#=============================================================================================

#A. UNIVARIATE ANALYSIS

#Histogram or barplots for numerical variables
for(i in 1:ncol(credit))
{
  if(is.numeric(credit[,i]))
  {
    if(length(unique(credit[,i])) > 10)
    {
      hist(credit[,i], main = names(credit)[i], xlab = names(credit)[i])
    }
      
    else if(length(unique(credit[,i])) < 10)
    {
      barplot(table(credit[,i]), main=names(credit)[i], xlab = names(credit)[i])
    }
  }
}


#Barplots for categorical varibales
for(i in 1:ncol(credit))
{
  if(is.factor(credit[,i]))
  {
     barplot(table(credit[,i]), main=names(credit)[i], xlab = names(credit)[i])
  }
}



#B. BIVARIATE ANALYSIS

#Side-by-side Boxplots for numerical variables
for(i in 2:ncol(credit))
{
  if(is.numeric(credit[,i]))
  {
    if(length(unique(credit[,i])) > 10)
    {
      boxplot(credit[,i] ~ credit$Default_, main = names(credit)[i], ylab = names(credit)[i])
    }
      
    else if(length(unique(credit[,i])) < 10)
    {
      barplot(table(credit[,i], credit$Default_), main=names(credit)[i], 
              xlab = names(credit)[i], beside = T, legend = rownames(table(credit[,i])))
    }
  }
}






#4. RE-GROUPING THE LEVELS OF THE CATEGORICAL VARIABLES
#=============================================================================================
library(xlsx)
library(InformationValue)
library(Information)



#Calculate the WOE table for the variable history

WOETable(credit$history, credit$Default_)



infoTables <- create_infotables(data = credit,
                                
                                y = "Default_",
                                bins = 5,
                                parallel = T)

infoTables$Summary
infoTables$Tables$age

# - WOE table:
infoTables$Tables$IV



#Exporting the WOE Table for every categorical variables in excel workbook
wb = createWorkbook()

for(i in 2:ncol(credit))
{
  if(is.factor(credit[,i]))
  {
    
    varname = names(credit)[i]
    
    sheet = createSheet(wb, varname)
    
    woe = WOETable(credit[,varname], credit$Default_)
    
    addDataFrame(woe, sheet = sheet, startColumn = 2, row.names = F)
    
  }
}

saveWorkbook(wb, "WOE Table 2.xlsx")




#re-level the credit history and a few other variables
credit3 = credit


#------------------------------------Credit3-------------------------------------------------
#VARIABLE: Credit history
credit3$history = factor(credit$history, levels=c("A30","A31","A32","A33","A34"))
levels(credit3$history) = c("good","good","poor","poor","terrible")



#VARIABLE: Purpose
credit3$purpose = factor(credit$purpose, levels=c("A41","A48","A43","A42","A44","A49","A45","A40","A410","A46"))
levels(credit3$purpose) = c("Re-training","Used-car","Radio TV", rep("Furniture and Domestic app.",2),
                            rep("Business or Repairs",2), "New car", rep("Education and Others",2))   #[Check the no. of levels]
#VARIABLE: Checking Status
credit3$checkingstatus1=factor(credit3$checkingstatus1,levels=c("A11","A12","A13","A14"))
levels(credit3$checkingstatus1)=c("Zero Balance Account","Less than 200 DM"," More than 200 DM","No checking account")



#VARIABLE:savings account
credit3$savings =factor(credit3$savings,levels=c("A61","A62","A64","A63","A65"))
levels(credit3$savings)=c("Very low","Low","High",rep("Moderate",2))

#VARIABLE:employ
credit3$employ =factor(credit3$employ,levels=c("A71","A72","A73","A74","A75"))
levels(credit3$employ)=c("Unemployed","Short-term employment","Moderate employment",rep("Long-term employment",2))

#VARIABLE:status
credit3$status =factor(credit3$status,levels=c("A91","A92","A93","A94"))
levels(credit3$status)=c("Male:D/S","F: D/S/M",rep("M:S/M/W",2))


#VARIABLE:factor
credit3$others =factor(credit3$others,levels=c("A101","A102","A103"))
levels(credit3$others) = c("None","Co-Applicant","Guarantor")

#VARIABLE:property
credit3$property=factor(credit3$property,levels=c("A121","A122","A123","A124"))
levels(credit3$property)=c("Real-Estate",rep("Other properties",2),"Unknown/No property")

#VARIABLE:otherplans
credit3$otherplans=factor(credit3$otherplans,levels=c("A141","A142","A143"))
levels(credit3$otherplans)=c(rep("Bank and Stores",2),"None")

#VARIABLE:housing
credit3$housing=factor(credit3$housing,levels=c("A151","A153","A152"))
levels(credit3$housing)=c(rep("Rent/For free",2),"Own")

#VARIABLE:job
credit3$job = factor(credit3$job, levels=c("A171","A172","A173","A174"))
levels(credit3$job) = c("Unemployed/Nonresident","Unskilled/Resident","Skilled/Employed","Self/Highly Qualified Employee")

#VARIABLE:tele
credit3$tele = factor(credit3$tele, levels=c("A191","A192"))
levels(credit3$tele) = c("None","Yes")


#VARIABLE:foreign_
credit3$foreign_ = factor(credit3$foreign_, levels=c("A201","A202"))
levels(credit3$foreign_) = c("Yes","None")

#VARIABLE:installment
typeof(credit3$installment)

View(credit3)

#---------WOE TABLE FOR CREDIT3------------------------------------------
#Exporting the WOE Table for every categorical variables in excel workbook
wb = createWorkbook()

for(i in 2:ncol(credit3))
{
  if(is.factor(credit3[,i]))
  {
    
    varname = names(credit3)[i]
    
    sheet = createSheet(wb, varname)
    
    woe = WOETable(credit3[,varname], credit3$Default_)
    
    addDataFrame(woe, sheet = sheet, startColumn = 2, row.names = F)
    
  }
}

saveWorkbook(wb, "WOE Table 3.xlsx")

getwd()



#UNDERSTANDING VARIABLE IMPORTANCE
#=============================================================================================
library(InformationValue)

#Using IV to understand the imporance of the categorical variables

for(i in 2:ncol(credit3))
{
  if(is.factor(credit3[,i]))
  {
    varname = names(credit3)[i]
    
    print(varname)
    print(IV(X=credit3[,varname], Y=credit3$Default_))
    
  }
}




#Using t-test to understand the imporance of the numerical variables

importance = c()

for(i in 2:ncol(credit))
{
  if(!is.factor(credit[,i]))
  {
    varname = names(credit)[i]
    
    p_value = t.test(credit[,varname] ~ credit$Default_)$p.value
    
    importance[varname] = round(p_value,5)
  
  }
}

importance



#Note: You can categorize the numerical variables in bins and calculate the WOE for
#separate bins. Group the bins with similar WOE in sequential manner. Finally calculate
#The IV to determine the variable importance.

install.packages("woeBinning")
library(woeBinning)

num <- credit3[, c('Default_', 'amount', 'duration', 'age', 'installment')]
binning <- woe.binning(num, 'Default_', num)

#table creation for bins
tabulate.binning <- woe.binning.table(binning)
tabulate.binning

#plotting the bins
woe.binning.plot(binning)

df.with.binned.vars.added <- woe.binning.deploy(num, binning = binning, add.woe.or.dum.var='dum')

View(df.with.binned.vars.added)
write.xlsx(df.with.binned.vars.added, file='num_bins.xlsx', sheetName = "Sheet1", 
           col.names = TRUE, row.names = TRUE, append = FALSE)

#-----------NUmerical Dummy creation method 2-------------------------------------------------------
num_dummy <- df.with.binned.vars.added[, c('Default_', 'amount.binned', 'duration.binned', 'age.binned', 'installment.binned')]
View(num_dummy)

num_dum <- dummy.data.frame(num_dummy, sep = '.')
View(num_dum)

#------------------------new dataframe with important features only--------
#Using some important variables to fit a Logistic Regression Model

#IMPORTANT CATEGORICAL VARIABLES: 
#("checkingstatus1", "history", "purpose_new", "savings", "property")

#IMPORTANT NUMERICAL VARIABLES: 
#("duration", "amount", "installment", "age")

cat_var = c("checkingstatus1", "history", "purpose", "savings", "property")
num_var = c("duration", "amount", "installment", "age")
credit_new = credit3[,c(cat_var, num_var)]

View(credit_new)

#-------Creating Dummy Variables------------------------
install.packages('dummies')
library(dummies)

credit_dum <- dummy.data.frame(credit_new, sep = '.')

credit_dum$Default_ <- credit$Default_

View(credit_dum)
View(num_dum)
write.xlsx(num_dum, file='numerical_with_dummy.xlsx', sheetName = "Sheet1", 
           col.names = TRUE, row.names = TRUE, append = FALSE)

nd <- read.csv('numerical_with_dummy.csv')
View(nd)

colnames(nd)

View(credit_exp)

credit_exp = credit_dum

credit_exp$amount1 <- nd$amount1
credit_exp$amount2 <- nd$amount2
credit_exp$amount3 <- nd$amount3
credit_exp$duration1 <- nd$duration1
credit_exp$duration2 <- nd$duration2
credit_exp$duration3 <- nd$duration3
credit_exp$duration4 <- nd$duration4
credit_exp$age1 <- nd$age1
credit_exp$age2 <- nd$age2
credit_exp$age3 <- nd$age3
credit_exp$installment1 <- nd$installment1
credit_exp$installment2 <- nd$installment2

credit_exp$amount <- NULL
credit_exp$installment <- NULL
credit_exp$age <- NULL
credit_exp$duration <- NULL



#TRAIN-TEST SPLIT
#=============================================================================================
library(caTools)
set.seed(88)
split <- sample.split(credit_dum$Default_, SplitRatio = 0.75)

#get training and test data
train <- subset(credit_dum, split == TRUE)
test  <- subset(credit_dum, split == FALSE)

View(train)

#---TRAIN TEST SPLIT FOR CREDIT_EXP------------
split <- sample.split(credit_exp$Default_, SplitRatio = 0.75)

#get training and test data
train_exp <- subset(credit_exp, split == TRUE)
test_exp  <- subset(credit_exp, split == FALSE)



#FITTING A LOGISTIC REGRESSION MODEL
#=============================================================================================
#perform same with credit_new----------------------------------------------

logit1 = glm(Default_ ~ ., data=train, family = binomial)

summary(logit1)
pred = predict(logit1, newdata = test, type = "response")
pred[1:5]

#----------MOdel for credit_exp------------------------------------------

logit_exp = glm(Default_ ~ ., data=train_exp, family = binomial)

summary(logit_exp)


pred_exp = predict(logit_exp, newdata = test, type = "response")
pred_exp[1:5]

library(ROCR)

auroc = AUROC(test_exp$Default_, pred_exp)
auroc 


#MODEL SELECTION
#=================================================================================================
#Refer to this artical:
#http://www.utstat.toronto.edu/~brunner/oldclass/appliedf11/handouts/2101f11StepwiseLogisticR.pdf

#CHOICE OF CUT-OFF
#==================================================================================================

#Assume that lending into default is 5 times as costly as not lending to a good debtor
#(Assume that this later cost is 1). Here the default is taken as "success". suppose we 
#estimate a certain p for probability of default.
#
#Then, Expected Cost = 5p, if we make a loan
#      Expected Cost = 1(1 - p), if we refuse the loan
#
#if 5p < (1 - p), we expect to lose less by loaning than by turning away business
#
#i.e. make loan if the probability of default is < 1/6
#Or,  predict 1, if p > 1/6
#

#Let t = 0.5
pred1 = ifelse(pred > 0.5, 1, 0)

#Confusion matrix
table(test$Default_, pred1)


#Accuracy metrics
library(InformationValue)

#Sensitivity or recall
?sensitivity
sensitivity(test$Default_, pred)

#Specificity
specificity(test$Default_, pred)

#Precision
precision(test$Default_, pred)

#Youden's Index (Sensitivity + Specificity - 1)
youdensIndex(test$Default_, pred)

#Mis-classification Error
misClassError(test$Default_, pred)



#Choosing Optimal Cutoff to detect more 1's
?optimalCutoff
ones = optimalCutoff(test$Default_, pred, "Ones")
ones
#Conf. Matrix
table(test$Default_, pred > ones)


#Choosing Optimal Cutoff to detect more 0's
#Based on the Youden's Index

zeros = optimalCutoff(test$Default_, pred, "Zeros")
zeros
#Conf. Matrix
table(test$Default_, pred > zeros)


#Choosing Optimal Cutoff to minimizes mis-classification error
both = optimalCutoff(test$Default_, pred, "Both")
both
#Conf. Matrix
table(test$Default_, pred > both)



#MODEL VALIDATION
#=================================================================================================













#ODDS RATIO
#============================================================================================
install.packages('oddsratio')
library(oddsratio)

View(credit_dum)

exp(cbind(OR = coef(logit1),confint(logit1)))



#ASSESSING MODEL PERFORMANCE
#=================================================================================================

#Plotting an ROC curve (Choosing Cut-off using ROC curve)
#------------------------------------------------------------------------

library(ROCR)
ROCpred <- prediction(pred,test$Default_)
ROCperf <- performance(ROCpred,"tpr","fpr")
plot(ROCperf)
#plot(ROCperf, colorize=T, 
     #print.cutoffs.at=seq(0,1,0.1), text.adj=c(-0.2,1.7))
plot(ROCRperf, colorize = TRUE, text.adj = c(-0.2,1.7))


#-Concordance-Disconcordance
Conc = Concordance(test$Default_, pred)
Conc
C = Conc$Concordance
D = Conc$Discordance
T = Conc$Tied

#Goodman - Kruskal Gamma
#------------------------------------------------------------------------
gamma = (C-D)/(C+D+T)
gamma

D = (C-D)/(C+D)
D



#K-S Statistic
#------------------------------------------------------------------------

#Lift chart and Gain Chart
#--------------------------------------------------------------------------

#CREATING A GAIN TABLE
#---------------------

#STEP 1 - Create a data frame with two columns - actual and the predicted proabilities
#-------------------------------------------------------------------------------------
pred1 = predict(logit1, newdata=test, type="response")
actual = test$Default_
newdata = data.frame(actual,pred1)
View(newdata)


#STEP 2 - Sort the data frame by the predicted probability
#-------------------------------------------------------------------------------------
newdata = newdata[order(-newdata$pred1), ]



#STEP 3 - Divide the data into 10 equal parts according to the values of the predicted probabilities
#-------------------------------------------------------------------------------------
#3A. -> Assign a group te each of the observations in the sorted data in sequence
#-------------------------------------------------------------------------------------
..
#How many observations should each groups contain?
nrow(newdata)/10

#Create the groups in using index
groups = rep(1:10,each=floor(nrow(newdata)/10)) 
extra = rep(10, nrow(newdata)-length(groups))   #Filling up the extras

groups = c(groups,extra)
groups

#Attach the groups to the data
newdata$groups = groups
View(newdata)


#3B -> Creating a Gain Table
#--------------------------------------------------------------------------------------

#We will use SELECT query from the sqldf library
library(sqldf)


#Calculate the number of Bads (or 1's) in each of the groups (keeping track of the total counts in each groups)
gainTable = sqldf("select groups, count(actual) as N, 
                  sum(actual) as N1 from newdata 
                  group by groups ")
class(gainTable)
View(gainTable)

#Calculate the cumulative sum of bads (or 1's)
gainTable$cumN1 = cumsum(gainTable$N1)


#Calculate the cumulative percentage of bads (or 1's)
gainTable$Gain = round(gainTable$cumN1/sum(gainTable$N1)*100,3)


#Calculate Cumulative Lift
gainTable$Lift = round(gainTable$Gain/((1:10)*10),3)


#Print the Gain Table

gainTable


#3C -> Plot the Cumulative Gain and Cumulative Lift Chart
#-------------------------------------------------------------------------------------

#Gain Chart
plot(gainTable$groups, gainTable$Gain, type="b", 
     main = "Gain Plot",
     xlab = "Groups", ylab = "Gain")



#Lift Chart
plot(gainTable$groups, gainTable$Lift, type="b", 
     main = "Lift Plot",
     xlab = "Groups", ylab = "Lift")





#INTERPRETATION:
#--------------

#Interpretation of Lift:
#The Cum Lift of 4.03 for top two deciles, means that when selecting 20% of the records 
#based on the model, one can expect 4.03 times the total number of targets (events) 
#found by randomly selecting 20%-of-file without a model.
#


#K-S Statistic
#------------------------------------------------------------------------

#Creating an initial table
ks = sqldf("select groups, count(actual) as N, sum(actual) as N1, 
           count(actual)-sum(actual) as N0 from newdata group by groups ")

View(ks)


#Calculate Percentage Events and Non-Events
ks$PerN0 = round(ks$N0/sum(ks$N0)*100,2)
ks$perN1 = round(ks$N1/sum(ks$N1)*100,2)


#Calculate Cumulative Percentage of Events and Non-Events
ks$CumPerN0 = cumsum(ks$PerN0)
ks$CumPerN1 = cumsum(ks$perN1)


#Calculation of KS
ks$KS = abs(ks$CumPerN0 - ks$CumPerN1)


#Print the Table
ks


#Plot the Graph
plot(ks$groups, ks$CumPerN0, type="l", col = "Green")
lines(ks$groups, ks$CumPerN1, col = "Red")


#INTERPRETATION (This example):
#-----------------------------

#KS Statictics if also calculated to understand how good the model is performing compared
#to the random model.
library(InformationValue)
ks_plot(newdata$actual, newdata$pred1)
ks_stat(newdata$actual, newdata$pred1)


#Lift chart and Gain Chart
#--------------------------------------------------------------------------

pred1 = predict(logit1, type="response")
actual = death$Death


newdata = data.frame(actual,pred1)
View(newdata)
newdata = newdata[order(-newdata$pred1), ]


nrow(newdata)/10
?rep
groups = rep(1:10,each=floor(nrow(newdata)/10))

extra = rep(10, nrow(newdata)-length(groups))
length(groups)
nrow(newdata)

groups = c(groups,extra)


newdata$groups = groups
View(newdata)

library(sqldf)
gainTable = sqldf("select groups, count(actual) as N, sum(actual) as N1 from newdata group by groups ")
gainTable$cumN1 = cumsum(gainTable$N1)
gainTable$Gain = round(gainTable$cumN1/sum(gainTable$N1)*100,3)
gainTable$Lift = round(gainTable$Gain/((1:10)*10),3)

gainTable


plot(gainTable$groups, gainTable$Gain, type="b", 
     main = "Gain Plot",
     xlab = "Groups", ylab = "Gain")



plot(gainTable$groups, gainTable$Lift, type="b", 
     main = "Lift Plot",
     xlab = "Groups", ylab = "Lift")




#K-S
ks = sqldf("select groups, count(actual) as N, sum(actual) as N1, 
           count(actual)-sum(actual) as N0 from newdata group by groups ")

ks$cumN1 = cumsum(ks$N1)
ks$cumN2 = cumsum(ks$N0)
ks$cumPerN1 = round(ks$cumN1/sum(ks$cumN1)*100,3)
ks$cumPerN2 = round(ks$cumN2/sum(ks$cumN2)*100,3)
ks$KS = ks$cumPerN1 - ks$cumPerN2
ks

plot(ks$groups, ks$cumPerN1, type="l", col="red")
lines(ks$groups, ks$cumPerN2, col="blue")

plot(ks$groups, ks$cumPerN2, type="l", col="red")
lines(ks$groups, ks$cumPerN1, col="blue")

library(InformationValue)
ks_plot(newdata$actual, newdata$pred1)


#Hosmer - Lameshow Goodness of Fit
#------------------------------------------------------------------------



library(ResourceSelection)
hoslem.test(test_bal$Default_, pred_bal, g=10)



#HANDLING CLASS IMBALANCEDNESS
#=================================================================================================

library(DMwR)

train$Default_ = as.factor(train$Default_)

balanced.data <- SMOTE(Default_ ~., train, perc.over = 800, k = 5, perc.under =200 )


as.data.frame(table(balanced.data$Default_))

table(balanced.data$Default_)


#---TRAIN TEST SPLIT FOR balanced data------------

split <- sample.split(balanced.data$Default_, SplitRatio = 0.75)

#get training and test data
train_bal <- subset(balanced.data, split == TRUE)
test_bal <- subset(balanced.data, split == FALSE)

logit_bal = glm(Default_ ~ ., data=train_bal, family = binomial)

summary(logit_bal)
pred_bal = predict(logit_bal, newdata = test_bal, type = "response")
pred[1:5]

auroc = AUROC(test_bal$Default_, pred_bal)
auroc 







