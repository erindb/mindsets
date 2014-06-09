library(plyr)

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

library(ggplot2)
r = read.table("replication-goals.results", header=T, sep=",", quote="")
#r = r[r$goal_wording == "original" & r$prompt_wording == "training" & r$dependent_measure == "original",]
#print(nrow(r))
#r = r[r$goal_wording == "original" & r$prompt_wording == "training" & r$dependent_measure == "original",]
#r = r[r$goal_wording == "achieve" & r$prompt_wording == "orignal" & r$dependent_measure == "original",]
#r = r[r$response < 0.1 | r$version != "test_bad",]
print(length(unique(r$subject)))
#r = r[r$heard_of == "no",]
r = r[r$can_describe_fixed == "no",]
# good.subjects = unique(as.character(r$subject)[sapply(as.character(r$subject), function(subj) {
#   r$response[r$subject==subj & r$version=="test_bad"] <= 0.1
# })])
good.subjects = c(2, 3, 6, 7, 10, 12, 13, 14, 15, 20, 21, 22, 23, 25, 26, 27, 28, 30, 31, 34, 35, 37, 38, 42, 45, 47, 51, 52, 53, 54, 56, 57, 58, 59, 60, 62, 63, 64, 65, 66, 70, 75, 76, 77, 78, 81, 83, 84, 85, 87, 88, 89, 91, 93, 95, 96, 98, 99, 100, 101, 102, 103, 104, 105, 107, 108, 109, 110, 111, 112, 114, 115, 116, 117, 118, 119, 120, 121, 123, 124, 126, 127, 128, 129, 130, 132, 134, 135, 136, 137, 138, 140, 142, 144, 146, 148, 149, 150, 153, 154, 156, 157, 158, 159, 160, 161, 162, 163, 164, 167, 169, 171, 175, 177, 178, 180, 181, 182, 187, 190, 191, 192, 193, 194, 197, 199)
r = r[r$subject %in% good.subjects,]
r = r[!is.na(r$response),]
print(length(unique(r$subject)))

med.split = median(r$dweck_sum_score)
r$fixed = r$dweck_sum_score > med.split
up.quart = median(r$dweck_sum_score[r$dweck_sum_score > med.split])
low.quart = median(r$dweck_sum_score[r$dweck_sum_score < med.split])
#r = r[r$dweck_sum_score < low.quart | r$dweck_sum_score > up.quart,]
print(length(unique(r$subject)))

ggplot(r, aes(x=dweck_sum_score)) +
  geom_histogram(binwidth = 0.1)

r$mindset = r$fixed
r$mindset[r$fixed] = "fixed"
r$mindset[!r$fixed] = "growth"

mean.goals = aggregate(response~version+mindset, data=r[r$trial_type == "g",], FUN=mean)
upper.goals = aggregate(response~version+mindset, data=r[r$trial_type == "g",], FUN=upper.conf)
lower.goals = aggregate(response~version+mindset, data=r[r$trial_type == "g",], FUN=lower.conf)

#1000x600
dodge <- position_dodge(width=0.9)
ggplot(mean.goals, aes(x=version, y=response, fill=mindset, group=mindset)) +
  geom_bar(binwidth=.1,position=dodge, stat="identity") +
  theme_bw(24) +
  #scale_colour_brewer(palette="Pastel2") +
  ggtitle("Replication Goals (self) - Raw Data") +
  geom_errorbar(aes(ymax = upper.goals$response, ymin=lower.goals$response),
                position=dodge, binwidth=.1, width=0.25)  #+
#   scale_fill_discrete(name="mindset",
#                       breaks=c(F, T),
#                       labels=c("growth", "fixed"))

# fit = lm(response ~ goal_variable * goal_impress * dweck_sum_score, data=r)
# print(anova(fit))


# #1000x600

# 
# # fit = lm(normed_resp ~ goal_variable * goal_impress * dweck_sum_score, data=r2)
# # print(anova(fit))

r2 = ddply(r[r$trial_type == "g",], .(subject), transform, normed_resp = response/sum(response))

mean.goals2 = aggregate(normed_resp~version+mindset, data=r2[r2$trial_type == "g",], FUN=mean)
upper.goals2 = aggregate(normed_resp~version+mindset, data=r2[r2$trial_type == "g",], FUN=upper.conf)
lower.goals2 = aggregate(normed_resp~version+mindset, data=r2[r2$trial_type == "g",], FUN=lower.conf)

dodge <- position_dodge(width=0.9)
ggplot(mean.goals2, aes(x=version, y=normed_resp, fill=mindset, group=mindset)) +
  geom_bar(binwidth=.1,position=dodge, stat="identity") +
  theme_bw(24) +
  ggtitle("Replication Goals (self) - Normalized Data") +
  #scale_colour_brewer(palette="Pastel2") +
  geom_errorbar(aes(ymax = upper.goals2$normed_resp, ymin=lower.goals2$normed_resp),
                position=dodge, binwidth=.1, width=0.25)  #+
#   scale_fill_discrete(name="mindset",
#                       breaks=c(F, T),
#                       labels=c("growth", "fixed"))