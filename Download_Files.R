# Downloads current and archive files from AEMO
# Public_DispatchSCADA
# Current: http://www.nemweb.com.au/REPORTS/CURRENT/Dispatch_SCADA/
# Archive: http://www.nemweb.com.au/REPORTS/ARCHIVE/Dispatch_SCADA/

Curr_websource <- "http://www.nemweb.com.au/REPORTS/CURRENT/Dispatch_SCADA/"
Arch_websource <- "http://www.nemweb.com.au/REPORTS/ARCHIVE/Dispatch_SCADA/"

Filelist_Current <- read.csv("Filelist_Current.csv",header=FALSE)
Filelist_Archive <- read.csv("Filelist_Archive.csv",header=FALSE)
Filelist_Current <- paste(Curr_websource,Filelist_Current[,1],sep="")
Filelist_Archive <- paste(Arch_websource,Filelist_Archive[,1],sep="")

## Downloads and unzips Current files


# for(id in Filelist_Current) {
#         download.file(id,"tempcurr.zip")
#         unzip("tempcurr.zip")
#         
#        }
# 
# unlink("tempcurr.zip")

# Downloads and unzips Archive files

for(id2 in Filelist_Archive) {
        download.file(id2,"temparch.zip")
        templist <- unzip("temparch.zip")
        for (id3 in templist) {
                unzip(id3)
                }
        unlink(id3)
        }




