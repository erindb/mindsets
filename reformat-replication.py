import re
import json
import sys

def classify_dweck(sentence):
	if sentence == "You can always substantially change how intelligent you are":
		return "increm1"
	elif sentence == "No matter who you are you can significantly change your intelligence level":
		return "increm2"
	elif sentence == "You have a certain amount of intelligence and you cant really do much to change it":
		return "entity1"
	elif sentence == "You can learn new things but you cant really change your basic intelligence":
		return "entity2"
	else:
		print "errrrrror 9"

goal_variable = {
	"test_bad": "test",
	"test_now": "test",
	"test_future": "test",
	"show_effort": "effort",
	"show_ability": "ability",
	"improve": "improve",
	"ability": "ability",
	"NA":"NA"
}
goal_timeline = {
	"test_bad": "NA",
	"test_now": "now",
	"test_future": "future",
	"show_effort": "NA",
	"show_ability": "NA",
	"improve": "NA",
	"ability": "NA",
	"NA":"NA"
}
goal_impress = {
	"test_bad": "for_me",
	"test_now": "for_me",
	"test_future": "for_me",
	"show_effort": "show",
	"show_ability": "show",
	"improve": "for_me",
	"ability": "for_me",
	"NA":"NA"
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
		"doing badly on this test":"test_bad",
		"doing well on future tests":"test_future",
		"doing well on this test":"test_now",
		"showing your teacher that you try at math":"show_effort",
		"showing your teacher that you have high math ability":"show_ability",
		"improving at math":"improve",
		"being good at math":"ability",
		"NA":"NA",
		"doing well on the upcoming test":"test_now",
		"doing badly on the upcoming test":"test_bad"
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
		theoryType = []
		difficulty = []
		ability = []
		effort = []
		theory_response = []
		for i in range(len(elems)):
			elem = cutone(elems[i])
			label = header[i]
			if label == "workerid":
				subject_data["subject"] = symb(elem)
				subject_data["workerID"] = symb(elem)
			if label == "gender":
				subject_data["gender"] = symb(elem)
			elif label == "Answer.randomization":
				elem = re.sub("\"\"", "\"", elem)
				elem = json.loads(elem)
				block_order = elem["block_order"]
				subject_data["performance_first"] = str(block_order.index("performance") < block_order.index("goals"))
				subject_data["improvement_first"] = str(block_order.index("improvement") < block_order.index("goals"))
				#conditions = elem["goal_conditions"]
				#subject_data["prompt_wording"] = conditions["prompt_wording"]
				#subject_data["goal_wording"] = conditions["goal_wording"]
				#subject_data["dependent_measure"] = conditions["dependent_measure"]
				#performance_first = block_order.index("performance") > block_order.index("goals")
				#improvment_first = block_order.index("improvement") > block_order.index("goals")
			elif label == "Answer.goals_responses":
				elem = re.sub("\"\"", "\"", elem)
				elem = json.loads(elem)
				if len(elem) == 3:
					subject_data["goal1"] = elem[0]
					subject_data["goal2"] = elem[1]
					subject_data["goal3"] = elem[2]
					subj_goals_responses.append("NA")
					subj_goals_responses.append("NA")
					subj_goals_responses.append("NA")
					subj_goals_responses.append("NA")
					subj_goals_responses.append("NA")
					subj_goals_responses.append("NA")
					subj_goals_responses.append("NA")
					subj_goals_targets.append("NA")
					subj_goals_targets.append("NA")
					subj_goals_targets.append("NA")
					subj_goals_targets.append("NA")
					subj_goals_targets.append("NA")
					subj_goals_targets.append("NA")
					subj_goals_targets.append("NA")
				else:
					#print elem
					subject_data["goal1"] = "NA"
					subject_data["goal2"] = "NA"
					subject_data["goal3"] = "NA"
					subj_goals_responses.append(elem["response0"])
					#print elem["response0"]
					subj_goals_responses.append(elem["response1"])
					subj_goals_responses.append(elem["response2"])
					subj_goals_responses.append(elem["response3"])
					subj_goals_responses.append(elem["response4"])
					subj_goals_responses.append(elem["response5"])
					subj_goals_targets.append(elem["target0"])
					subj_goals_targets.append(elem["target1"])
					subj_goals_targets.append(elem["target2"])
					subj_goals_targets.append(elem["target3"])
					subj_goals_targets.append(elem["target4"])
					subj_goals_targets.append(elem["target5"])
					if "response6" in elem.keys():
						subj_goals_responses.append(elem["response6"])
						subj_goals_targets.append(elem["target6"])
					else:
						subj_goals_responses.append("NA")
						subj_goals_targets.append("NA")
			elif label == "Answer.trials":
				elem = re.sub("\"\"", "\"", elem)
				elem = json.loads(elem)
				for trial in elem:
					if trial["type"] == "dweck":
						questions = trial["question_order"]
						order = trial["order"]
						for presentation_index in range(len(order)):
							question_index = order[int(presentation_index)]
							dweck_question = re.sub(u"\u2019|,", "", questions["question" + str(question_index)][:-1])
							subj_dweck_targets.append(dweck_question)
							subj_dweck_responses.append(trial["q" + str(presentation_index)])
					elif trial["type"] == "slider_practice":
						if trial["n_blue_dots"] == 0:
							subject_data["practice0"] = str(trial["response"])
						elif trial["n_blue_dots"] == 6:
							subject_data["practice6"] = str(trial["response"])
						elif trial["n_blue_dots"] == 10:
							subject_data["practice10"] = str(trial["response"])
						else:
							print "error 5"
					elif trial["type"] == "sanity":
						if trial["correct"] == 1:
							subject_data["sanity1"] = str(trial["response"])
						elif trial["correct"] == 0:
							subject_data["sanity0"] = str(trial["response"])
						else:
							print "error 4"
					elif trial["type"] == "performance":
						theoryType.append("performance")
						difficulty.append(trial["difficulty"])
						ability.append(trial["ability"])
						effort.append(trial["effort"])
						theory_response.append(str(trial["response"]))
					elif trial["type"] == "improvement":
						theoryType.append("improvement")
						difficulty.append(trial["difficulty"])
						ability.append(trial["ability"])
						effort.append(trial["effort"])
						theory_response.append(str(trial["response"]))
					elif trial["type"] == "blackwell":
						a=1
						#not dealing with this yet
					else:
						print "error 72134"
			elif label == "Answer.what_about":
				elem = cutquotes(elem, 2)
				new_elem = re.sub("\.", "", elem)
				new_elem = re.sub(",", "", new_elem)
				new_elem = re.sub("'", "", new_elem)
				new_elem = re.sub("\!", "", new_elem)
				new_elem = re.sub("\?", "", new_elem)
				new_elem = re.sub("\(", "", new_elem)
				new_elem = re.sub("\)", "", new_elem)
				new_elem = re.sub(u"\u2019", "", new_elem)
				subject_data["what_about"] = new_elem
				#print subject_data["what_about"]
			elif label == "Answer.comments":
				elem = cutquotes(elem, 2)
				new_elem = re.sub("\.", "", elem)
				new_elem = re.sub(",", "", new_elem)
				new_elem = re.sub("'", "", new_elem)
				new_elem = re.sub("\!", "", new_elem)
				new_elem = re.sub("\?", "", new_elem)
				new_elem = re.sub("\(", "", new_elem)
				new_elem = re.sub("\)", "", new_elem)
				new_elem = re.sub(u"\u2019", "", new_elem)
				subject_data["comments"] = new_elem
			elif label == "Answer.gender":
				subject_data["gender"] = cutquotes(elem, 2)
			elif label == "Answer.heard_of":
				subject_data["heard_of"] = cutquotes(elem, 2)
			elif label == "Answer.hear_more":
				subject_data["hear_more"] = cutquotes(elem, 2)
			elif label == "Answer.what_is_fixed":
				elem = cutquotes(elem, 2)
				new_elem = re.sub("\.", "", elem)
				new_elem = re.sub(",", "", new_elem)
				new_elem = re.sub("'", "", new_elem)
				new_elem = re.sub("\!", "", new_elem)
				new_elem = re.sub("\?", "", new_elem)
				new_elem = re.sub("\(", "", new_elem)
				new_elem = re.sub("\)", "", new_elem)
				new_elem = re.sub(u"\u2019", "", new_elem)
				subject_data["what_is_fixed"] = new_elem
				#print subject_data["what_is_fixed"]
			elif label == "Answer.duration":
				subject_data["duration"] = elem
		#subject_data[""]
		subject_data["trial_type"] = [
			"g", "g", "g",
			"g", "g", "g",
			"g",
			"d", "d", "d", "d"
		]
		#subj_goals_sum = sum(map(int, subj_goals_responses))
		#subj_goals_responses = [float(x)/subj_goals_sum for x in subj_goals_responses]
		subject_data["version"] = []
		subject_data["goal_variable"] = []
		subject_data["goal_timeline"] = []
		subject_data["goal_impress"] = []
		subject_data["response"] = []
		subject_data["theoryType"] = theoryType
		subject_data["difficulty"] = difficulty
		subject_data["ability"] = ability
		subject_data["effort"] = effort
		subject_data["theory_response"] = theory_response
		dweck_sum_score = 0
		for i in range(len(subj_dweck_responses)):
			target = classify_dweck(subj_dweck_targets[i])
			response = int(subj_dweck_responses[i])
			subject_data[target] = str(response)
			if target[:-1] == "entity":
				dweck_sum_score += response
			else:
				dweck_sum_score += (7 - response)
		subject_data["dweck_sum_score"] = str(dweck_sum_score)
		for i in range(len(subj_goals_targets)):
			target = short_goals(subj_goals_targets[i])
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
		#print subject_data["version"]
		#print subject_data["response"]
	line_num += 1
#print data_from_subjects

f.close()

# between_subj_labels = [
# 	"subject", "what_about", "comments",
# 	"gender", "heard_of",
# 	"hear_more", "what_is_fixed", "duration", "dweck_sum_score",
# 	"goal1", "goal2", "goal3", "goal_wording", "prompt_wording", "dependent_measure"
# 	#"performance_first", "improvement_first"
# ]
# within_subj_labels = [
# 	"trial_type", #dweck or goal
# 	"version", #DWECK: certain_amount, can_learn, cannot_change 
# 			   #GOALS: test_bad, test_now, test_future, show_effort, show_ability, improve, ability
# 	"goal_variable", #NA, test, ability, effort, improve
# 	"goal_timeline", #NA, now, future
# 	"goal_impress", #NA, show, for_me
# 	"response"
# ]
# #print data_from_subjects
# w = open("goals-" + sys.argv[1][6:], "w")
# lines_to_save = [",".join(between_subj_labels + within_subj_labels)]
# for i in range(len(data_from_subjects)):
# 	subj_data = data_from_subjects[i]
# 	subj_line_elements = []
# 	for j in range(len(between_subj_labels)):
# 		label = between_subj_labels[j]
# 		subj_line_elements.append(subj_data[label])
# 	for j in range(len(subj_data["version"])):
# 		line_elements = [x for x in subj_line_elements]
# 		for k in range(len(within_subj_labels)):
# 			label = within_subj_labels[k]
# 			#print subj_data
# 			line_elements.append(subj_data[label][j])
# 		lines_to_save.append(",".join(line_elements))
# w.write("\n".join(lines_to_save))
# w.close()

theories_between_subj_labels = [
	"entity1", "entity2", "increm1", "increm2",
	"practice0", "practice6", "practice10",
	"sanity0", "sanity1",
	"workerID", "gender", "heardOf", "performance_first", "improvement_first"
]
theories_within_subj_labels = [
	"theoryType",
	"ability",
	"effort",
	"difficulty",
	"response"
]
# #print data_from_subjects
w = open("theories-" + sys.argv[1][6:], "w")
lines_to_save = [",".join(theories_between_subj_labels + theories_within_subj_labels)]
for i in range(len(data_from_subjects)):
	subj_data = data_from_subjects[i]
	subj_data["heardOf"] = subj_data["heard_of"]
	subj_data["response"] = subj_data["theory_response"] ####DANGER!!!!!!!!
	subj_line_elements = []
	for j in range(len(theories_between_subj_labels)):
		label = theories_between_subj_labels[j]
		subj_line_elements.append(subj_data[label])
	for j in range(len(subj_data["theoryType"])):
		line_elements = [x for x in subj_line_elements]
		for k in range(len(theories_within_subj_labels)):
			label = theories_within_subj_labels[k]
			#print subj_data
			line_elements.append(subj_data[label][j])
		lines_to_save.append(",".join(line_elements))
w.write("\n".join(lines_to_save))
w.close()