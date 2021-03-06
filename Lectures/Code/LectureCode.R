# Internal functions, simulated data for demonstrations etc.


# Calculate estimates with standard errors with simple random sampling (SRS)
ySRS <- function(n, N, ybar, s2){
  results <- list(est = ybar, 
                  SE = sqrt((s2/n)*(1-n/N)))
                  return(results)
}

tSRS <- function(n, N, ybar, s2){
  results <- list(est = ybar*N, 
                  SE = N*sqrt((s2/n)*(1-n/N)))
                  return(results)
}

pSRS <- function(n, N, p){
  results <- list(est = p, 
                  SE = sqrt(p*(1-p)*(1/(n-1))*(1-n/N)))
                  return(results)
}


ySTRSRS <- function(nh, Nh, ybar, s2){
  results <- list(est = sum(ybar * Nh) / sum(Nh), 
                  SE = sqrt((1 / sum(Nh)^2) * sum(Nh^2 * (s2/nh) * (1-nh/Nh))),
                  wh = Nh / nh)
  return(results)
}

tSTRSRS <- function(nh, Nh, ybar, s2){
  ybarest <- ySTRSRS(nh = nh, Nh = Nh, ybar = ybar, s2 = s2)
  results <- list(est = sum(Nh) * ybarest$est,
                  SE = sum(Nh) * ybarest$SE,
                  wh = ybarest$wh)
  return(results)
}


# Data for examples in Lectures F3
generatePopIncome <- function(mySeed=as.numeric(Sys.Date())){
  set.seed(mySeed) 
  N <- 815598
  y1 <- rexp(round(N*0.25), rate=1/5000)
  y2 <- rnorm(round(N*0.65), mean=29000,sd=7500)
  y3 <- rexp(round(N*0.10), rate=1/30000)
  y <- round(c(y1,y2,y3))
  y <- y[sample(1:length(y),length(y))]
  return(data.frame(income=y))
}

# Create data for ploting SE, ME
plotnsizedata <- function(yPop, n, mySeed){
  stopifnot(max(n) < length(yPop))
  s <- sd(yPop)
  m <- mean(yPop)
  N <- length(yPop)
  SRSsample <- as.numeric(rep(NA,max(n)))
  sample_m <- sample_s <- sample_se <- as.numeric(rep(NA,length(n)))
  for (i in seq_along(n)){
    set.seed(mySeed)
    SRSsample[1:n[i]] <- sample(x=yPop,size=n[i])
    sample_m[i] <- mean(SRSsample,na.rm=TRUE)
    sample_s[i] <- sd(SRSsample,na.rm=TRUE)
    sample_se[i] <- ySRS(N=N,n=n[i],ybar=sample_m[i],s2=sample_s[i]^2)$SE
  }
  samplePlotData <- data.frame(n = n, mean = sample_m, s = sample_s ,SE = sample_se)
  samplePlotData$kiLow <- samplePlotData$mean - 1.96 * samplePlotData$SE
  samplePlotData$kiHigh <- samplePlotData$mean + 1.96 * samplePlotData$SE
  return(list(popMean = m, popStd = s, samplePlotData = samplePlotData))
}

# Create ggplots
createSampleEstPlots<- function(plotData, plotParts){
  ggplotsList <- list()  
  for (i in seq_along(plotParts)){
    sampleData <- plotData$samplePlotData
    sampleData[round(nrow(sampleData)*plotParts[i]):nrow(sampleData),2:ncol(sampleData)] <- NA
    ggplotsList[[length(ggplotsList)+1]] <- 
      ggplot(data=sampleData, aes(x=n, y=mean)) + 
      geom_line() + 
      geom_hline(yintercept=plotEx$popMean, col="red") +
      ylab(expression(bar(y))) +
      ylim(min(plotData$samplePlotData[,"mean"]), max(plotData$samplePlotData[,"mean"]))
    ggplotsList[[length(ggplotsList)+1]] <- 
      ggplot(data=sampleData, aes(x=n, y=s)) + 
      geom_line() + 
      geom_hline(yintercept=plotEx$popStd, col="red") +
      ylab(expression(s)) +
      ylim(min(plotData$samplePlotData[,"s"]), max(plotData$samplePlotData[,"s"]))
    ggplotsList[[length(ggplotsList)+1]] <- 
      ggplot(data=sampleData, aes(x=n, y=SE)) + geom_line() +
      ylim(min(plotData$samplePlotData[,"SE"]), max(plotData$samplePlotData[,"SE"]))    
    ggplotsList[[length(ggplotsList)+1]] <- 
      ggplot(sampleData, aes(x=n)) + 
      geom_line(aes(y = mean)) +
      geom_line(aes(y = kiLow), linetype="dashed") + 
      geom_line(aes(y = kiHigh), linetype="dashed") + 
      geom_hline(yintercept=plotEx$popMean, col="red") + 
      ylab(expression(bar(y))) +
      ylim(min(plotData$samplePlotData[,"kiLow"]), max(plotData$samplePlotData[,"kiHigh"]))    
  }
  return(ggplotsList)
}


# Gastroenteritis example in F4
generateGastro <- function(mySeed=20130206){
  set.seed(mySeed)
  # Create example
  N <- c(1687283, 1851959, 1812691, 2935231)
  n <- round(400.1*(N/sum(N)))
  
  e.y<-c(3.5,0.7,1.8,0.4) 
  age<-c(0,15,25,40,65) 
  y.mean<-numeric(length(n)) 
  y.s<-numeric(length(n))
  for(i in 1:length(n)){   
    y.temp<-round(rexp(n[i],1/e.y[i]))   
    y.mean[i]<-round(mean(y.temp),2)  
    y.s[i]<-round(sd(y.temp),2) 
    x.temp<-round(runif(n=n[i],min=age[i],max=age[i+1]))   
    if(i==1){y<-y.temp;x<-x.temp}   
    if(i>1){y<-c(y,y.temp);x<-c(x,x.temp)} 
  }
  gastro <- list()
  gastro$N <- N
  gastro$n <- n
  gastro$y <- y
  gastro$x <- x
  gastro$age <- age
  gastro$ybar <- y.mean
  gastro$ybarAll <- round(mean(y),2) 
  gastro$sy <- y.s
  gastro$syAll <- round(sd(y),2) 
  return(gastro) 
}
gastro <- generateGastro()

# Burglary example in F7
generateBurglary <- function(mySeed = 20140201, prop=c(0.3,0.8)){
  set.seed(mySeed)
  burgl <- list()
  burgl$n <- 4
  burgl$N <- 24
  burgl$y <- round(rgamma(burgl$N, shape=0.33*(10/1),scale=(10/1)))
  burgl$x <- round(burgl$y * runif(burgl$N, prop[1], prop[2]))
  return(burgl)
}

# Apelsinexempel
generateOrgange <-function(n=15, mySeed = 20130104){
  set.seed(mySeed)  
  xPop <- rgamma(3400,shape=0.25*40,scale=0.025) 
  x <- sample(xPop,n)
  y <- rgamma(length(x),shape=0.1*x*1000,scale=0.002)
  
  B <- mean(y) / mean(x)
  e <- y - B*x
  
  return(list(data = data.frame(socker=y, vikt=x, e=e), 
              xTot = round(sum(xPop))))
}

# Example: Welfare
generateWelfare <-function(mySeed = 20130206){
  set.seed(mySeed)  
  N <- 16

  x <- rgamma(n = N, shape = 970^2 / 485, scale = 485 / 970) 
  y <- rnorm(n = N, mean = 33851.18 - 5 * x, sd=50)
    
  return(list(welfare = x, income = y))
}


# Example: Forest volume
generateForest <- function(mySeed = 20130201){
  set.seed(mySeed) 
  N <- 17010
  tot_x <- 1807641
  n <- 18
  y <- rgamma(n = n, shape = 2.65, scale = 40)  
  x <- rnorm(n = length(y), mean = y, sd = 18)
  x[x < 0] <- 0
  data <- data.frame(y=y,x=x) 
  mod <- lm(y ~ x, data = data)
  data$y_hat <- predict(mod)
  data$e <- resid(mod)
  return(list(data = data, n = n, N = N, tot_x = tot_x, B = mod$coefficients))
}


# Create forestplots
credplot.gg <- function(d){
  require(ggplot2)
  require(stringr)

  # Correct data
  d$text <- as.character(d$text)
  len<-nchar(d$text)
  spaces <- str_locate_all(d$text, " ")
  for (i in seq_along(d$text)){
#    d$text[i] <- str_replace_all(d$text[i],pattern="\’", "\"")
#    d$text[i] <- str_replace_all(d$text[i],pattern="'", "\"")
    if(len[i]>40){
      split<-spaces[[i]][which.min(abs(spaces[[i]][,'start']-len[i]/2)),'start']
      d$text[i] <- str_c(str_sub(d$text[i],1,split-1),"\n",str_sub(d$text[i],split+1,len[i]),collapse="")
    }
  }
  
  # Plot
  p <- ggplot(d, aes(x=as.character(text), 
                     y=as.numeric(OR), 
                     ymin=as.numeric(ORlow), 
                     ymax=as.numeric(ORhigh)))+
    geom_pointrange()+
    geom_point(aes(size=log(as.numeric(sampleSize)), shape="4"), fill="white") +
    scale_size_continuous(limits=log(c(1000,100000))) + 
    scale_y_log10(breaks=c(0.5,1,1.5,2:5)) +
    coord_flip() + 
    scale_shape_manual(values=c(22,21)) +
    scale_linetype_manual(values=c(1,2)) +
    geom_hline(yintercept=1, linetype="dashed")+ 
    ggtitle(d$area[1]) + 
    ylab('Odds ratio (log scale)') + 
    xlab('') +
    theme(legend.position="none")#, plot.title = element_text(lineheight=.8, face="bold"))
  
  return(p)
}
