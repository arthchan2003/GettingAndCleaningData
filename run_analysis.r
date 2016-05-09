dataurl <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
zipfile <- 'dataset.zip'
datasetname <- 'UCI HAR Dataset'

if(!file.exists(zipfile)) {
	download.file(dataurl, zipfile, method = "curl")
	unzip (zipfile)
}else{
	print("data set is already downloaded.")
}

# 1, Merges the training and the test sets to create one data set.

X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
sub_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
sub_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

X_merged <- rbind(X_train, X_test)
y_merged <- rbind(y_train, y_test)
sub_merged <- rbind (sub_train, sub_test)
names(sub_merged) <- c("Subject")

# 2, Extracts only the measurements on the mean and standard deviation for each measurement.
features <- read.table("./UCI HAR Dataset/features.txt")[,2]
names(X_merged) <- features
matches <- grep("(mean|std)\\(\\)", features)
X_limited <- X_merged[, matches]

# 3, Uses descriptive activity names to name the activities in the data set
activities <-read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
y_descriptive= activities[y_merged[,1]]

# 4, Appropriately labels the data set with descriptive variable names.
names(X_limited) <- gsub("^t", "Time_", names(X_limited))
names(X_limited) <- gsub("^f", "FFT_", names(X_limited))
names(X_limited) <- gsub("-mean\\(\\)", "Mean", names(X_limited))
names(X_limited) <- gsub("-std\\(\\)", "StdDev", names(X_limited))
names(X_limited) <- gsub("Acc","_Accelerometer_", names(X_limited))
names(X_limited) <- gsub("Gyro","_Gyroscope_", names(X_limited))
names(X_limited) <- gsub("Jerk","Jerk_", names(X_limited))
names(X_limited) <- gsub("Mag","Mag_", names(X_limited))

# 4 -> 5 Before we go to step 5, now we have the three ingredients of the table.
# a, X_limited with limited labels and properly named variable names. 
# b, y_descriptive with descriptive names
# c, sub_merged with all subjects. 
# So now we just need to bind them together 
combined_table <- cbind (sub_merge, X_limited, y_descriptive)

# 5, From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
melted <- melt(combined_table, id=c("Subject","y_descriptive"))
tidied <- dcast(melted, Subject+y_descriptive ~ variable, mean)
names(tidied) <- gsub("y_descriptive","Activity", names(tidied) ) 
write.csv(tidied, "tidy.csv", row.names=FALSE)

