# Downloads all available archive files from AEMO and saves to a file noting date limits
# Real time dataset is Public_DispatchSCADA_YYYY
# Current: http://www.nemweb.com.au/REPORTS/CURRENT/Dispatch_SCADA/
# Archive: http://www.nemweb.com.au/REPORTS/ARCHIVE/Dispatch_SCADA/

library(XML)
library(plyr)
library(googleVis)
library(stringr)

# Define base variables
Nem_base_url <- "http://www.nemweb.com.au/"
Arch_url <- "http://www.nemweb.com.au/REPORTS/ARCHIVE/Dispatch_SCADA/"
Curr_url <- "http://www.nemweb.com.au/REPORTS/CURRENT/Dispatch_SCADA/"
Gendata <- read.csv("NEMData.csv")

# Downloads archive SCADA file from NEM website in correct format  

Download_Arch <- function(baseurl,archurl,gendata) {
  
  Arch_parsed <- htmlParse(archurl)
  Arch_links <- xpathSApply(Arch_parsed,"//@href")
  Arch_links <- paste(baseurl,Arch_links,sep="")
  Last <- length(Arch_links)
  First_link <- Arch_links[1]
  Last_link <- Arch_links[Last]
  dtf <- strsplit(First_link,"_")
  dtf <- as.POSIXct(strptime(dtf[3],"%Y%m%d%H%M"))
  dtl <- strsplit(Last_link,"_")
  dtl <- as.POSIXct(strptime(dtl[3],"%Y%m%d%H%M"))
  
  Archive_data <- {data.frame(datetime=character(),DUID=character(),
                               MW=numeric(),State=numeric(),
                               Inertia=numeric(),Region=character())}
  
  for(i in Arch_links) {
    download.file(i,"temparch.zip")
    ziplist <- unzip("temparch.zip")
    for (j in ziplist) {
            tempzip <- unzip(j)
            templist <- download.file(tempzip)
            Arch_file <- read.csv(templist,skip=2,header=F)
            unlink(templist)
            Arch_file <- subset(Arch_file,select=V5:V7)
            names(Arch_file)<-c("datetime","DUID","MW")
            Arch_file$State <- as.numeric(Arch_file$MW>0)
            Arch_file$datetime<-as.POSIXct(strptime(Arch_file$datetime,"%Y/%m/%d %H:%M:%S"))
            Arch_file <- na.omit(Arch_file)
            len <- length(Arch_file$DUID)
            
            for(i in 1:len) {
              index <- match(Arch_file$DUID[i],gendata$DUIDUn,nomatch = "NA")
              Arch_file$Inertia[i] <- gendata$Inertia[index]*Arch_file$State[i]
              Arch_file$Region[i] <- as.character(gendata$Region[index])
              {if(Arch_file$Region[i] == "NSW1" ||
                  Arch_file$Region[i] == "QLD1" ||
                  Arch_file$Region[i] == "VIC1" ) Arch_file$Region[i] <- "NEM1"
              }
            Arch_file$Technology[i] <- as.character(gendata$Technology.Descriptor[index])
            Arch_file$Participant[i] <- as.character(gendata$Participant[index])
            }
    
    Archive_data <- rbind(Archive_data,na.omit(Arch_file))
    
      }
      }
  
  
  return(Archive_data)  

  }