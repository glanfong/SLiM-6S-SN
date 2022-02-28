# R code used to manage CHG_nomut simulations
# and check for tajD values


#### EXP ####

library(tidyverse)

files=list.files(path=".", pattern="sumStats", all.files=FALSE, full.names=FALSE)
EXP_tajD=c()

file_num=0

for (file in files) {

    sumStats=as_tibble(read.table(file, h=T))
    mean_tajD=sumStats %>% select(starts_with("tajD_")) %>% slice(1) %>% unlist(., use.names=FALSE) %>% mean(na.rm=T)

    if (file_num<100){ # EXP
        EXP_tajD=c(EXP_tajD, mean_tajD)
    }
    file_num=file_num+1
    
}

dens_EXP <- density(EXP_tajD)
plot(dens_EXP, col="red")


#### BTL ####



library(tidyverse)

files=list.files(path=".", pattern="sumStats", all.files=FALSE, full.names=FALSE)
BTL_tajD=c()

file_num=0

for (file in files) {

    sumStats=as_tibble(read.table(file, h=T))
    mean_tajD=sumStats %>% select(starts_with("tajD_")) %>% slice(1) %>% unlist(., use.names=FALSE) %>% mean(na.rm=T)

    if (file_num<100){ # EXP
        BTL_tajD=c(BTL_tajD, mean_tajD)
    }
    file_num=file_num+1
    
}

dens_BTL <- density(BTL_tajD)
plot(dens_BTL, col="blue")

### CST ###




### ALL CHG ###



library(tidyverse)

files=list.files(path=".", pattern="sumStats", all.files=FALSE, full.names=FALSE)
EXP_tajD=c()
CST_tajD=c()
BTL_tajD=c()

file_num=0

for (file in files) {

    sumStats=as_tibble(read.table(file, h=T))
    mean_tajD=sumStats %>% select(starts_with("tajD_")) %>% slice(1) %>% unlist(., use.names=FALSE) %>% mean(na.rm=T)

    if (file_num>=200){ # EXP
        EXP_tajD=c(EXP_tajD, mean_tajD)
    }

    if (file_num>=100 & file_num<200){ # CST
        CST_tajD=c(CST_tajD, mean_tajD)
    }

    if (file_num<100){ # BTL
        BTL_tajD=c(BTL_tajD, mean_tajD)
    }  
    file_num=file_num+1
    
}

dens_CST <- density(CST_tajD)
dens_BTL <- density(BTL_tajD)
dens_EXP <- density(EXP_tajD)


hist_CST <- hist(CST_tajD)
hist_BTL <- hist(BTL_tajD, plot=F)
hist_EXP <- hist(EXP_tajD, plot=F)


# plot density

plot(dens_CST, col="green",
main="Estimated Tajima's D for CST, EXP & BTL scenarios",
xlab="Tajima's D",
ylab="Density", ylim=c(0,1.6))
legend(x=2, y=1.5, legend=c("CST", "EXP", "BTL"),
col=c("green", "blue", "red"), lty=1, cex=0.8)
lines(dens_BTL, col="red")
lines(dens_EXP, col="blue")


# plot hist

plot(hist_CST, col="green",
main="Estimated Tajima's D under 3 scenarios",
xlab="Tajima's D",
ylab="Density")
legend(x=2, y=0.5, legend=c("CST", "BTL", "EXP"),
col=c("green", "blue", "red"), lty=1, cex=0.8)
lines(hist_BTL, col="blue")
lines(hist_EXP, col="red")


# ggplot from "tajD.txt"

tajD = as_tibble(read.table("tajimaD.txt", h=T))
ggplot(data=tajD, aes(x=tajD, group=scenario, fill=scenario)) + geom_density(adjust=1, alpha=0.4) + ggtitle("Distribution of TajD")
ggsave("TajD_treesTajD.png")


# load summary.txt file as summary

summary = as_tibble(read.table("summary.txt", h=T))

