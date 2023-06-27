from collections import defaultdict, Counter
import re
import numpy as np

def getFeatures(text1, text2, n):
    # Remove non-alphabetic characters and make texts lowercase
    text1 = re.sub(r'[^a-zA-Z ]+', '', text1.lower())
    text2 = re.sub(r'[^a-zA-Z ]+', '', text2.lower())
    
    # Split texts into words
    words1 = text1.split()
    words2 = text2.split()
    
    # Count word frequencies in text1
    freq = Counter(words1)

    # Words in text2 but not in text1, initialized with zero frequency
    for word in words2:
        if word not in freq:
            freq[word] = 0
    
    # Sort by frequency and order of appearance
    sorted_words = sorted(freq.keys(), key=lambda x: (-freq[x], words1.index(x) if x in words1 else float("inf")))
    word_rank = {word: i+1 for i, word in enumerate(sorted_words)}
    rank_word = {i+1: word for i, word in enumerate(sorted_words)}
    
    # Initialize context vectors
    before, after = defaultdict(lambda: defaultdict(lambda: np.zeros(len(word_rank)))), defaultdict(lambda: defaultdict(lambda: np.zeros(len(word_rank))))
    
    # Create context vectors
    for i, word in enumerate(words1):
        target_rank = word_rank[word]
        for j in range(1, n+1):
            if i-j >= 0:
                context_word = words1[i-j]
                context_rank = word_rank[context_word]
                before[target_rank][j][context_rank-1] += 1
            if i+j < len(words1):
                context_word = words1[i+j]
                context_rank = word_rank[context_word]
                after[target_rank][j][context_rank-1] += 1
    
    # Build context vector hash
    context_vector_hash = {}
    for rank in word_rank.values():
        context_vector = []
        for j in range(n, 0, -1):
            context_vector.extend(before[rank][j])
        for j in range(1, n+1):
            context_vector.extend(after[rank][j])
        context_vector_hash[rank] = np.array(context_vector) / float(len(words1))
    
    return context_vector_hash, freq, word_rank

text1 = "I love programming code code code code"
text2 = "Programming is fun"
n = 2
print(getFeatures(text1, text2, n))
