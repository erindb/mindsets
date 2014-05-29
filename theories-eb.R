split = "quartile"

## Summarizes data.
## Gives count, mean, standard deviation, standard error of the mean, and confidence interval (default 95%).
##   data: a data frame.
##   measurevar: the name of a column that contains the variable to be summariezed
##   groupvars: a vector containing names of columns that contain grouping variables
##   na.rm: a boolean that indicates whether to ignore NA's
##   conf.interval: the percent range of the confidence interval (default is 95%)
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
  require(plyr)
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                   )
                 },
                 measurevar
  )
  
  # Rename the "mean" column    
  datac <- rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval: 
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}

# read filesu
#t = read.csv("theories69.csv")
t = read.csv("theories71.csv")
#t = t[t$workerID < 31,]
#t <- read.csv("theories_results_processed.csv")

# factors and labels
t$effort <- factor(t$effort, levels=c("low", "medium", "high"),
                             labels=c("Low effort", "Medium effort", "High effort"))
t$ability <- factor(t$ability, levels=c("low", "high"),
                              labels=c("Low ability", "High ability"))
t$difficulty <- factor(t$difficulty, levels=c("easy", "difficult"),
                       labels=c("Easy", "Difficult"))

# filter
#t <- subset(t, heardOf=="no")
t <- subset(t, sanity1 > sanity0)

# mindset score
t$entityScore <- t$entity1 + t$entity2 + (7 - t$increm1) + (7 - t$increm2)

# group people into growth and fixed
med.split = median(t$entityScore)
up.quart = median(t$entityScore[t$entityScore > med.split])
low.quart = median(t$entityScore[t$entityScore < med.split])

if (split == "median") {
  t$mindset <- ifelse(t$entityScore > med.split, "fixed", "growth")
} else if (split == "quartile") {
  t$mindset <- ifelse(t$entityScore >= up.quart, "fixed", NA)
  t$mindset[t$entityScore <= low.quart] = "growth"
  t = t[!is.na(t$mindset),]
}

t$e.effort = as.character(t$effort)
t$e.effort[t$e.effort == "Low effort"] = "0"
t$e.effort[t$e.effort == "Medium effort"] = "0.5"
t$e.effort[t$e.effort == "High effort"] = "1"
t$e.effort = as.numeric(t$e.effort)

t$e.ability = as.character(t$ability)
t$e.ability[t$e.ability == "Low ability"] = "0"
t$e.ability[t$e.ability == "Medium ability"] = "0.5"
t$e.ability[t$e.ability == "High ability"] = "1"
t$e.ability = as.numeric(t$e.ability)

t$e.difficulty = as.character(t$difficulty)
t$e.difficulty[t$e.difficulty == "Easy"] = "0.5"
t$e.difficulty[t$e.difficulty == "Difficult"] = "2"
t$e.difficulty = as.numeric(t$e.difficulty)

# mindset histogram
ggplot(t, aes(x=entityScore)) + 
  geom_histogram(aes(y=..density..),      # Histogram with density instead of count on y-axis
                 binwidth=1,
                 colour="black", fill="white") +
  geom_density(alpha=.2, fill="#FF6666") +
  theme_bw()

# plot theory of performance
performance <- summarySE(subset(t, theoryType=="performance"), measurevar="response",
                         groupvars=c("ability", "effort", "difficulty", "mindset"))

ggplot(performance, aes(x=difficulty, y=response, fill=mindset)) +
  geom_bar(stat="identity", color="black", position=position_dodge()) +
  geom_errorbar(aes(ymin=response-ci, ymax=response+ci), position=position_dodge(0.9), width=0.2) +
  facet_grid(effort ~ ability) +
  theme_bw() +
  scale_fill_brewer(palette="Set2") +
  xlab("") +
  ylab("Performance")

# plot theory of performance by individual subjects and continuous entity score
performance.all <- subset(t, theoryType=="performance")
ggplot(performance.all, aes(x=entityScore, y=response, color=effort)) +
  geom_point() +
  facet_grid(difficulty ~ ability) +
  theme_bw() +
  xlab("Fixedness") +
  ylab("Performance")

# plot theory of improvement
improvement <- summarySE(subset(t, theoryType=="improvement"), measurevar="response",
                         groupvars=c("ability", "effort", "difficulty", "mindset"))

ggplot(improvement, aes(x=difficulty, y=response, fill=mindset)) +
  geom_bar(stat="identity", color="black", position=position_dodge()) +
  geom_errorbar(aes(ymin=response-ci, ymax=response+ci), position=position_dodge(0.9), width=0.2) +
  facet_grid(effort ~ ability) +
  theme_bw() +
  scale_fill_brewer(palette="Accent") +
  xlab("") +
  ylab("Improvement")

# plot theory of performance by individual subjects and continuous entity score
improvement.all <- subset(t, theoryType=="improvement")
ggplot(improvement.all, aes(x=entityScore, y=response, color=effort)) +
  geom_point() +
  facet_grid(difficulty ~ ability) +
  theme_bw() +
  xlab("Fixedness") +
  ylab("Improvement")

ggplot(t, aes(x=e.difficulty, y=response, color=mindset)) +
  geom_point() +
  facet_grid(. ~ theoryType) +
  #facet_grid(difficulty ~ ability) +
  theme_bw(24) +
  stat_smooth(method="lm") +
  xlab("difficulty") +
  ylab("response") +
  ggtitle("improvement/performace as a function of difficulty")
#ggtitle("improvement as a function of effort")

ggplot(t, aes(x=e.ability, y=response, color=mindset)) +
  geom_point() +
  facet_grid(. ~ theoryType) +
  #facet_grid(difficulty ~ ability) +
  theme_bw(24) +
  stat_smooth(method="lm") +
  xlab("ability") +
  ylab("response") +
  ggtitle("improvement/performace as a function of ability")
#ggtitle("improvement as a function of effort")

ggplot(t, aes(x=entityScore, y=response, color=effort)) +
  #geom_point() +
  facet_grid(. ~ theoryType) +
  #facet_grid(difficulty ~ ability) +
  theme_bw(24) +
  stat_smooth(method="lm") +
  xlab("Dweck score") +
  ylab("response") #+
  #ggtitle("")

ggplot(t, aes(x=e.effort, y=response, color=mindset)) +
  geom_point() +
  facet_grid(. ~ theoryType) +
  #facet_grid(difficulty ~ ability) +
  theme_bw(24) +
  stat_smooth(method="lm") +
  xlab("effort") +
  ylab("response") +
  ggtitle("improvement/performace as a function of effort")
  #ggtitle("improvement as a function of effort")
# 
# ggplot(performance.all, aes(x=e.effort, y=response, color=mindset)) +
#   geom_point() +
#   #facet_grid(difficulty ~ ability) +
#   theme_bw(24) +
#   stat_smooth(method="lm") +
#   xlab("effort") +
#   ylab("performance") +
#   ggtitle("performance as a function of effort")

improvement.fixed = improvement.all[improvement.all$mindset == "fixed",]
improvement.growth = improvement.all[improvement.all$mindset == "growth",]
f.fixed = lm(response~e.effort*e.difficulty, data=improvement.fixed)
#print(anova(f.fixed))
f.growth = lm(response~e.effort*e.difficulty, data=improvement.growth)
#print(anova(f.growth))
# print(f.fixed)
# print(f.growth)

resample.lm = function(df) {
  rows = sample(1:nrow(df), nrow(df), replace=T)
  new.df = df[rows,]
  return(lm(response~e.effort*e.difficulty, data=new.df)$coefficients)
}

lm.conf = function(df) {
  resampled.lm = replicate(100, resample.lm(df))
  intercepts = quantile(resampled.lm["(Intercept)",], c(0.025, 0.975))
  effort = quantile(resampled.lm["e.effort",], c(0.025, 0.975))
  difficulty = quantile(resampled.lm["e.difficulty",], c(0.025, 0.975))
  interaction = quantile(resampled.lm["e.effort:e.difficulty",], c(0.025, 0.975))
  return(rbind(intercepts, effort, difficulty, interaction))
}
g.conf = lm.conf(improvement.growth)
f.conf = lm.conf(improvement.fixed)
plot(x=c(1,2,3,4,1,2,3,4), y=c(g.conf), col="blue", pch=19, ylim=c(-0.3,0.5))
par(new=T)
plot(x=c(1,2,3,4,1,2,3,4), y=c(f.conf), col="red", pch=19, ylim=c(-0.3,0.5))

f.impr = lm(response~e.effort*e.difficulty*e.ability*entityScore, data=improvement.all)
f.perf = lm(response~e.effort*e.difficulty*e.ability*entityScore, data=performance.all)
print(anova(f.impr))
print(anova(f.perf))