library(plyr)
library(ggplot2)

condition = "achieve"

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

r = read.table("replication-goals.results", header=T, sep=",", quote="")

if (condition == "training") {
  r = r[r$goal_wording == "original" & r$prompt_wording == "training" & r$dependent_measure == "original",]
} else if (condition == "achieve") {
  r = r[r$goal_wording == "achieve" & r$prompt_wording == "orignal" & r$dependent_measure == "original",]
}

print(length(unique(r$subject)))

r = r[r$response < 0.1 | r$version != "test_bad",]
r = r[r$can_describe_fixed == "no",]
r = r[!is.na(r$response),]

print(length(unique(r$subject)))
# print(nrow(r))
# 
# med.split = median(r$dweck_sum_score)
# r$fixed = r$dweck_sum_score > med.split
# up.quart = median(r$dweck_sum_score[r$dweck_sum_score > med.split])
# low.quart = median(r$dweck_sum_score[r$dweck_sum_score < med.split])
# #r = r[r$dweck_sum_score < low.quart | r$dweck_sum_score > up.quart,]
# 
# ggplot(r, aes(x=dweck_sum_score)) +
#   geom_histogram(binwidth = 0.1)
# 
# mean.goals = aggregate(response~version+fixed, data=r[r$trial_type == "g",], FUN=mean)
# upper.goals = aggregate(response~version+fixed, data=r[r$trial_type == "g",], FUN=upper.conf)
# lower.goals = aggregate(response~version+fixed, data=r[r$trial_type == "g",], FUN=lower.conf)
# 
# mean.goals$mindset = mean.goals$fixed
# mean.goals$mindset[mean.goals$fixed] = "fixed"
# mean.goals$mindset[!mean.goals$fixed] = "growth"
# 
# r$mindset = r$fixed
# r$mindset[r$fixed] = "fixed"
# r$mindset[!r$fixed] = "growth"
# 
# r2 = ddply(r, .(subject), transform, normed_resp = response/sum(response))
# 
# print(length(unique(r$subject)))
# 
# #1000x600
# dodge <- position_dodge(width=0.9)
# ggplot(mean.goals, aes(x=version, y=response, fill=mindset, group=mindset)) +
#   geom_bar(binwidth=.1,position=dodge, stat="identity") +
#   theme_bw(24) +
#   ggtitle("probability of success (unnormalized)") +
#   #scale_colour_brewer(palette="Pastel2") +
#   geom_errorbar(aes(ymax = upper.goals$response, ymin=lower.goals$response),
#                 position=dodge, binwidth=.1, width=0.25)  #+
# #   scale_fill_discrete(name="mindset",
# #                       breaks=c(F, T),
# #                       labels=c("growth", "fixed"))
# 
# fit = lm(response ~ goal_variable * goal_impress * dweck_sum_score, data=r)
# print(anova(fit))
# 
# mean.goals2 = aggregate(normed_resp~version+mindset, data=r2[r2$trial_type == "g",], FUN=mean)
# upper.goals2 = aggregate(normed_resp~version+mindset, data=r2[r2$trial_type == "g",], FUN=upper.conf)
# lower.goals2 = aggregate(normed_resp~version+mindset, data=r2[r2$trial_type == "g",], FUN=lower.conf)
# 
# #1000x600
# dodge <- position_dodge(width=0.9)
# ggplot(mean.goals2, aes(x=version, y=normed_resp, fill=mindset, group=mindset)) +
#   geom_bar(binwidth=.1,position=dodge, stat="identity") +
#   theme_bw(24) +
#   #scale_colour_brewer(palette="Pastel2") +
#   ggtitle("training goals") +
#   geom_errorbar(aes(ymax = upper.goals2$normed_resp, ymin=lower.goals2$normed_resp),
#                 position=dodge, binwidth=.1, width=0.25)  #+
# #   scale_fill_discrete(name="mindset",
# #                       breaks=c(F, T),
# #                       labels=c("growth", "fixed"))
# 
# fit = lm(normed_resp ~ goal_variable * goal_impress * dweck_sum_score, data=r2)
# print(anova(fit))