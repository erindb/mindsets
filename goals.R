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
r = read.table("goals-5-21.results", header=T, sep=",")
print(length(r))
r = r[r$response < 0.2 | r$version != "test_bad",]
print(length(r))


med.split = median(r$dweck_sum_score)
r$fixed = r$dweck_sum_score > med.split
up.quart = median(r$dweck_sum_score[r$dweck_sum_score > med.split])
low.quart = median(r$dweck_sum_score[r$dweck_sum_score < med.split])
r = r[r$dweck_sum_score < low.quart | r$dweck_sum_score > up.quart,]

ggplot(r, aes(x=dweck_sum_score)) +
  geom_histogram(binwidth = 0.1)

mean.goals = aggregate(response~version+fixed, data=r[r$trial_type == "g",], FUN=mean)
upper.goals = aggregate(response~version+fixed, data=r[r$trial_type == "g",], FUN=upper.conf)
lower.goals = aggregate(response~version+fixed, data=r[r$trial_type == "g",], FUN=lower.conf)

#1000x600
dodge <- position_dodge(width=0.9)
ggplot(mean.goals, aes(x=version, y=response, fill=fixed, group=fixed)) +
  geom_bar(binwidth=.1,position=dodge, stat="identity") +
  theme_bw(24) +
  #scale_colour_brewer(palette="Pastel2") +
  geom_errorbar(aes(ymax = upper.goals$response, ymin=lower.goals$response),
                position=dodge, binwidth=.1, width=0.25)  +
  scale_fill_discrete(name="mindset",
                      breaks=c(F, T),
                      labels=c("growth", "fixed"))
