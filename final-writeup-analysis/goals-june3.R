library(plyr)
library(ggplot2)

condition = "training"

conf <- function(v) {
  v <- v[is.na(v) == F]
  nsubj=length(v)
  sample.means <- replicate(100, mean(sample(v, nsubj, replace=TRUE)))
  return(quantile(sample.means, c(0.025, 0.975)))
}
lower.conf <- function(v) {
  conf(v)[["2.5%"]]
}
upper.conf <- function(v) {
  conf(v)[["97.5%"]]
}

r = read.table("goals-june3.results", header=T, sep=",", quote="")

if (condition == "training") {
  label = "training"
  r = r[r$goal_wording == "original" & r$prompt_wording == "training" & r$dependent_measure == "original",]
} else if (condition == "achieve") {
  label = "probability of success"
  r = r[r$goal_wording == "achieve" & r$prompt_wording == "orignal" & r$dependent_measure == "original",]
}

print(length(unique(r$subject)))

r = r[r$response < 0.1 | r$version != "test_bad",]
r = r[r$can_describe_fixed == "no",]
r = r[!is.na(r$response),]

print(length(unique(r$subject)))

med.split = median(r$dweck_sum_score)
r$fixed = r$dweck_sum_score > med.split
r$mindset = r$fixed
r$mindset[r$fixed] = "fixed"
r$mindset[!r$fixed] = "growth"
r$mindset <- factor(r$mindset)
r$entityScore = r$dweck_sum_score

ggplot(r, aes(x=dweck_sum_score)) + 
  geom_histogram(aes(y=..density.., fill=factor(mindset)),      # Histogram with density instead of count on y-axis
                 binwidth=1, colour="black") +
  geom_density(alpha=.2, fill="#080808") +
  theme_bw(24)

mean.goals = aggregate(response~version+mindset, data=r[r$trial_type == "g",], FUN=mean)
upper.goals = aggregate(response~version+mindset, data=r[r$trial_type == "g",], FUN=upper.conf)
lower.goals = aggregate(response~version+mindset, data=r[r$trial_type == "g",], FUN=lower.conf)

dodge <- position_dodge(width=0.9)
ggplot(mean.goals, aes(x=version, y=response, fill=mindset, group=mindset)) +
  geom_bar(binwidth=.1,position=dodge, stat="identity") +
  theme_bw(24) +
  ggtitle(paste(label, " (unnormalized)")) +
  geom_errorbar(aes(ymax = upper.goals$response, ymin=lower.goals$response),
                position=dodge, binwidth=.1, width=0.25)
# 
# fit = lm(response ~ goal_variable * goal_impress * dweck_sum_score, data=r)
# print(anova(fit))
# 
r2 = ddply(r, .(subject), transform, normed_resp = response/sum(response))

mean.goals2 = aggregate(normed_resp~version+mindset, data=r2[r2$trial_type == "g",], FUN=mean)
upper.goals2 = aggregate(normed_resp~version+mindset, data=r2[r2$trial_type == "g",], FUN=upper.conf)
lower.goals2 = aggregate(normed_resp~version+mindset, data=r2[r2$trial_type == "g",], FUN=lower.conf)

dodge <- position_dodge(width=0.9)
ggplot(mean.goals2, aes(x=version, y=normed_resp, fill=mindset, group=mindset)) +
  geom_bar(binwidth=.1,position=dodge, stat="identity") +
  theme_bw(24) +
  ggtitle(paste(label, "(normalized)")) +
  geom_errorbar(aes(ymax = upper.goals2$normed_resp, ymin=lower.goals2$normed_resp),
                position=dodge, binwidth=.1, width=0.25)
# 
# fit = lm(normed_resp ~ goal_variable * goal_impress * dweck_sum_score, data=r2)
# print(anova(fit))