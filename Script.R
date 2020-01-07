library(tidyverse)
library(pROC)
library(caret)

Data<-read.table("level2_res.txt",header=F, sep="\t",stringsAsFactors=F)
names(Data)=c("Sample","Status","prediction")
Data$Subject = gsub("_[A-Z0-9]*","",Data$Sample)
Data$Gene<-"A"
input<-read.table('samplelist_level2.txt',header=F, sep="\t",stringsAsFactors=F)
colnames(input)<-c("Subject","Subtype","Group")
data<-merge(Data,input,by="Subject")

Data<-data
Data$Status = as.factor(Data$Status)

Data$Status1<-1
Data$Status1[which(Data$Subtype=="ADC")]<-0
Data$Status<-Data$Status1


train = Data %>% 
  group_by(Subject) %>%
  filter(Group =="train") %>%
  mutate(Prediction=mean(prediction)) %>%
  select(-prediction,-Sample) %>%
  unique()

test = Data %>% 
  group_by(Subject) %>%
  filter(Group =="test") %>%
  mutate(Prediction=mean(prediction)) %>%
  select(-prediction,-Sample) %>%
  unique()
  

TRAINING_RESULTS = NULL
tmp2 = roc(train$Status1, train$Prediction)
d = data.frame("AUC"=as.vector(tmp2$auc))
d = cbind(d,data.frame(t(coords(tmp2,"best"))))
TRAINING_RESULTS = rbind(TRAINING_RESULTS, d)
TRAINING_RESULTS

tmp = test
thresh = as.double(TRAINING_RESULTS['threshold'])
tmp$Prediction1<-0
tmp$Prediction<-as.double(tmp$Prediction)
tmp$Prediction1[which(tmp$Prediction > thresh)]<-1
cm = confusionMatrix(table(tmp$Status1,tmp$Prediction1), positive='1')
tmp = as.vector(cm$table)
names(tmp) = c("TN","FP","FN","TP")
cm = as.data.frame(t(cm$byClass))
cm = as.data.frame(c(cm,tmp))
TESTING_RESULTS = NULL
TESTING_RESULTS = rbind(TESTING_RESULTS, cm)
TESTING_RESULTS

