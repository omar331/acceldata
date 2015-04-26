library(reshape)
library(dplyr)
library(sqldf)


# get the list of features (measurements)
features = read.table("UCI HAR Dataset/features.txt", header = FALSE, col.names=c("id", "name"))

# get the possible activities and their labels
activities = read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE, col.names=c("id", "activity"))


# function get_domain_dataset()
# Get the merged dataset of a certain domain.
#     - domain can be either 'test' or 'train'.
#   The following variables must be defined in parent scope:
#     - features - a dataframe containing the features name
#     - activities - a dataframe containing the possible activities
#
#
get_domain_dataset = function(domain) {
  #
  # get the SUBJECTS of each observation
  #
  file <- paste( c("./UCI HAR Dataset/", domain, "/subject_", domain, ".txt"), collapse="")
  subjects = readLines(file)

  
  #
  # get performed action for each observation
  #
  file <- paste( c("./UCI HAR Dataset/", domain, "/y_", domain, ".txt"), collapse="")
  actions = readLines(file)
  

  
  #
  # get the measuments
  #
  file <- paste( c("./UCI HAR Dataset/", domain, "/X_", domain, ".txt"), collapse="")
  measurements = read.table(file, header=FALSE)
  
  # "Appropriately labels the data set with descriptive variable names"
  names(measurements) <- features$name
  
  #
  # Merge all the data into resulting dataset
  #
  
  # create the resulting dataset
  dataset <- measurements
  

  # Add subjects and domain to resulting dataset
  dataset[,"subject"] <- subjects
  dataset[,"domain"] <- domain

  # Add actions to resulting dataset
  dataset <- cbind(activityId=actions, dataset)
  
  # "Uses descriptive activity names to name the activities in the data set"
  dataset = merge(dataset, activities, by.x="activityId", by.y="id")

  # Rearrange de columns
  finalColumns = c("domain", "subject", "activity",as.vector(features$name) )  
  dataset[finalColumns]
}

#
# function sqlAvg
#     Build SQL statement for getting the average of each measurement.
#     The list of measurements must be in feature and declared in global scope
#
sqlAvg <- function(datasetName) {
  cols <- "subject, activity,"
  for(feature in features$name) {
    col <-paste( c("avg(`", feature, "`) as `avg-", feature, "`, " ), collapse="")
    
    cols <- paste( c(cols, col), collapse="" )
    
  }
  cols <- substr(cols, 1, nchar(cols) - 2)
  
  sql <- paste( c("select ", cols, " from ", datasetName ," group by subject, activity"), collapse="")  
  
  sql
}


#
#  ---> step 1: "Merges the training and the test sets to create one data set"
#
testdata <- get_domain_dataset('test');
traindata <- get_domain_dataset('train');

testAndTrainData <- rbind( testdata, traindata )


#
#  ---> step 2: "Extracts only the measurements on the mean and standard deviation for each measurement"
#
mean_features <- features$name[grep("mean", features$name)]
std_features <- features$name[grep("std", features$name)]

std_mean_features <- c(as.vector(mean_features), as.vector(std_features) )

meanAndStdMeasurements <- testAndTrainData[std_mean_features]


#
#  ---> step 3: "Uses descriptive activity names to name the activities in the data set"
#

# It's already done! This operations was performed by get_domain_dataset() function used to gather the datasets in step 1

#
#  ---> step 4: "Appropriately labels the data set with descriptive variable names"
#

# Already done as part of function get_domain_dataset()


#
#  ---> step 5: "From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject."
#

# generate a SQL statement for getting the averages and put the results into dataset subjectActivityAverages
sqlTidyAvg <- sqlAvg("testAndTrainData")
subjectActivityAverages <- sqldf(sqlTidyAvg)

write.table(subjectActivityAverages, file = "averages.txt", row.names=FALSE)

