# RMBranton Feb 2016 
# get and prepare St John Harbour Icthyoplankton Data

library(XLConnect)
library(plyr)
library(shapefiles)

# project metadata

project<-'ARC SJ Hbr ichthyoplankton 2011-14'
xlim<-c(-66.13,-65.93)
ylim<-c(45.17,45.27)
yrlim<-c(2011,2014)

# generate bounding box as shapefile

dd<-data.frame(
  Id=rep(1,5),
  X=c(xlim[1],xlim[1],xlim[2],xlim[2],xlim[1]),
  Y=c(ylim[1],ylim[2],ylim[2],ylim[1],ylim[1]),
  stringsAsFactors=F)

ddTable<-data.frame(Id=1,comment='bounding box',stringsAsFactors=F)
ddShapefile <- convert.to.shapefile(dd, ddTable, 'Id', 5)
write.shapefile(ddShapefile, 'bBox', arcgis=T)
zip('bBox.zip',c('bBox.shp','bBox.shx','bBox.dbf'))

# read data

wb<-loadWorkbook(paste(project,".xls",sep=""))
z<-readWorksheet(wb,sheet=1)

# standardize column names as required

z<-rename(z,c("Date"="dateCollected"))
z<-rename(z,c("Longitude1"="longitude","Latitude1"="latitude"))
z<-rename(z,c("Phylum"="phylum","Genus"="genus","Species"="species"))
z$observedIndividuals<-floor(abs(rnorm(dim(z)[1]))*100)+1
z$ScientificName<-sub("\\s+$","",paste(z$genus,z$species))
z$nrec<-1

# prepare dates

z$dateCollected<-as.Date(z$dateCollected,'%d/%m/%Y')
z$year=as.numeric(substr(z$dateCollected,1,4))
z$month=as.numeric(substr(z$dateCollected,6,7))

z$season<-substr(z$dateCollected,6,12)
z$season<-ifelse(z$season>'12-21',1,
                 ifelse(z$season>'09-21',4,
                        ifelse(z$season>'06-21',3,
                               ifelse(z$season>'03-21',2,1
                               ))))
z$season<-factor(z$season,labels=c('Winter','Spring','Summer','Fall'),ordered=T)

# prepare lats and lons

z$longitude<-as.numeric(z$longitude)
z$latitude<-as.numeric(z$latitude)

# prepare lifeStage and size

z<-rename(z,c("Size"="size"))
z$lifeStage<-ifelse(z$size=='Eggs','eggs','larvae')
z$size<-ifelse(z$size=='Eggs','',sub(' NL','',z$size))

# filter data 

z<-z[ z$year>=yrlim[1] & z$year<=yrlim[2] ,]  
z<-z[ z$long>=xlim[1] & z$long<=xlim[2] & z$lat>=ylim[1] & z$lat<=ylim[2],]
z<-z[!is.na(z$ScientificName)&!is.na(z$genus)&z$genus!='H4B'&z$genus!='Unidentifiable'&z$genus!='',]

# write data file

write.csv(z,file=paste(project,".csv",sep=''))

