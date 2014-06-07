library(plyr)
library(bear)
library(ggplot2)
r = read.table("pilot-theories.results", header=T, sep=",", quote="")
r$subject = r$workerID
print(length(unique(r$subject)))
r = r[r$heardOf == "no",]
print(length(unique(r$subject)))
good.subjects = unique(as.character(r$subject)[sapply(as.character(r$subject), function(subj) {
  r$sanity0[r$subject==subj][1] <= 0.1 & r$sanity1[r$subject==subj][1] >= 0.9
})])
r = r[r$subject %in% good.subjects,]
r = r[!is.na(r$response),]
print(length(unique(r$subject)))

r$dweck_sum_score = r$entity1 + r$entity2 + (7 - r$increm1) + (7 - r$increm2)
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

t = r

#factors and labels
t$effort <- factor(t$effort, levels=c("low", "medium", "high"),
                             labels=c("Low effort", "Medium effort", "High effort"))
t$ability <- factor(t$ability, levels=c("low", "high"),
                              labels=c("Low ability", "High ability"))
t$difficulty <- factor(t$difficulty, levels=c("easy", "difficult"),
                       labels=c("Easy", "Difficult"))

#numeric effort, ability, and difficulty
t$e = t$effort
levels(t$e) = c("0", "0.5", "1")
t$e = as.numeric(as.character(t$e))
t$a = t$ability
levels(t$a) = c("0.5", "1")
t$a = as.numeric(as.character(t$a))
t$d = t$difficulty
levels(t$d) = c("0.5", "2")
t$d = as.numeric(as.character(t$d))

# # plot theory of performance
performance <- summarySE(subset(t, theoryType=="performance"), measurevar="response",
                         groupvars=c("ability", "effort", "difficulty", "mindset"))
improvement <- summarySE(subset(t, theoryType=="improvement"), measurevar="response",
                         groupvars=c("ability", "effort", "difficulty", "mindset"))
# 
# ggplot(performance, aes(x=difficulty, y=response, fill=mindset)) +
#   geom_bar(stat="identity", color="black", position=position_dodge()) +
#   geom_errorbar(aes(ymin=response-ci, ymax=response+ci), position=position_dodge(0.9), width=0.2) +
#   facet_grid(effort ~ ability) +
#   theme_bw() +
#   scale_fill_brewer(palette="Set2") +
#   xlab("") +
#   ylab("Performance")

# plot theory of performance by individual subjects and continuous entity score
performance.all <- subset(t, theoryType=="performance")
ggplot(performance.all, aes(x=entityScore, y=response, color=effort)) +
  #geom_point() +
  geom_smooth(method=lm) +
  facet_grid(difficulty ~ ability) +
  theme_bw(24) +
  xlab("Fixedness") +
  ylab("Performance") +
  ggtitle("Pilot Theories - Performance")

# plot theory of improvement by individual subjects and continuous entity score
improvement.all <- subset(t, theoryType=="improvement")
ggplot(improvement.all, aes(x=entityScore, y=response, color=effort)) +
  #geom_point() +
  geom_smooth(method=lm) +
  facet_grid(difficulty ~ ability) +
  theme_bw(24) +
  xlab("Fixedness") +
  ylab("Improvement") +
  ggtitle("Pilot Theories - Improvement")

ggplot(performance,
       aes(x=effort, y=response, color=mindset)) +
  geom_errorbar(aes(ymin=response-ci, ymax=response+ci), width=0.2, color="grey") +
  geom_point(size=3) +
  facet_grid(difficulty ~ ability) +
  theme_bw(24) +
  xlab("") +
  ylab("Performance") +
  ggtitle("Pilot Theories - Performance")

ggplot(improvement,
       aes(x=effort, y=response, color=mindset)) +
  geom_errorbar(aes(ymin=response-ci, ymax=response+ci), width=0.2, color="grey") +
  geom_point(size=3) +
  facet_grid(difficulty ~ ability) +
  theme_bw(24) +
  xlab("") +
  ylab("Improvement") +
  ggtitle("Pilot Theories - Improvement")

ggplot(t, aes(x=d, y=response, color=mindset)) +
  geom_point() +
  facet_grid(. ~ theoryType) +
  theme_bw(24) +
  stat_smooth(method="lm") +
  xlab("difficulty") +
  ylab("response") +
  ggtitle("improvement/performace as a function of difficulty")

ggplot(t, aes(x=a, y=response, color=mindset)) +
  geom_point() +
  facet_grid(. ~ theoryType) +
  theme_bw(24) +
  stat_smooth(method="lm") +
  xlab("ability") +
  ylab("response") +
  ggtitle("improvement/performace as a function of ability")


ggplot(t, aes(x=e, y=response, color=mindset)) +
  geom_point() +
  facet_grid(. ~ theoryType) +
  theme_bw(24) +
  stat_smooth(method="lm") +
  xlab("effort") +
  ylab("response") +
  ggtitle("improvement/performace as a function of effort")

performance.justMindset <- summarySE(performance.all, measurevar="response",
                                     groupvars=c("mindset"))
ggplot(performance.justMindset, aes(x=mindset, y=response, fill=mindset)) +
  geom_bar(stat="identity", color="black") +
  geom_errorbar(aes(ymin=response-ci, ymax=response+ci), width=0.2) +
  theme_bw(24) +
  ylab("Performance") +
  xlab("Mindset") +
  ggtitle("Pilot Theories - Performance (all conditions)")

improvement.justMindset <- summarySE(improvement.all, measurevar="response",
                                     groupvars=c("mindset"))
ggplot(improvement.justMindset, aes(x=mindset, y=response, fill=mindset)) +
  geom_bar(stat="identity", color="black") +
  geom_errorbar(aes(ymin=response-ci, ymax=response+ci), width=0.2) +
  theme_bw(24) +
  ylab("Improvement") +
  xlab("Mindset") +
  ggtitle("Pilot Theories - Improvement  (all conditions)")

# # endorsements = data.frame(
# #   type=c(rep("entity", length(t$entity1)),
# #          rep("incremental", length(t$increm1))),
# #   q1 = c(t$entity1, t$increm1),
# #   q2 = c(t$entity2, t$increm2)
# # )
# # ggplot(endorsements, aes(x=q1, y=q2, colour=type)) +
# #   geom_point() + stat_smooth(method="lm")  +
# #   theme_bw(24) + ggtitle("endorsements of entity and incremental questions")
# # 
# # entity.vs.increm = data.frame(
# #   question=c(rep("question 1", length(t$entity1) + length(t$increm1)),
# #          rep("question 2", length(t$entity2) + length(t$increm2))),
# #   entity = c(t$entity1, t$entity2),
# #   incremental = c(t$increm1, t$increm2)
# # )
# # ggplot(entity.vs.increm, aes(x=entity, y=incremental#, colour=question
# #                              )) +
# #   geom_point() + stat_smooth(method="lm")  +
# #   #facet_grid(. ~ question) +
# #   theme_bw(24) + ggtitle("endorsements of entity vs. incremental questions")
# # 
# # # ggplot(t, aes(x=entity1, y=entity2)) +
# # #   geom_point() +theme_bw(24) +
# # #   ggtitle("entity responses") +
# # #   stat_smooth(method="lm")
# # 
# # 