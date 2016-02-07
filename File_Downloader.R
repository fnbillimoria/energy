# Downloads current and archive files from AEMO
# Real time dataset is Public_DispatchSCADA_YYYY
# Current: http://www.nemweb.com.au/REPORTS/CURRENT/Dispatch_SCADA/
# Archive: http://www.nemweb.com.au/REPORTS/ARCHIVE/Dispatch_SCADA/

library(XML)
library(plyr)
library(googleVis)

# Downloads latest SCADA file from NEM website in correct format  

Download_Curr <- function(baseurl,currurl,gendata) {
 
  Curr_parsed <- htmlParse(currurl)
  Curr_links <- xpathSApply(Curr_parsed,"//@href")
  Curr_links <- paste(baseurl,Curr_links,sep="")
  Latest_link <- Curr_links[length(Curr_links)]
  download.file(Latest_link,"Curr_SCADA.zip")
  Curr_fileref <- unzip("Curr_SCADA.zip")
  #Curr_fileref <- file.rename(Curr_fileref,"AACurr_SCADA.csv")
  Curr_file <- read.csv(Curr_fileref,skip=2,header=F)
  Curr_file <- subset(Curr_file,select=V5:V7)
  names(Curr_file)<-c("datetime","DUID","MW")
  Curr_file$State <- as.numeric(Curr_file$MW>0)
  Curr_file$datetime <- strptime(Curr_file$datetime,"%Y/%m/%d %H:%M:%S")
  Curr_file <- na.omit(Curr_file)
  len <- length(Curr_file$DUID)
  
  for(i in 1:len) {
            index <- match(Curr_file$DUID[i],gendata$DUIDUn,nomatch = "NA")
            Curr_file$Inertia[i] <- gendata$Inertia[index]*Curr_file$State[i]
            Curr_file$Region[i] <- as.character(gendata$Region[index])
                    {if(Curr_file$Region[i] == "NSW1" ||
                        Curr_file$Region[i] == "QLD1" ||
                        Curr_file$Region[i] == "VIC1" ) Curr_file$Region[i] <- "NEM1"
                    }
            Curr_file$Technology[i] <- as.character(gendata$Technology.Descriptor[index])
            Curr_file$Participant[i] <- as.character(gendata$Participant[index])
            }
  
  # Calculates total inertia and inertia by NEM Region
  
   Curr_file <- na.omit(Curr_file)
   return(Curr_file)
}

Download_Last_Day <- function(baseurl,currurl,gendata) {
  
  Curr_parsed <- htmlParse(currurl)
  Curr_links <- xpathSApply(Curr_parsed,"//@href")
  Curr_links <- paste(baseurl,Curr_links,sep="")
  Latest <- length(Curr_links)
  endlink <- 288
  startlink <- Latest - endlink + 1
  Last_day_data <- {data.frame(datetime=character(),DUID=character(),
                              MW=numeric(),State=numeric(),
                              Inertia=numeric(),Region=character())}
  
  for(i in startlink:endlink) {
            download.file(Curr_links[i],"tempcurr.zip")
            Curr_fileref <- unzip("tempcurr.zip")
            #Curr_fileref <- file.rename(Curr_fileref,"Curr_SCADA.csv")
            Curr_file <- read.csv(Curr_fileref,skip=2,header=F)
            unlink(Curr_fileref)
            Curr_file <- subset(Curr_file,select=V5:V7)
            names(Curr_file)<-c("datetime","DUID","MW")
            Curr_file$State <- as.numeric(Curr_file$MW>0)
            Curr_file$datetime<-as.POSIXct(strptime(Curr_file$datetime,"%Y/%m/%d %H:%M:%S"))
            Curr_file <- na.omit(Curr_file)
            len <- length(Curr_file$DUID)
            
            for(i in 1:len) {
              index <- match(Curr_file$DUID[i],gendata$DUIDUn,nomatch = "NA")
              Curr_file$Inertia[i] <- gendata$Inertia[index]*Curr_file$State[i]
              Curr_file$Region[i] <- as.character(gendata$Region[index])
                      {if(Curr_file$Region[i] == "NSW1" ||
                          Curr_file$Region[i] == "QLD1" ||
                          Curr_file$Region[i] == "VIC1" ) Curr_file$Region[i] <- "NEM1"
                      }
              Curr_file$Technology[i] <- as.character(gendata$Technology.Descriptor[index])
              Curr_file$Participant[i] <- as.character(gendata$Participant[index])
            }
            
            Last_day_data <- rbind(Last_day_data,na.omit(Curr_file))
            
          }

return(Last_day_data)  
#     
#   
    
#   NSW_I <- sum(na.omit(subset(Curr_file,Region=="NSW-1")$Inertia))
#   
#   State_inert <- ddply(Curr_file,.(Region),summarise,Inertia=sum(Inertia))
#   State_inert[6,1] <- "QLD-NSW-VIC"
#   State_inert[6,2] <- State_inert[1,2]+State_inert[2,2]+State_inert[5,2]
#   
#   Output <- paste("Total System Inertia is ",Tot_Inertia,"MW, as at ",Curr_file$Time[1])
#   print(Output)
#   print(State_inert)
  }
            
#
  


# # Searches Generator reference data for Inertia metric
# 
# for(i in 1:len) {
#           index <- match(Curr_file$DUID[i],Gendata$DUIDUn,nomatch = "NA")
#           Curr_file$Inertia[i] <- Gendata$Inertia[index]
#           Curr_file$Region[i] <- as.character(Gendata$Region[index])
#           }
# 
# # Calculates total inertia and inertia by NEM Region
# Tot_Inertia <- sum(na.omit(Curr_file$Inertia))
# 
# State_inert <- ddply(Curr_file,.(Region),summarise,Inertia=sum(Inertia))
# State_inert[6,1] <- "QLD-NSW-VIC"
# State_inert[6,2] <- State_inert[1,2]+State_inert[2,2]+State_inert[5,2]
# 
# Output <- paste("Total System Inertia is ",Tot_Inertia,"MW, as at ",Curr_file$Time[1])
# print(Output)
# print(State_inert)

