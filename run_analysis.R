#Download Fild

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile="./WearableData.zip")

#Unzip file

unzip(zipfile="./WearableData.zip")

#Get the file list

path <- file.path("UCI HAR Dataset")
Listoffiles <-list.files(path, recursive=TRUE)

# Read the data form the Activity, Subject and Features files based upon the data frame structure.

Activity_Y_Test <-read.table(file.path(path,"test","Y_test.txt"), header = FALSE)
Activity_Y_Train <-read.table(file.path(path,"train","Y_train.txt"),header = FALSE)
SubjectTrain <- read.table(file.path(path,"train","subject_train.txt"),header = FALSE)
SubjectTest <- read.table(file.path(path, "test","subject_test.txt"),header=FALSE)
FeaturesTest <- read.table(file.path(path, "test", "X_test.txt"), header = FALSE)
FeaturesTrain <-read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

#Merge the data sets to have one set for Subject, Activity and Features data

MergeSubjectData <-rbind(SubjectTrain, SubjectTest)
MergeActivityData <- rbind(Activity_Y_Train, Activity_Y_Test)
MergeFeaturesData <- rbind(FeaturesTrain, FeaturesTest)

#Name the variables

names(MergeSubjectData) <-c("subject")
names(MergeActivityData) <- c("activity")
FeatureDataNames <-read.table(file.path(path, "features.txt"),head=FALSE)
names(MergeFeaturesData) <- FeatureDataNames$V2

#Create one 'Merged Data' data frame

CombinedSubjectActivity <- cbind(MergeSubjectData, MergeActivityData)
MergedData <-cbind(MergeFeaturesData,CombinedSubjectActivity)

#Take names of Features with mean or std, and subset the Merged Data frame by these names

subdataFeaturesNames <- FeatureDataNames$V2[grep("mean\\(\\)|std\\(\\)",FeatureDataNames$V2)]
SelectNames <-c(as.character(subdataFeaturesNames),"subject","activity")
MergedData <-subset(MergedData,select=SelectNames)

#Read descriptive activity names, and factorize the activity variable using the descriptive activity names

activitylabels <- read.table(file.path(path,"activity_labels.txt"),header=FALSE)
MergedData$activity<-factor(MergedData$activity); MergedData$activity <-factor(MergedData$activity,labels=as.character(activitylabels$V2))

#Label he names of features with descriptive variable names

names(MergedData) <-gsub("^t", "time", names(MergedData))
names(MergedData) <-gsub("^f", "frequency", names(MergedData))
names(MergedData) <-gsub("Acc", "Accelerometer", names(MergedData))
names(MergedData) <-gsub("Gyro", "Gyroscope", names(MergedData))
names(MergedData) <-gsub("Mag", "Magnitude", names(MergedData))
names(MergedData) <-gsub("BodyBody", "Body", names(MergedData))

#create independent tidy data set, using the average for each variable for each subject / activity

library(plyr);
TidyData <- aggregate(. ~subject + activity, MergedData, mean)
TidyData <- TidyData[order(TidyData$subject,TidyData$activity),]
write.table(TidyData, file = "TidyData.txt",row.name = FALSE)