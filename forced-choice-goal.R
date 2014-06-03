library("ggplot2")
r = read.table("goals-goals-take2.results", header=T, sep=",", quote="")
r = r[r$dependent_measure == "forced-choice" & r$trial_type == "g" & r$heard_of == "no",]
r = r[r$goal1 != "test_bad" & r$goal2 != "test_bad" & r$goal3 != "test_bad",]
r = r[,c("goal_wording", "prompt_wording", "goal1", "goal2", "goal3", "subject", "dweck_sum_score")]
#r = r[r$goal_wording == "original" & r$prompt_wording == "original",]
r = r[r$goal_wording == "original" & r$prompt_wording == "training",]
print(length(unique(r$subject)))

med.split = median(r$dweck_sum_score)
r$fixed = r$dweck_sum_score > med.split
up.quart = median(r$dweck_sum_score[r$dweck_sum_score > med.split])
low.quart = median(r$dweck_sum_score[r$dweck_sum_score < med.split])
#r = r[r$dweck_sum_score < low.quart | r$dweck_sum_score > up.quart,]
r$mindset = r$fixed
r$mindset[r$fixed] = "fixed"
r$mindset[!r$fixed] = "growth"

ggplot(r, aes(x=mindset, fill=mindset)) +
  geom_bar(position=dodge) +
  facet_grid(. ~ goal1) +
  theme_bw(24) +
  ggtitle("first choice goal")
ggplot(r, aes(x=mindset, fill=mindset)) +
  geom_bar(position=dodge) +
  theme_bw(24) +
  facet_grid(. ~ goal2) +
  ggtitle("second choice goal")

# print(length(unique(r$subject)))
# ggplot(r, aes(x=goal1, fill=fixed, group=fixed)) +
#   geom_bar(binwidth=.1,position=dodge) +
#   theme_bw(24) +
#   #scale_colour_brewer(palette="Pastel2") +
# #   geom_errorbar(aes(ymax = upper.goals$response, ymin=lower.goals$response),
# #                 position=dodge, binwidth=.1, width=0.25)  

# fit = lm(response ~ goal_variable * goal_impress * dweck_sum_score, data=r)
# print(anova(fit))