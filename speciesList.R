# RMBranto Feb 2015
# create taxon list using http://www.marinespecies.org/aphia.php?p=match 
# need to fiqure out WoRMS web services

library(XLConnect)
library(plyr)

tnames<-data.frame(ScientificName=unique(z$ScientificName),stringsAsFactors=F)
wb<-loadWorkbook("tnames.xlsx", create = TRUE)
createSheet(wb, name="Sheet1")
writeWorksheet(wb, tnames, sheet="Sheet1", header=F)
saveWorkbook(wb)

##  http://www.marinespecies.org/aphia.php?p=match 
##  cnames, imageURL and imageLink coulmn were added manually
##  need to cnvert this WoRMS web services

wb<-loadWorkbook("tnames_matched_with_cnames.xlsx")
tnames_matched<-readWorksheet(wb,sheet=1)

tnames_matched$ScientificName<-sub("\\s+$","",tnames_matched$ScientificName)

z<-merge(
  x=z,
  y=tnames_matched[,c(1:4,6,9,7,10:26)],
  by='ScientificName'
)

write.csv(z,file=paste(project,".csv",sep=''))

z<-read.csv(paste(project,'.csv',sep=''),as.is=T)
Id<-1:dim(z)[1]

dd<-data.frame(Id=Id,X=z$longitude,Y=z$latitude,stringsAsFactors=F)
ddTable<-data.frame(Id,z,stringsAsFactors=F)
ddTable$dateCollected<-as.Date(ddTable$dateCollected)
ddShapefile <- convert.to.shapefile(dd, ddTable, 'Id', 1)
write.shapefile(ddShapefile, project, arcgis=T)
zip(paste(project,'.zip',sep=''),paste(project,c('.shp','.shx','.dbf'),sep=''),flags='-m')
