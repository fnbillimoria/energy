# Downloads and processes SCADA data

library(XML)
library(plyr)

Nem_base_url <- "http://www.nemweb.com.au/"

Arch_url <- "http://www.nemweb.com.au/REPORTS/ARCHIVE/Dispatch_SCADA/"
Curr_url <- "http://www.nemweb.com.au/REPORTS/CURRENT/Dispatch_SCADA/"

# Downloads latest SCADA file from NEM website in correct format
Arch_parsed <- htmlParse(Arch_url)
Arch_links <- xpathSApply(Arch_parsed,"//@href")
Arch_links <- paste(Nem_base_url,Arch_links,sep="")

# Downloads and unzips Archive files

for(id2 in Arch_links) {
  download.file(id2,"temparch.zip")
  templist <- unzip("temparch.zip")
  for (id3 in templist) {
    templist2 <- unzip(id3)
    tempzip <- download.file(templist2)
    arch_file <- read.csv(tempzip,skip=2,header=F)
  }
  unlink(id3)
}


# 
# existingDF <- as.data.frame(matrix(seq(20),nrow=5,ncol=4))
# r <- 3
# newrow <- seq(4)
# insertRow <- function(existingDF, newrow, r) {
#   existingDF[seq(r+1,nrow(existingDF)+1),] <- existingDF[seq(r,nrow(existingDF)),]
#   existingDF[r,] <- newrow
#   existingDF
# }
