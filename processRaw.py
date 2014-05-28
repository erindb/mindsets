import sys, re, string

f = open(sys.argv[1], "r")

print "d1,d2,d3,d4,theoryType,ability,effort,difficulty,response,practice0,practice6,practice10,sanity0,sanity1,workerID,gender,heardOf"

fields = ["WorkerId", "Gender", "HeardOf"]
indices = []
firstline = 0
for l in f:
    l = l.strip()
    #l = l.replace('""', "")
    toks = l.split("\t")
    if firstline == 0:
        firstline = 1
        for t in toks:
            if t in fields:
                indices.append(toks.index(t))            
    else:
        subjectInfo = []
        for t in toks:
            if toks.index(t) in indices:
                subjectInfo.append(t.replace('"', ""))
            if toks.index(t) == 9:
                t = t.replace('"', "")
                t = t.replace('[{', "").replace(']}', "")
                trials = t.split("},{")
                practice = dict()
                sanity = dict()
                theories = []
                dweck = []
                for trial in trials:
                    trialType = trial.split(",")[0].split(":")[1]
                    if trialType == "slider_practice":
                        numBlue = int(trial.split(",")[1].split(":")[1])
                        response = float(trial.split(",")[2].split(":")[1])
                        practice[numBlue] = response
                    elif trialType == "sanity":
                        correct = float(trial.split(",")[1].split(":")[1])
                        response = float(trial.split(",")[2].split(":")[1])
                        sanity[correct] = response
                        #print sanity
                    elif trialType == "performance" or trialType == "improvement":
                        ability = trial.split(",")[1].split(":")[1]
                        effort = trial.split(",")[2].split(":")[1]
                        difficulty = trial.split(",")[3].split(":")[1]
                        response = trial.split(",")[4].split(":")[1]
                        theories.append([trialType, ability, effort, difficulty, response])
                        #print performance
                    elif trialType == "dweck":
                        #dweck.append(trial)
                        orders = trial.split("[")[1].split("]")[0].split(",")
                        scores = trial.replace("}", "").split("]")[1].split(",")[1:]
                        scoresOrdered = []
                        for qNum in range(0, 4):
                            qIndex = orders.index(str(qNum))
                            scoresOrdered.append(scores[qIndex])
                        #print orders
                        #print scores
                        #print scoresOrdered
                        #dweck.append(trial)
                        #dweck.append(parts)
                        for score in scoresOrdered:
                            dweck.append(score.split(":")[1])
                practiceResponses = []
                sanityResponses = []
                for key in sorted(practice):
                    practiceResponses.append(str(practice[key]))
                for key in sorted(sanity):
                    sanityResponses.append(str(sanity[key]))
        #print subjectInfo
        for theory in theories:
            print ",".join(dweck) + "," + ",".join(theory) + "," + ",".join(practiceResponses) + "," + ",".join(sanityResponses) + "," + ",".join(subjectInfo) 
                
