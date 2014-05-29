# read file
t <- read.csv("theories71.csv")

# factors and labels
t$n.effort <- ifelse(t$effort=="low", 0,
                     ifelse(t$effort=="medium", 0.5, 1))
t$n.ability <- ifelse(t$ability=="low", 0.5, 1)
t$n.difficulty <- ifelse(t$difficulty=="easy", 0.5, 2)

t$effort <- factor(t$effort, levels=c("low", "medium", "high"),
                             labels=c("Low effort", "Medium effort", "High effort"))
t$ability <- factor(t$ability, levels=c("low", "high"),
                              labels=c("Low ability", "High ability"))
t$difficulty <- factor(t$difficulty, levels=c("easy", "difficult"),
                       labels=c("Easy", "Difficult"))
# filter
t <- subset(t, heardOf=="no")
#t <- subset(t, sanity1 > sanity0)
threshold <- 0.1
t <- subset(t, abs(sanity1 - 1) <= threshold & abs(sanity0 - 0) <= threshold)
# number of people left after filtering
length(unique(t$workerID))

# mindset score
t$entityScore <- t$entity1 + t$entity2 + (7 - t$increm1) + (7 - t$increm2)
# mindset histogram
ggplot(t, aes(x=entityScore)) + 
  geom_histogram(aes(y=..density..),      # Histogram with density instead of count on y-axis
                 binwidth=1,
                 colour="black", fill="white") +
  geom_density(alpha=.2, fill="#FF6666") +
  theme_bw()

# group people into growth and fixed
median <- median(t$entityScore)
t$mindset <- ifelse(t$entityScore > median, "fixed", "growth")
t$mindset <- factor(t$mindset)


# group people into quartiles
# quart <- quantile(t$entityScore)
# t$mindset <- ifelse(t$entityScore > 
#                        quart[4], "Very fixed",
#                      ifelse(t$entityScore > quart[3], "Kind of fixed",
#                             ifelse(t$entityScore > quart[2], "Kind of growth", "Very growth")))

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
  geom_smooth(method=lm) +
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

# plot theory of improvement by individual subjects and continuous entity score
improvement.all <- subset(t, theoryType=="improvement")
ggplot(improvement.all, aes(x=entityScore, y=response, color=effort)) +
  geom_point() +
  geom_smooth(method=lm) +
  facet_grid(difficulty ~ ability) +
  theme_bw() +
  xlab("Fixedness") +
  ylab("Improvement")

#
ggplot(performance,
       aes(x=effort, y=response, color=mindset)) +
  geom_errorbar(aes(ymin=response-ci, ymax=response+ci), width=0.2, color="grey") +
  geom_point(size=3) +
  facet_grid(difficulty ~ ability) +
  theme_bw() +
  xlab("") +
  ylab("Performance")
  

summary(lm(data=performance.all, response ~ mindset))
summary(lm(data=improvement.all, response ~ mindset))
summary(lm(data=improvement.all, response ~ entityScore))

#################################
# Performance regression for fixed vs growth
#################################
performance.justMindset <- summarySE(performance.all, measurevar="response",
                                     groupvars=c("mindset"))
ggplot(performance.justMindset, aes(x=mindset, y=response, fill=mindset)) +
  geom_bar(stat="identity", color="black") +
  geom_errorbar(aes(ymin=response-ci, ymax=response+ci), width=0.2) +
  theme_bw() +
  ylab("Performance") +
  xlab("Mindset")

performance.all.fixed <- subset(performance.all, mindset=="fixed")
performance.all.growth <- subset(performance.all, mindset=="growth")

summary(lm(data=performance.all, response ~ ability * difficulty * effort * mindset))
summary(lm(data=performance.all.growth, response ~ ability + difficulty + effort))

#################################
# Improvement regression for fixed vs growth
#################################
improvement.justMindset <- summarySE(improvement.all, measurevar="response",
                                     groupvars=c("mindset"))
ggplot(improvement.justMindset, aes(x=mindset, y=response, fill=mindset)) +
    geom_bar(stat="identity", color="black") +
    geom_errorbar(aes(ymin=response-ci, ymax=response+ci), width=0.2) +
    theme_bw() +
    ylab("Improvement") +
    xlab("Mindset")

improvement.all.fixed <- subset(improvement.all, mindset=="fixed")
improvement.all.growth <- subset(improvement.all, mindset=="growth")

summary(lm(data=improvement.all.fixed, response ~ ability + difficulty + effort))
summary(lm(data=improvement.all.growth, response ~ ability + difficulty + effort))


anova(lm(data=improvement.all, response ~ n.ability * n.difficulty * n.effort * entityScore))
