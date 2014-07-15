rm(list=ls())

library(ggplot2)

r = read.table("goals-other-60Ss.results", header=T, sep="\t")

# sort
r.sorted <- r[with(r, order(subject, trial_type, -response)), ]
r.sorted$rank <- c(-1, -1, -1, 1, 2, 3, 4, 5, 6, 7)
r.sorted.top <- subset(r.sorted, rank==6)

# Histogram with density instead of count on y-axis
ggplot(r, aes(x=dweck_sum_score)) + 
  geom_histogram(aes(y=..density..),      # Histogram with density instead of count on y-axis
                 binwidth=0.5,
                 colour="black", fill="white") +
  geom_density(alpha=.2, fill="#FF6666") +
  theme_bw()


# find median dweck score
med <- median(r.sorted.top$dweck_sum_score)
r.sorted.top$mindset <- ifelse(r.sorted.top$dweck_sum_score > med, "fixed", "growth")
# find quartiles for dweck score
quant <- quantile(r.sorted.top$dweck_sum_score)
r.sorted.top$mindsetquart <- ifelse(r.sorted.top$dweck_sum_score < quant[2], 1, 
                               ifelse(r.sorted.top$dweck_sum_score < quant[3], 2,
                                      ifelse(r.sorted.top$dweck_sum_score < quant[4], 3, 4)))

ggplot(r.sorted.top, aes(x=version)) +
  geom_bar(aes(y = (..count..))) +
  theme_bw() +
  facet_wrap(~mindset, ncol=2)

r$mindset <- ifelse(r$dweck_sum_score > med, "fixed", "growth")

r.goals <- subset(r, trial_type=="g")
ggplot(r.goals, aes(x=dweck_sum_score, y=response, color=mindset)) +
  geom_point() +
  facet_wrap(~version, ncol=3) +
  theme_bw()

r.dweck <- subset(r, trial_type=="d")
ggplot(r.dweck, aes(x=dweck_sum_score, y=response, color=mindset)) +
  geom_point() +
  facet_wrap(~version, ncol=3) +
  theme_bw()
