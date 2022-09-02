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

    if (file_num<100){ # EXP
        EXP_tajD=c(EXP_tajD, mean_tajD)
    }

    if (file_num>=100 & file_num<200){ # CST
        CST_tajD=c(CST_tajD, mean_tajD)
    }

    if (file_num>=200){ # BTL
        BTL_tajD=c(BTL_tajD, mean_tajD)
    }  
    file_num=file_num+1
    
}

dens_CST <- density(CST_tajD)
dens_BTL <- density(BTL_tajD, plot=F)
dens_EXP <- density(EXP_tajD, plot=F)


hist_CST <- hist(CST_tajD)
hist_BTL <- hist(BTL_tajD, plot=F)
hist_EXP <- hist(EXP_tajD, plot=F)


# plot density

plot(dens_CST, col="green",
main="Estimated Tajima's D for 3 values of r_chg",
xlab="Tajima's D",
ylab="Density")
legend(x=2, y=0.5, legend=c("CST", "BTL", "EXP"),
col=c("green", "blue", "red"), lty=1, cex=0.8)
lines(dens_BTL, col="blue")
lines(dens_EXP, col="red")


# plot hist

plot(hist_CST, col="green",
main="Estimated Tajima's D under 3 scenarios",
xlab="Tajima's D",
ylab="Density")
legend(x=2, y=0.5, legend=c("CST", "BTL", "EXP"),
col=c("green", "blue", "red"), lty=1, cex=0.8)
lines(hist_BTL, col="blue")
lines(hist_EXP, col="red")



########################################################


# TajD from SLiM

library(tidyverse)

tajD = as_tibble(read.table("Taj_D.txt", header=T))
tajD1 = as_tibble(read.table("Taj_D_1.txt", header=T))
tajD2 = as_tibble(read.table("Taj_D_2.txt", header=T))
tajD3 = as_tibble(read.table("Taj_D_3.txt", header=T))
tajD4 = as_tibble(read.table("Taj_D_4.txt", header=T))
tajD5 = as_tibble(read.table("Taj_D_5.txt", header=T))
tajD6 = as_tibble(read.table("Taj_D_6.txt", header=T))
tajD7 = as_tibble(read.table("Taj_D_7.txt", header=T))
tajD8 = as_tibble(read.table("Taj_D_8.txt", header=T))
tajD9 = as_tibble(read.table("Taj_D_9.txt", header=T))

D12 = left_join(tajD, tajD1, by="generation")
D12 = left_join(D12, tajD2, by="generation")
D12 = left_join(D12, tajD3, by="generation")
D12 = left_join(D12, tajD4, by="generation")
D12 = left_join(D12, tajD5, by="generation")
D12 = left_join(D12, tajD6, by="generation")
D12 = left_join(D12, tajD7, by="generation")
D12 = left_join(D12, tajD8, by="generation")
D12 = left_join(D12, tajD9, by="generation")

D12 = rename(D12, D1 = TajD.x, D2 = TajD.y, D3 = TajD.x.x, D4 = TajD.y.y, D5 = TajD.x.x.x, D6 = TajD.y.y.y, D7 = TajD.x.x.x.x, D8 = TajD.y.y.y.y, D9 = TajD.x.x.x.x.x, D10 = TajD.y.y.y.y.y)

fullTajD <- D12 %>% pivot_longer(c(D1, D2, D3, D4, D5, D6, D7, D8, D9, D10), names_to = "sim", values_to = "tajD")

ggplot (fullTajD, aes(x=generation, y=tajD, color=sim)) + geom_smooth() + geom_hline(yintercept = 2, color = "red")