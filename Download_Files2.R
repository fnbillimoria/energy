# Downloads current and archive files from AEMO
# Real time dataset is Public_DispatchSCADA_YYYY
# Current: 
#
# Historical dataset is Public_Daily_YYYYMMDD
# Current: http://www.nemweb.com.au/REPORTS/CURRENT/Daily_Reports/
# Archive: http://www.nemweb.com.au/REPORTS/ARCHIVE/Daily_Reports/

library(XML)

Nem_base_url <- "http://www.nemweb.com.au/"
Curr_url <- "http://www.nemweb.com.au/REPORTS/CURRENT/Daily_Reports/"
Arch_url <- "http://www.nemweb.com.au/REPORTS/ARCHIVE/Daily_Reports/"

Curr_parsed <- htmlParse(Curr_url)
Curr_links <- xpathSApply(Curr_parsed, "//@href")
Curr_links <- paste(Nem_base_url,Curr_links,sep="")

intertia <-

# Filelist_Current <- read.csv("Filelist_Current.csv",header=FALSE)
# Filelist_Archive <- read.csv("Filelist_Archive.csv",header=FALSE)
# Filelist_Current <- paste(Curr_websource,Filelist_Current[,1],sep="")
# Filelist_Archive <- paste(Arch_websource,Filelist_Archive[,1],sep="")
# 
# ## Downloads and unzips Current files


# for(id in Filelist_Current) {
#         download.file(id,"tempcurr.zip")
#         unzip("tempcurr.zip")
#         
#        }
# 
# unlink("tempcurr.zip")

# Downloads and unzips Archive files

# for(id2 in Filelist_Archive) {
#         download.file(id2,"temparch.zip")
#         templist <- unzip("temparch.zip")
#         for (id3 in templist) {
#                 unzip(id3)
#                 }
#         unlink(id3)
#         }
# 
# 


