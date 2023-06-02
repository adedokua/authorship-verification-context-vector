from collections import OrderedDict
import re
import numpy as np

#sorts dict by its values in ascending order
def sort_dict_by_value(d, reverse=False):
    return dict(sorted(d.items(), key=lambda x: x[1], reverse=reverse))

def generateFeatures(text1, text2, n):
    # Process Texts
    processed_text1 = re.sub(r'[^\w\s]', '', text1)
    processed_text2 = re.sub(r'[^\w\s]', '', text2)

    # Clean strings and lowercase
    pat = re.compile(r'[^a-zA-Z ]+')
    processed_text1 = re.sub(pat, '', processed_text1).lower()
    processed_text2 = re.sub(pat, '', processed_text2).lower()

    # Tokenize texts
    text1_tokens = processed_text1.split()
    text2_tokens = processed_text2.split()

    # Create hash of token frequencies in both texts
    frequency_hash = OrderedDict()
    for token in text1_tokens + text2_tokens:
        if token in frequency_hash:
            frequency_hash[token] += 1
        else:
            frequency_hash[token] = 1

    # Sort hash by frequency
    sorted_frequency_hash = sort_dict_by_value(frequency_hash, reverse=True)

    # Create hash of token indexes in sorted_frequency_hash
    index_hash = {}
    for i, token in enumerate(sorted_frequency_hash.keys()):
        index_hash[token] = i

    # Create hash of token indexes and tokens
    index_token_hash = {}
    for i, token in enumerate(sorted_frequency_hash.keys()):
        index_token_hash[i] = token

    # Add missing tokens from corpus to frequency hash with 0 frequency
    for token in set(text1_tokens + text2_tokens):
        if token not in frequency_hash:
            frequency_hash[token] = 0

    # Create context vectors and ranking hash
    context_vectors = []
    ranking_hash = {}
    for i, token in enumerate(text1_tokens):
        before_context_vector = np.zeros(len(sorted_frequency_hash))
        after_context_vector = np.zeros(len(sorted_frequency_hash))

        for j in range(i - n, i):
            if j >= 0:
                before_token = text1_tokens[j]
                if before_token in frequency_hash:
                    before_context_vector[index_hash[before_token]] += 1

        for j in range(i + 1, i + n + 1):
            if j < len(text1_tokens):
                after_token = text1_tokens[j]
                if after_token in frequency_hash:
                    after_context_vector[index_hash[after_token]] += 1

        context_vector = np.concatenate((before_context_vector, after_context_vector))
        context_vectors.append(context_vector)

        ranking_hash[token] = sorted_frequency_hash[token]

    for i, token in enumerate(text2_tokens):
        before_context_vector = np.zeros(len(sorted_frequency_hash))
        after_context_vector = np.zeros(len(sorted_frequency_hash))

        for j in range(i - n, i):
            if j >= 0:
                before_token = text2_tokens[j]
                if before_token in frequency_hash:
                    before_context_vector[index_hash[before_token]] += 1

        for j in range(i + 1, i + n + 1):
            if j < len(text2_tokens):
                after_token = text2_tokens[j]
                if after_token in frequency_hash:
                    after_context_vector[index_hash[after_token]] += 1

        context_vector = np.concatenate((before_context_vector, after_context_vector))
        context_vectors.append(context_vector)

        ranking_hash[token] = sorted_frequency_hash[token]

    return np.array(context_vectors), frequency_hash, index_token_hash
