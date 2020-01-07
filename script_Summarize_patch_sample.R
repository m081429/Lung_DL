

Data<-read.table('Final_res.txt',header=F, sep="\t",stringsAsFactors = F)

library(tidyverse)
library(pROC)
library(caret)

Data1<-read.table('inference_input.txt',header=F, sep="\t",stringsAsFactors = F)
Data1<-as.vector(Data1[,1])
Data1<-data.frame(do.call(rbind, strsplit(Data1, '.', fixed=TRUE)))
Data1<-Data1[,c(1,3)]
colnames(Data1)<-c("Subject","group")
Data<-merge(Data,Data1,by="Subject")

names(Data)=c("Sample","Subtype","logit0","logit1")
Data$Status<-0
Data$Status[which(Data$Subtype=="SQCC")]<-1
Data$Subject = gsub("_[A-Z0-9]*","",Data$Sample)


Data$softmax=NULL

Data$Status = as.factor(Data$Status)
for (x in 1:nrow(Data)){
  z = c(Data$logit0[x], Data$logit1[x])
  z_2 = exp(z)/sum(exp(z))
  Data$softmax[x] = z_2[2]
}


train = Data %>% 
  group_by(Subject) %>%
  filter(Group =="train") %>%
  mutate(Prediction=mean(softmax)) %>%
  select(-logit0,-logit1,-softmax,-Sample) %>%
  unique()

TRAINING_RESULTS = NULL
tmp = train
tmp2 = roc(tmp$Status, tmp$Prediction)
d = data.frame("AUC"=as.vector(tmp2$auc))
d = cbind(d,data.frame(t(coords(tmp2,"best"))))
TRAINING_RESULTS = rbind(TRAINING_RESULTS, d)
TRAINING_RESULTS

test = Data %>% 
  group_by(Subject) %>%
  filter(Group =="test") %>%
  mutate(Prediction=mean(softmax)) %>%
  select(-logit0,-logit1,-softmax,-Sample) %>%
  unique()



TESTING_RESULTS = NULL
tmp = test
thresh = TRAINING_RESULTS$threshold
tmp$Prediction0<-tmp$Prediction
tmp$Prediction = ifelse(tmp$Prediction0 > thresh, 1,0)
cm = confusionMatrix(table(tmp$Status,tmp$Prediction), positive='1')
tmp = as.vector(cm$table)
names(tmp) = c("TN","FP","FN","TP")
cm = as.data.frame(t(cm$byClass))
cm = as.data.frame(c(cm,tmp))
TESTING_RESULTS = rbind(TESTING_RESULTS, cm)
TESTING_RESULTS %>%
  select(Sensitivity, Specificity, F1, TP, FP, FN, TN)

