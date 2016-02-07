# Downloads current and archive files from AEMO
# Real time dataset is Public_DispatchSCADA_YYYY
# Current: http://www.nemweb.com.au/REPORTS/CURRENT/Dispatch_SCADA/
# Archive: http://www.nemweb.com.au/REPORTS/ARCHIVE/Dispatch_SCADA/

library(XML)
library(plyr)
library(googleVis)

Download_Curr <- function(baseurl,currurl,gendata) {
 
# Downloads latest SCADA file from NEM website in correct format  

     Curr_parsed <- htmlParse(Curr_url)
  Curr_links <- xpathSApply(Curr_parsed,"//@href")
  Curr_links <- paste(Nem_base_url,Curr_links,sep="")
  Latest_link <- Curr_links[length(Curr_links)]
  download.file(Latest_link,"Curr_SCADA.zip")
  Curr_fileref <- unzip("Curr_SCADA.zip")
  Curr_fileref <- file.rename(Curr_fileref,"AACurr_SCADA.csv")
  Curr_file <- read.csv("AACurr_SCADA.csv",skip=2,header=F)
  Curr_file <- subset(Curr_file,select=V5:V7)
  Curr_file$State <- (Curr_file$V7>0)*1
  names(Curr_file)<-c("datetime","DUID","MW","State")
  Curr_file$Time <- strptime(Curr_file$Time,"%Y/%m/%d %H:%M:%S")
  Curr_file <- na.omit(Curr_file)
  
  len <- length(Curr_file$DUID)
  
  # Searches Generator reference data for Inertia metric
  
  for(i in 1:len) {
            index <- match(Curr_file$DUID[i],Gendata$DUIDUn,nomatch = "NA")
            Curr_file$Inertia[i] <- Gendata$Inertia[index]
            Curr_file$Region[i] <- as.character(Gendata$Region[index])
            }
  
  # Calculates total inertia and inertia by NEM Region
  Tot_I <- sum(na.omit(Curr_file$Inertia))
  NSW_I <- sum(na.omit(subset(Curr_file,Region=="NSW-1")$Inertia))
  
  State_inert <- ddply(Curr_file,.(Region),summarise,Inertia=sum(Inertia))
  State_inert[6,1] <- "QLD-NSW-VIC"
  State_inert[6,2] <- State_inert[1,2]+State_inert[2,2]+State_inert[5,2]
  
  Output <- paste("Total System Inertia is ",Tot_Inertia,"MW, as at ",Curr_file$Time[1])
  print(Output)
  print(State_inert)
  
            
}
  


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

