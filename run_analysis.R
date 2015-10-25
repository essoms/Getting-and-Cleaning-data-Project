### Downloading and unzipping the data

filePath <- "C:/Users/LENOVO/Documents/Getting and cleaning data/Project/Dataset"
setwd(filePath)
dataUrl <- "http://d396qusza40orc.cloudfront.net/getdata/projectfiles/UCI%20HAR%20Dataset.zip"
download.file(dataUrl, "Dataset.zip")
unzip("Dataset.zip", exdir = "Dataset")

### Loading required packages
library(dplyr)
library(data.table)
library(tidyr)

### Reading Data from the files into variables 
path_rf <- file.path("./Dataset" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files
#Read the activity files

activityTrainData <- read.table(file.path(path_rf, "train", "y_train.txt"),header = FALSE)
activityTestData  <- read.table(file.path(path_rf, "test" , "y_test.txt" ),header = FALSE)

#Read the Subject files

subjectTrainData <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
subjectTestData  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

#Read Fearures files

featuresTestData  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
featuresTrainData <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)
##############################################################################################

#########1. Merges the training and the test sets to create one data set.#####################

###1.1 Concatenate the data tables by rows
subjectData <- rbind(subjectTrainData, subjectTestData)
activityData<- rbind(activityTrainData, activityTestData)
featuresData<- rbind(featuresTrainData, featuresTestData)

###1.2.set names to variables in the frame################

names(subjectData)<-c("subject")
names(activityData)<- c("activity")
featuresDataNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(featuresData)<- featuresDataNames$V2

###1.3Merge datatables to get the data frame dataFrames #########################
combineData <- cbind(subjectData, activityData)
dataFrame <- cbind(featuresData, combineData)

###2 Extracts only the measurements on the mean and standard deviation for each measurement. 
##2.1 Subset Name of Features by measurements on the mean and standard deviation

subfeaturesDataNames <- featuresDataNames$V2[grep("mean\\(\\)|std\\(\\)", featuresDataNames$V2)]

## 2.2 Subset the data frame  by seleted names of Features

selectedNames<-c(as.character(subfeaturesDataNames), "subject", "activity" )
dataFrame <- subset(dataFrame,select=selectedNames)


str(dataFrame)
### 3. Uses descriptive activity names to name the activities in the data set

##Read descriptive activity names from “activity_labels.txt”
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)

##facorize Variale activity in the data frame using descriptive activity names
dataFrame$activity <- as.character(dataFrame$activity)
dataFrame$activity[dataFrame$activity == 1] <- "Walking"
dataFrame$activity[dataFrame$activity == 2] <- "Walking Upstairs"
dataFrame$activity[dataFrame$activity == 3] <- "Walking Downstairs"
dataFrame$activity[dataFrame$activity == 4] <- "Sitting"
dataFrame$activity[dataFrame$activity == 5] <- "Standing"
dataFrame$activity[dataFrame$activity == 6] <- "Laying"
dataFrame$activity <- as.factor(dataFrame$activity)

head(dataFrame$activity,30)
### 4.Appropriately labels the data set with descriptive variable names

## Names before
head(str(dataFrame),2)

##Labeling data set

# Remove parentheses
names(dataFrame) <- gsub('\\(|\\)',"",names(dataFrame), perl = TRUE)
# Make syntactically valid names
names(dataFrame) <- make.names(names(dataFrame))
# Make clearer names

names(dataFrame) <- gsub('Acc',"Acceleration",names(dataFrame))
names(dataFrame) <- gsub('GyroJerk',"AngularAcceleration",names(dataFrame))
names(dataFrame) <- gsub('Gyro',"AngularSpeed",names(dataFrame))
names(dataFrame) <- gsub('Mag',"Magnitude",names(dataFrame))
names(dataFrame) <- gsub('^t',"TimeDomain.",names(dataFrame))
names(dataFrame) <- gsub('^f',"FrequencyDomain.",names(dataFrame))
names(dataFrame) <- gsub('\\.mean',".Mean",names(dataFrame))
names(dataFrame) <- gsub('\\.std',".StandardDeviation",names(dataFrame))
names(dataFrame) <- gsub('Freq\\.',"Frequency.",names(dataFrame))
names(dataFrame) <- gsub('Freq$',"Frequency",names(dataFrame))
###Checking
names(dataFrame)

###5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
dataFrame2<-aggregate(. ~subject + activity, dataFrame, mean)
dataFrame2<-dataFrame2[order(dataFrame2$subject,dataFrame2$activity),]
write.table(dataFrame2, file = "tidydata.txt",row.name=FALSE)

tidydata <- read.csv("~/Getting and cleaning data/Project/Dataset/tidydata.txt", sep="")
names(tidydata)
