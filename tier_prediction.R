# ============================================================================
# Title: Hero Tier Predictor
# Description:
#   This table predicts tiers using character stats
# Input(s): .csv files
# Output(s): 
# Author: Timothy Tan
# Date: 2-7-2018
# ============================================================================

library(readr)
library(e1071,    verbose=FALSE, warn.conflicts=FALSE, quietly=TRUE)
library(ggplot2,  verbose=FALSE, warn.conflicts=FALSE, quietly=TRUE)
library(gridExtra, verbose=FALSE, warn.conflicts=FALSE, quietly=TRUE)
library(rpart,    verbose=FALSE, warn.conflicts=FALSE, quietly=TRUE)
library(neuralnet, verbose=FALSE, warn.conflicts=FALSE, quietly=TRUE)
library(dummies,   verbose=FALSE, warn.conflicts=FALSE, quietly=TRUE)
library(rpart.plot, verbose=FALSE, warn.conflicts=FALSE, quietly=TRUE)
library(kknn, verbose=FALSE, warn.conflicts=FALSE, quietly=TRUE)
library(caret,     verbose=FALSE, warn.conflicts=FALSE, quietly=TRUE)
library(e1071,     verbose=FALSE, warn.conflicts=FALSE, quietly=TRUE)


heroes <- read_csv('data/heroes.csv')

#functions
as.class <- function(value){
  newValue = c()
  for(i in 1:length(value)) {
    if(value[i] < 0){
      newValue[i] = 0 
    }
    else
      newValue[i] = round(value[i])
  }
  return(newValue)
}

createFolds.train = function(v, train) { test = list(); for (i in 1:length(train)) { test[[i]] = setdiff(1:length(v), train[[i]]); names(test)[[i]]=sprintf("Fold%d",i) }; test }

#linear regression model
lm_heroes <- lm(Tier ~ Class + Movement + HP + ATK + SPD + DEF + RES + Total, heroes)
heroes$lm_prediction <- as.class(predict(lm_heroes, heroes))
accuracy_lm = length(which(heroes$Tier == heroes$lm_prediction)) / length(heroes$Tier == heroes$lm_prediction)
accuracy_lm
linearplot <- ggplot(heroes) +
  geom_point(aes(x=ATK, y=Tier), color="Green") +
  geom_point(aes(x=ATK, y=heroes$lm_prediction), color="Red")

#complex linear regression model
clm_heroes <- lm(Tier ~ Class + Movement + HP + log(ATK) + log(SPD) + DEF + RES + Total, heroes)
heroes$clm_prediction <- as.class(predict(clm_heroes, heroes))
accuracy_clm = length(which(heroes$Tier == heroes$clm_prediction)) / length(heroes$Tier == heroes$clm_prediction)
accuracy_clm

#support vector machine
#tuning
# tune = data.frame()
# for (gamma in c(1,2,3,4))
#   for (cost in c(0.1,1,10))
#     for (degree in c(1,2,3,4))
#     {
#       model = svm(Tier ~ HP + ATK + SPD + DEF + RES + Total, heroes, type="C-classification", kernel="polynomial", degree=degree, gamma=gamma, cost=cost, scale=TRUE)
#       prediction = predict(model, heroes)
#       accuracy = length(which(heroes$Tier == prediction)) / length(heroes$Tier == prediction)
#       tune = rbind(tune, data.frame(method="svm", kernel="polynomial", gamma=gamma, scale=TRUE, degree=degree, cost=cost, accuracy=mean(accuracy)))
#     }
# tune[which.max(tune$accuracy),]

#svm
svm_heroes <- svm(Tier ~ Class + Movement + HP + ATK + SPD + DEF + RES + Total, heroes, type="C-classification", kernel="polynomial", degree=4, gamma=1, cost=0.1, scale=TRUE)
heroes$svm_prediction <- predict(svm_heroes, heroes)
accuracy_svm = length(which(heroes$Tier == heroes$svm_prediction)) / length(heroes$Tier == heroes$svm_prediction)
accuracy_svm

#neuralnet
set.seed(12345)
neuralnet_heroes = neuralnet(Tier ~ HP + ATK + SPD + DEF + RES + Total, heroes, hidden=3, algorithm="backprop", learningrate=0.002, threshold=0.01, stepmax=5000, rep=1, act.fct="logistic", linear.output=TRUE)
heroes$neuralnet_prediction <- as.class(compute(neuralnet_heroes, heroes[,4:9])$net.result)
accuracy_neuralnet = length(which(heroes$Tier == heroes$neuralnet_prediction)) / length(heroes$Tier == heroes$neuralnet_prediction)
accuracy_neuralnet

#decision tree
dt_heroes = rpart(Tier ~ Class + Movement + HP + ATK + SPD + DEF + RES + Total, heroes, method="anova")
heroes$dt_prediction <- as.class(predict(dt_heroes, heroes))
accuracy_dt = length(which(heroes$Tier == heroes$dt_prediction)) / length(heroes$Tier == heroes$dt_prediction)
accuracy_dt

#testing with folds
# nfold = 3
# 
# set.seed(12345)
# test = createFolds(heroes$Tier, k=nfold)
# train = createFolds.train(heroes$Tier, test)
# lm_hero = list()
# lm_predict = list()
# lm_accuracy = c()
# 
# for (fold in 1:nfold)
# {
#   lm_hero[[fold]] = lm(Tier ~ Class + Movement + HP + ATK + SPD + DEF + RES + Total, heroes[train[[fold]],])
#   lm_predict[[fold]] = heroes[test[[fold]],]
#   lm_predict[[fold]]$predicted = as.class(predict(lm_hero[[fold]], heroes[test[[fold]],]))
#   lm_accuracy[fold] = length(which(lm_predict[[fold]]$Tier == lm_predict[[fold]]$predicted)) / length(lm_predict[[fold]]$Tier == lm_predict[[fold]]$predicted)
# }
# 
# accuracy_lm = mean(lm_accuracy)























