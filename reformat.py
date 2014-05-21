import re
import json
import sys

goal_variable = {
	"test_bad": "test",
	"test_now": "test",
	"test_future": "test",
	"show_effort": "effort",
	"show_ability": "ability",
	"improve": "improve",
	"ability": "ability"
}
goal_timeline = {
	"test_bad": "NA",
	"test_now": "now",
	"test_future": "future",
	"show_effort": "NA",
	"show_ability": "NA",
	"improve": "NA",
	"ability": "NA"
}
goal_impress = {
	"test_bad": "for_me",
	"test_now": "for_me",
	"test_future": "for_me",
	"show_effort": "show",
	"show_ability": "show",
	"improve": "for_me",
	"ability": "for_me"
}

def short_dweck(dq):
	dqs = {
		"You can learn new things, but you can't really change your basic intelligence":"can_learn",
		"You have a certain amount of intelligence, and you really can't do much to change it":"certain_amount",
		"Your intelligence is something about you that you can't change very much":"cannot_change",
	}
	return dqs[dq]

#GOALS: test_bad, test_now, test_future, show_effort, show_ability, improve, ability
def short_goals(g):
	gs = {
		"doing badly on his tests":"test_bad",
		"doing well on future tests":"test_future",
		"doing well on this test":"test_now",
		"showing his teacher that he tries at math":"show_effort",
		"showing his teacher that he has high math ability":"show_ability",
		"improving at math":"improve",
		"being good at math":"ability"
	}
	return gs[g]

workers = {}
def symb(workerid):
	if workerid in workers:
		return workers[workerid]
	else:
		id_number = str(len(workers))
		workers[workerid] = id_number
		return id_number

def cutquotes(x, i):
	return x[i:-i]
def cutone(x):
	return cutquotes(x, 1)

data_from_subjects = []

f = open(sys.argv[1])

header = []
line_num = 0;
for line in f:
	elems = line[:-1].split("\t")
	if line_num == 0:
		header =  map(cutone, elems)
	else:
		subject_data = {}
		subj_dweck_targets = []
		subj_goals_targets = []
		subj_dweck_responses = []
		subj_goals_responses = []
		for i in range(len(elems)):
			elem = cutone(elems[i])
			label = header[i]
			if label == "workerid":
				subject_data["subject"] = symb(elem)
			if label == "Answer.randomization":
				elem = re.sub("\"\"", "\"", elem)
				elem = json.loads(elem)
				raw_dweck_questions = elem["dweck_questions"]
				subj_dweck_targets = map(short_dweck, raw_dweck_questions)
				raw_goals_questions = elem["goals"]
				subj_goals_targets = map(short_goals, raw_goals_questions)
			if label == "Answer.responses":
				elem = re.sub("\"\"", "\"", elem)
				elem = json.loads(elem)
				subj_goals_responses.append(elem["response0"])
				subj_goals_responses.append(elem["response1"])
				subj_goals_responses.append(elem["response2"])
				subj_goals_responses.append(elem["response3"])
				subj_goals_responses.append(elem["response4"])
				subj_goals_responses.append(elem["response5"])
				subj_goals_responses.append(elem["response6"])
				subj_dweck_responses.append(elem["response7"])
				subj_dweck_responses.append(elem["response8"])
				subj_dweck_responses.append(elem["response9"])
			if label == "Answer.what_about":
				subject_data["what_about"] = cutquotes(elem, 2)
			if label == "Answer.comments":
				elem = re.sub("\.", "", elem)
				elem = re.sub(",", "", elem)
				elem = re.sub("'", "", elem)
				subject_data["comments"] = cutquotes(elem, 2)
			if label == "Answer.gender":
				subject_data["gender"] = cutquotes(elem, 2)
			if label == "Answer.heard_of":
				subject_data["heard_of"] = cutquotes(elem, 2)
			if label == "Answer.hear_more":
				subject_data["hear_more"] = cutquotes(elem, 2)
			if label == "Answer.what_is_fixed":
				subject_data["what_is_fixed"] = cutquotes(elem, 2)
			if label == "Answer.duration":
				subject_data["duration"] = elem
		#subject_data[""]
		subject_data["trial_type"] = [
			"g", "g", "g",
			"g", "g", "g",
			"g",
			"d", "d", "d"
		]
		subj_goals_sum = sum(subj_goals_responses)
		subj_goals_responses = [float(x)/subj_goals_sum for x in subj_goals_responses]
		subject_data["version"] = []
		subject_data["goal_variable"] = []
		subject_data["goal_timeline"] = []
		subject_data["goal_impress"] = []
		subject_data["response"] = []
		subject_data["dweck_sum_score"] = str(sum(subj_dweck_responses))
		for i in range(len(subj_goals_targets)):
			target = subj_goals_targets[i]
			response = str(subj_goals_responses[i])
			subject_data["response"].append(response)
			subject_data["version"].append(target)
			subject_data["goal_variable"].append(goal_variable[target])
			subject_data["goal_timeline"].append(goal_timeline[target])
			subject_data["goal_impress"].append(goal_impress[target])
		for i in range(len(subj_dweck_targets)):
			target = subj_dweck_targets[i]
			response = str(subj_dweck_responses[i])
			subject_data["response"].append(response)
			subject_data["version"].append(target)
			subject_data["goal_variable"].append("NA")
			subject_data["goal_timeline"].append("NA")
			subject_data["goal_impress"].append("NA")
		data_from_subjects.append(subject_data)
	line_num += 1

f.close()

between_subj_labels = [
	"subject", "what_about", "comments", "gender", "heard_of",
	"hear_more", "what_is_fixed", "duration", "dweck_sum_score"
]
within_subj_labels = [
	"trial_type", #dweck or goal
	"version", #DWECK: certain_amount, can_learn, cannot_change 
			   #GOALS: test_bad, test_now, test_future, show_effort, show_ability, improve, ability
	"goal_variable", #NA, test, ability, effort, improve
	"goal_timeline", #NA, now, future
	"goal_impress", #NA, show, for_me
	"response"
]
w = open(sys.argv[1][6:], "w")
lines_to_save = [",".join(between_subj_labels + within_subj_labels)]
for i in range(len(data_from_subjects)):
	subj_data = data_from_subjects[i]
	subj_line_elements = []
	for j in range(len(between_subj_labels)):
		label = between_subj_labels[j]
		subj_line_elements.append(subj_data[label])
	for j in range(len(subj_data["version"])):
		line_elements = [x for x in subj_line_elements]
		for k in range(len(within_subj_labels)):
			label = within_subj_labels[k]
			line_elements.append(subj_data[label][j])
		lines_to_save.append(",".join(line_elements))
w.write("\n".join(lines_to_save))
w.close()