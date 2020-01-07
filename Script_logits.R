library(tidyverse)
library(pROC)
library(caret)

#Data<-read.table("level3_res.txt",header=F, sep="\t",stringsAsFactors=F)
#Data<-read.table("level2_res.txt",header=F, sep="\t",stringsAsFactors=F)
Data<-read.table("level2_res_new.txt",header=F, sep="\t",stringsAsFactors=F)
names(Data)=c("Sample","Status","logit0","logit1")
Data$Subject = gsub("_[A-Z0-9]*","",Data$Sample)
Data$Gene<-"A"
#input<-read.table('samplelist.txt',header=F, sep="\t",stringsAsFactors=F)
#input<-read.table('samplelist_level2.txt',header=F, sep="\t",stringsAsFactors=F)
#colnames(input)<-c("Subject","Subtype","Group")

input<-read.table('final_confirm_tf_record_level2_geneexp.xls',header=F, sep="\t",stringsAsFactors=F)
data<-merge(Data,input,by="Subject")
Data<-data
Data$softmax=NULL
Data$Status = as.factor(Data$Status)
for (x in 1:nrow(Data)){
  z = c(Data$logit0[x], Data$logit1[x])
  z_2 = exp(z)/sum(exp(z))
  Data$softmax[x] = z_2[2]
}

Data$Status1<-1
Data$Status1[which(Data$Subtype=="ADC")]<-0
Data$Status<-Data$Status1
train = Data %>% 
  group_by(Subject, Gene) %>%
  filter(Group =="train") %>%
  mutate(Prediction=mean(softmax)) %>%
  select(-logit0,-logit1,-softmax,-Sample) %>%
  unique()
test = Data %>% 
  group_by(Subject, Gene) %>%
  filter(Group =="test") %>%
  mutate(Prediction=mean(softmax)) %>%
  select(-logit0,-logit1,-softmax,-Sample) %>%
  unique()
val = Data %>% 
  group_by(Subject, Gene) %>%
  filter(Group =="val") %>%
  mutate(Prediction=mean(softmax)) %>%
  select(-logit0,-logit1,-softmax,-Sample) %>%
  unique()
TRAINING_RESULTS = NULL
for (gene in unique(train$Gene)){
  tmp = train[which(train$Gene==gene),]
  tmp2 = roc(tmp$Status, tmp$Prediction)
  d = data.frame("Gene"=gene,"AUC"=as.vector(tmp2$auc))
  d = cbind(d,data.frame(t(coords(tmp2,"best"))))
  TRAINING_RESULTS = rbind(TRAINING_RESULTS, d)
}
TRAINING_RESULTS
gene<-unique(test$Gene)[1]
tmp = test[which(test$Gene==gene),]
thresh = TRAINING_RESULTS[which(TRAINING_RESULTS$Gene==gene),'threshold']
tmp$Prediction = ifelse(tmp$Prediction > thresh, 1,0)
cm = confusionMatrix(table(tmp$Status,tmp$Prediction), positive='1')
tmp = as.vector(cm$table)
names(tmp) = c("TN","FP","FN","TP")
cm = as.data.frame(t(cm$byClass))
cm = as.data.frame(c(cm,tmp, "Gene"=gene))
cm

#Newcode
# # Gene_RESULTS 
# Gene_RESULTS = NULL
# for (gene in unique(Data$Gene)){
	# tmp = Data[which(Data$Gene==gene & Data$Group=="train"),]
	# tmp2 = roc(tmp$Status, tmp$softmax)
	# d = data.frame("Gene"=gene,"AUC"=as.vector(tmp2$auc))
	# d = cbind(d,data.frame(t(coords(tmp2,"best"))))
	# Gene_RESULTS = rbind(Gene_RESULTS, d)
# }
# Gene_RESULTS
# TRAINING_RESULTS = NULL
# for (gene in as.character(Gene_RESULTS$Gene)){
	# thresh = Gene_RESULTS[which(Gene_RESULTS$Gene==gene),'threshold']
	# tmp = Data[which(Data$Gene==gene & Data$Group=="train"),]
	# original<-c()
	# predicted<-c()
	# for (samp in unique(tmp$Subject)){
		# tmp1  = tmp[which(tmp$Subject==samp),]
		# per_gt_thres=length(which(tmp1$softmax>thresh))/nrow(tmp1)
		# original<-c(original,as.numeric(as.character(tmp1$Status[1])))
		# predicted<-c(predicted,ifelse(per_gt_thres >= 0.50, 1,0))
	# }
	# cm = confusionMatrix(table(original,predicted), positive='1')
	# tmp3 = c(as.vector(cm$table),thresh)
	# names(tmp3) = c("TN","FP","FN","TP","threshold")
	# cm = as.data.frame(t(cm$byClass))
	# cm = as.data.frame(c(cm,tmp3, "Gene"=gene))
	# TRAINING_RESULTS = rbind(TRAINING_RESULTS, cm)
# }
# TRAINING_RESULTS
# TESTING_RESULTS = NULL
# for (gene in as.character(Gene_RESULTS$Gene)){
	# thresh = Gene_RESULTS[which(Gene_RESULTS$Gene==gene),'threshold']
	# tmp = Data[which(Data$Gene==gene & Data$Group=="test"),]
	# original<-c()
	# predicted<-c()
	# for (samp in unique(tmp$Subject)){
		# tmp1  = tmp[which(tmp$Subject==samp),]
		# per_gt_thres=length(which(tmp1$softmax>thresh))/nrow(tmp1)
		# original<-c(original,as.numeric(as.character(tmp1$Status[1])))
		# predicted<-c(predicted,ifelse(per_gt_thres >= 0.50, 1,0))
	# }
	# cm = confusionMatrix(table(original,predicted), positive='1')
	# tmp3 = c(as.vector(cm$table),thresh)
	# names(tmp3) = c("TN","FP","FN","TP","threshold")
	# cm = as.data.frame(t(cm$byClass))
	# cm = as.data.frame(c(cm,tmp3, "Gene"=gene))
	# TESTING_RESULTS = rbind(TESTING_RESULTS, cm)
# }
# TESTING_RESULTS 
