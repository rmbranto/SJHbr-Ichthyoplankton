# RMBranto Feb 2015
# create taxon list using http://www.marinespecies.org/aphia.php?p=match 
# need to fiqure out WoRMS web services

library(XLConnect)
library(plyr)
library(shapefiles)
library(stringi)

tnames<-data.frame(ScientificName=unique(z$ScientificName),stringsAsFactors=F)
wb<-loadWorkbook("tnames.xlsx", create = TRUE)
createSheet(wb, name="Sheet1")
writeWorksheet(wb, tnames, sheet="Sheet1", header=F)
saveWorkbook(wb)

##  http://www.marinespecies.org/aphia.php?p=match 
##  cnames, imageURL and imageLink coulmn were added manually
##  need to cnvert this WoRMS web services

wb<-loadWorkbook("tnames_matched_with_egg_and_larva_images.xlsx")
y<-readWorksheet(wb,sheet=1)

y$ScientificName<-sub("\\s+$","",y$ScientificName)

zz<-merge(
  x=z,
   y=y,
by='ScientificName'
)

# determine caption, URL and link based on life stage

zz$imageCaption<-
  ifelse(zz$lifeStage=='eggs'&!is.na(zz$eggCaption),
         paste('Image of Egg found on ',zz$eggCaption,'. Click image for details.',sep=''),
         ifelse(zz$lifeStage=='larvae'&!is.na(zz$larvaCaption),
                paste('Image of Larvae found on ',zz$larvaCaption,'. Click image for details.',sep=''),
                paste(stri_trans_totitle(zz$lifeStage),'image not available. Click image to search Google.')))  

zz$imageURL<-
  ifelse(zz$lifeStage=='eggs'&!is.na(zz$eggURL),zz$eggURL,
         ifelse(zz$lifeStage=='larvae'&!is.na(zz$larvaURL),zz$larvaURL,
                zz$adultURL))
                  
zz$imageLink<-
  ifelse(zz$lifeStage=='eggs'&!is.na(zz$eggLink),zz$eggLink,
         ifelse(zz$lifeStage=='larvae'&!is.na(zz$larvaLink),zz$larvaLink,
                paste('http://www.google.com/images?q=',zz$ScientificName,'egg larva'))) 
                  
zz<-zz[,c("Locality.Name","Station","Set","latitude","longitude","dateCollected","year","month","season",
          "Surface.Temp","Bottom.Temp","Surface.Sal","Bottom.Sal","ScientificName","commonName","AphiaID",
          "lifeStage","size","Order","observedIndividuals","Family","Genus","Species","isMarine","isBrackish","isFresh","isTerrestrial",
          "imageCaption","imageURL","imageLink")]  

write.csv(zz,file=paste(project,".csv",sep=''))
zz<-read.csv(paste(project,'.csv',sep=''),as.is=T)
Id<-1:dim(zz)[1]

dd<-data.frame(Id=Id,X=zz$longitude,Y=zz$latitude,stringsAsFactors=F)
ddTable<-data.frame(Id,zz,stringsAsFactors=F)
ddTable$dateCollected<-as.Date(ddTable$dateCollected)
ddShapefile <- convert.to.shapefile(dd, ddTable, 'Id', 1)
write.shapefile(ddShapefile, project, arcgis=T)
zip(paste(project,'.zip',sep=''),paste(project,c('.shp','.shx','.dbf'),sep=''),flags='-m')
