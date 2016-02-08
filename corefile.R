# This is the core function that loads libraries, 

# Loads relevant libraries and files
library(XML)
library(plyr)
library(googleVis)
library(ggplot2)

source("File_Downloader.R")

# Define base variables
Nem_base_url <- "http://www.nemweb.com.au/"
Arch_url <- "http://www.nemweb.com.au/REPORTS/ARCHIVE/Dispatch_SCADA/"
Curr_url <- "http://www.nemweb.com.au/REPORTS/CURRENT/Dispatch_SCADA/"
Gendata <- read.csv("NEMData.csv")

# Downloads latest and last 24 hours of SCADA from NEM website in correct format

Curr_file1 <- Download_Curr(Nem_base_url,Curr_url,Gendata)
Curr_region <-  aggregate(Inertia ~  Region,data=Last_day_data,sum)
Curr_tech <-  aggregate(Inertia ~ datetime + Technology.Descriptor,data=Last_day_data,sum)
Last_day_part <-  aggregate(Inertia ~ datetime + Participant,data=Last_day_data,sum)


Last_day_file <- Download_Last_Day(Nem_base_url,Curr_url,Gendata)
Last_day_region <-  aggregate(Inertia ~ datetime + Region,data=Last_day_data,sum)
Last_day_tech <-  aggregate(Inertia ~ datetime + Technology.Descriptor,data=Last_day_data,sum)
Last_day_part <-  aggregate(Inertia ~ datetime + Participant,data=Last_day_data,sum)
remove(Last_day_file)

# Output 1: Current Inertia Gauge

Curr_file1





# Output 2: 
Arch_parsed <- htmlParse(Arch_url)
Arch_links <- xpathSApply(Arch_parsed,"//@href")
Arch_links <- paste(Nem_base_url,Arch_links,sep="")

# Downloads and unzips Archive files

# for(id2 in Arch_links) {
#   download.file(id2,"temparch.zip")
#   templist <- unzip("temparch.zip")
#   for (id3 in templist) {
#     templist2 <- unzip(id3)
#     tempzip <- download.file(templist2)
#     Arch_file <- read.csv(tempzip,skip=2,header=F)
#     Aurr_file <- subset(Curr_file,select=V5:V7)
#     Curr_file$State <- (Curr_file$V7>0)*1
#   }
#   unlink(id3)
# }


# 
# existingDF <- as.data.frame(matrix(seq(20),nrow=5,ncol=4))
# r <- 3
# newrow <- seq(4)
# insertRow <- function(existingDF, newrow, r) {
#   existingDF[seq(r+1,nrow(existingDF)+1),] <- existingDF[seq(r,nrow(existingDF)),]
#   existingDF[r,] <- newrow
#   existingDF
# }
