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
  Arch_links <- Arch_links[2:Last]
  First_link <- Arch_links[1]
  Last_link <- Arch_links[Last-1]
  dtf <- str_extract(First_link,"([[:digit:]]{8})")
  dtf <- as.POSIXct(strptime(dtf,"%Y%m%d"))
  dtl <- str_extract(Last_link,"([[:digit:]]{8})")
  dtl <- as.POSIXct(strptime(dtl,"%Y%m%d"))
  
  Archive_data <- {data.frame(datetime=character(),DUID=character(),
                               MW=numeric(),State=numeric(),
                               Inertia=numeric(),Region=character())}

  for(i in Arch_links) {
    download.file(i,"temparch.zip")
    ziplist <- unzip("temparch.zip")
    for (j in ziplist) {
            templist <- unzip(j)
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
             Arch_file$Technology[i] <- as.character(gendata$Technology.Descriptor[index])
             Arch_file$Participant[i] <- as.character(gendata$Participant[index])
            }
    
    Archive_data <- rbind(Archive_data,na.omit(Arch_file))
    
         }
  unlink(ziplist)  
    
  }
  
  write.csv(Archive_data,file="ArchiveInertia.csv")
  write.csv(c(dtf,dtl),file="archdates.csv")
  return(Archive_data)  

}

Download_Arch(Nem_base_url,Arch_url,Gendata)
