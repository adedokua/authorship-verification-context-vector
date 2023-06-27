from collections import OrderedDict
import re

import numpy as np

#returns a dictionary sorted by the values in ascending or descending order
def sort_dict_by_value(d, reverse = False):
    return dict(sorted(d.items(), key = lambda x: x[1], reverse = reverse))

#
def getFeatures(text1, text2, n):
    #1) Process Text
    # remove punctuation from the texts
    processedText1 = re.sub(r'[^\w\s]', '', text1)
    processedText2 = re.sub(r'[^\w\s]', '', text2)

    #clean strings and lowercase
    pat = re.compile(r'[^a-zA-Z ]+')
    processedText1 = re.sub(pat, '', processedText1).lower()
    processedText2 = re.sub(pat, '', processedText2).lower()

    tokens = set()
    # dict for keeping track of occurrences. to be used later in ranking.
    # hashFrequency = {}
    #initializes variables and dictionaries for storing tokens, frequencies, rankings, and context vectors
   
    #hashFrequency stores frequencies of tokens in the text
    hashFrequency = OrderedDict()
    #stores the ranking of tokens based on their frequency. Keys are tokens, Values are the rankings
   
    hashTokenRanking = {}
    #stores the reverse mapping of hashTokenRankinig, keys are rankings, Values are Tokens,
    hashRankingToken = {}
   
    #stores total number of unique tokens in text1
    nbTokensInText1 = 0

    splitText1 = processedText1.split(' ')
    for word in splitText1:
        tokens.add(word)
        if word in hashFrequency:
            hashFrequency[word] = hashFrequency[word] + 1
        else:
            hashFrequency[word] = 1
    nbTokensInText1 = len(tokens)

    # for adding missing words which are present in text
    # in cvectors of text 1. add word in token list

    splitText2 = processedText2.split(' ')

    #count tokens in text 2 that arent in text1
    for word in splitText2:
        tokens.add(word)
        if word not in hashFrequency:
            hashFrequency[word] = 0
    i = 1
    # sort hash frequency
    
    sortedHashFreq = sort_dict_by_value(hashFrequency, True)

    #creates the rankings for tokens
    for token in sortedHashFreq:
        hashTokenRanking[token] = i
        hashRankingToken[i] = token
        i = i + 1

    #create context vectors
    after = {}
    before = {}
    #The outer dictionary's keys correspond to target word indices (hashTokenRanking values), 
    #and the inner dictionary's keys represent the positions. 
    #The values in the inner dictionary are arrays that indicate the co-occurrence frequencies of other words at those positions.
    for index, word in enumerate(splitText1):
        # word = splitText1[index]
        #get ranking of target word
        targetWordIndex = hashTokenRanking[word]
        # iterate from 1 to n (inclusive)
        #capture context within window of size n
        for position in range(1, n+1):
        # for after
            if (index + position < len(splitText1)):
                contextWord = splitText1[index + position]
                #position of the context word in the context vector.
                contextWordIndex = hashTokenRanking[contextWord]
                #check the position dictoinary, because we may have already seen this
                #word before, and created a position dictoinary for the frequencies 
                #in the window when we last saw the word
                if (targetWordIndex in after):
                    positionDict = after[targetWordIndex]
                    if (position in positionDict):
                        relFreqAtPositionJ = after[targetWordIndex][position]
                        relFreqAtPositionJ[contextWordIndex - 1] = relFreqAtPositionJ[contextWordIndex - 1] + 1
                        #position dictionary gives sus the position n the window the word was found 
                        #then we use the ranking of the word at that position to update the position dict
                        #which basically tells us, hey! this word appeared at postion 3 from our target word, 
                        #it might be different from the word at position 3 when we last saw the target word
                        #so lets update its co-occurence count based on its rank (index in the array)
                    else:
                        #create an array
                        relFreqAtPositionJ = [0] * len(tokens)
                        relFreqAtPositionJ[contextWordIndex - 1] = 1
                        positionDict[position] = relFreqAtPositionJ
                else:
                    relFreqAtPositionJ = [0] * len(tokens)
                    relFreqAtPositionJ[contextWordIndex - 1] = 1
                    positionDict = {}
                    positionDict[position] = relFreqAtPositionJ
                    after[targetWordIndex] = positionDict
             # for before
            if (index - position >= 0):
                contextWord = splitText1[index - position]
                contextWordIndex = hashTokenRanking[contextWord]

                if (targetWordIndex in before):
                    positionDict = before[targetWordIndex]
                    if (position in positionDict):
                        relFreqAtPositionJ = before[targetWordIndex][position]
                        relFreqAtPositionJ[contextWordIndex - 1] = relFreqAtPositionJ[contextWordIndex - 1] + 1
                    else:
                        #create an array
                        relFreqAtPositionJ = [0] * len(tokens)
                        relFreqAtPositionJ[contextWordIndex - 1] = 1
                        positionDict[position] = relFreqAtPositionJ
                else:
                    relFreqAtPositionJ = [0] * len(tokens)
                    relFreqAtPositionJ[contextWordIndex - 1] = 1
                    positionDict = {}
                    positionDict[position] = relFreqAtPositionJ
                    before[targetWordIndex] = positionDict

    # process before and after for missing position vectors
    contextVectorHash = {}
    for rank in hashTokenRanking.values():
        contextVectorHash[rank] = []
        # start adding freq from before
        # n to 1 in before (so negative)
        for negativePos in range(n, 0, -1):
            # print(negativePos)
            if (rank not in before):
                contextVectorHash[rank] += [0] * len(tokens)
            else:
                if (negativePos not in before[rank]):
                    contextVectorHash[rank] += [0] * len(tokens)
                else:
                    contextVectorHash[rank] += before[rank][negativePos]
        for positivePos in range(1, n+1):
            if (rank not in after):
                contextVectorHash[rank] += [0] * len(tokens)
            else:
                if (positivePos not in after[rank]):
                    contextVectorHash[rank] += [0] * len(tokens)
                else:
                    contextVectorHash[rank] += after[rank][positivePos]
    notNormalized = contextVectorHash.copy()
    for rank in hashTokenRanking.values():
        arrVector = np.asarray(contextVectorHash[rank])
        contextVectorHash[rank] = arrVector / float(nbTokensInText1)
        
    return notNormalized, hashFrequency, hashTokenRanking
text1 = "I love programming code code code code"
text2 = "Programming is fun"
n=2
print(getFeatures(text1,text2,n))

#[2, 0, 1, 1, 0, 0, 3, 0, 0, 1, 0, 0, 3, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0]


#{1 (target word rank):  {1 (window  position 1): [0,2,3,4] (co-occurence frequencies of all words at position 1, we know each word by the rnak!),1;[]}}