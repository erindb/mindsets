# read file
t <- read.csv("theories_results_processed.csv")

# factors and labels
t$effort <- factor(t$effort, levels=c("low", "medium", "high"),
                             labels=c("Low effort", "Medium effort", "High effort"))
t$ability <- factor(t$ability, levels=c("low", "high"),
                              labels=c("Low ability", "High ability"))
t$difficulty <- factor(t$difficulty, levels=c("easy", "difficult"),
                       labels=c("Easy", "Difficult"))

# filter
t <- subset(t, heardOf=="no")
t <- subset(t, sanity1 > sanity0)

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

