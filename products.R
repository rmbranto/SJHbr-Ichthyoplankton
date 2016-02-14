# RMBranton Feb 2016 
# prepare prducts from St John Harbour Icthyoplankton Data

print(table(z$season,z$year),zero.print='.')
print(table(paste(z$genus,ifelse(z$species=='','sp.',z$species)),paste(z$year,substr(z$lifeStage,1,1))),zero.print='.')
print(table(paste(z$genus,ifelse(z$species=='','sp.',z$species)),paste(z$Station,substr(z$lifeStage,1,1))),zero.print='.')
print(table(z$lifeStage))


# generate resords summary

summary<-aggregate(nrec~Station+longitude+latitude,data=z,FUN=sum)
write.csv(summary,file='summary.csv')

