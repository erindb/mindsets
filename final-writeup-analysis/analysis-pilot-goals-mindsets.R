library(plyr)
library(ggplot2)
other = read.table("pilot-goals-other.results", header=T, sep=",", quote="")
self = read.table("pilot-goals-self.results", header=T, sep=",", quote="")
self$subject = as.character(as.numeric(as.character(self$subject)) + 59)
r = rbind(other,self)
print(length(unique(r$subject)))
r = r[r$can_describe_fixed == "no",]
good.subjects = unique(as.character(r$subject)[sapply(as.character(r$subject), function(subj) {
  r$response[r$subject==subj & r$version=="test_bad"] <= 0.1
})])
r = r[r$subject %in% good.subjects,]
r = r[!is.na(r$response),]
print(length(unique(r$subject)))

med.split = median(r$dweck_sum_score)
r$fixed = r$dweck_sum_score > med.split
r$mindset = r$fixed
r$mindset[r$fixed] = "fixed"
r$mindset[!r$fixed] = "growth"

mindset_colors = sapply(seq(0,1.02,by=0.03), function(x) {x > med.split})

ggplot(r, aes(x=dweck_sum_score)) + 
  geom_histogram(aes(y=..density.., fill=factor(mindset)),      # Histogram with density instead of count on y-axis
                 binwidth=0.03,
                 #colour=mindset_colors
                 #colour="black",
                 #colour="black"
                 ) +
  geom_density(alpha=.2, #fill="#FF6666"
               fill="#080808") +
  theme_bw(24)
# 
# mean.goals = aggregate(response~version+mindset, data=r[r$trial_type == "g",], FUN=mean)
# upper.goals = aggregate(response~version+mindset, data=r[r$trial_type == "g",], FUN=upper.conf)
# lower.goals = aggregate(response~version+mindset, data=r[r$trial_type == "g",], FUN=lower.conf)
# 
# #1000x600
# dodge <- position_dodge(width=0.9)
# ggplot(mean.goals, aes(x=version, y=response, fill=mindset, group=mindset)) +
#   geom_bar(binwidth=.1,position=dodge, stat="identity") +
#   theme_bw(24) +
#   #scale_colour_brewer(palette="Pastel2") +
#   ggtitle("Pilot Goals (self) - Raw Data") +
#   geom_errorbar(aes(ymax = upper.goals$response, ymin=lower.goals$response),
#                 position=dodge, binwidth=.1, width=0.25)  #+
# #   scale_fill_discrete(name="mindset",
# #                       breaks=c(F, T),
# #                       labels=c("growth", "fixed"))
# 
# # fit = lm(response ~ goal_variable * goal_impress * dweck_sum_score, data=r)
# # print(anova(fit))
# 
# 
# # #1000x600
# 
# # 
# # # fit = lm(normed_resp ~ goal_variable * goal_impress * dweck_sum_score, data=r2)
# # # print(anova(fit))
# 
# r2 = ddply(r[r$trial_type == "g",], .(subject), transform, normed_resp = response/sum(response))
# 
# mean.goals2 = aggregate(normed_resp~version+mindset, data=r2[r2$trial_type == "g",], FUN=mean)
# upper.goals2 = aggregate(normed_resp~version+mindset, data=r2[r2$trial_type == "g",], FUN=upper.conf)
# lower.goals2 = aggregate(normed_resp~version+mindset, data=r2[r2$trial_type == "g",], FUN=lower.conf)
# 
# dodge <- position_dodge(width=0.9)
# ggplot(mean.goals2, aes(x=version, y=normed_resp, fill=mindset, group=mindset)) +
#   geom_bar(binwidth=.1,position=dodge, stat="identity") +
#   theme_bw(24) +
#   ggtitle("Pilot Goals (self) - Normalized Data") +
#   #scale_colour_brewer(palette="Pastel2") +
#   geom_errorbar(aes(ymax = upper.goals2$normed_resp, ymin=lower.goals2$normed_resp),
#                 position=dodge, binwidth=.1, width=0.25)  #+
# #   scale_fill_discrete(name="mindset",
# #                       breaks=c(F, T),
# #                       labels=c("growth", "fixed"))