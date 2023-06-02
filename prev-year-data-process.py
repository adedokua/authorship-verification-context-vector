import json
import io
def createDataset():
    with open('pan/pan-demo-smalll.jsonl', 'r') as json_file:
        with open('pan/pan-demo-small-truth.jsonl', 'r') as truth_file:
            truth_list = list(truth_file)
            with open("truthvalues.txt", "a") as cases:
                json_list = list(json_file) 
                i=0
                pair_num = 0
                for entry in json_list:
                    #something like {"fandom":"harrypotter, "pair": ["I love coding.", "Coding is fun!"]}

                    js = entry
                    #parse as JSON
                    result = json.loads(js)
                    #textPair is assigned the value of result['pair'], which is ["I love coding.", "Coding is fun!"]
                    textPair = result['pair']
                    #first file
                    with io.open("data/" + str(i) + ".txt", 'w', encoding='utf-8') as f1:
                        f1.write(textPair[0])
                        f1.close()
                    i += 1
                    #second file
                    with io.open("data/" + str(i) + ".txt", 'w',encoding='utf-8') as f2:
                        f2.write(textPair[1])
                        f2.close()
                    i += 1
                    truthjs = truth_list[pair_num]
                    pair_num+=1
                    tresult = json.loads(truthjs)
                    ans = 0
                    if (tresult['same'] == True):
                        ans = 1
                    cases.write(str(i-2) + ".txt " + str(i-1) + ".txt " + str(ans) + "\n")
    cases.close()
createDataset()
