from get_context_vector import generateFeatures
import numpy as np
# Test case 1
text1 = "I love programming code code code code"
text2 = "Programming is fun"
n = 2
context_vectors, frequency_hash, ranking_hash = generateFeatures(text1, text2, n)

print("Test Case 1:")
print("Context Vectors:")
print(context_vectors)
print("Frequency Hash:")
print(frequency_hash)
print("Ranking Hash:")
print(ranking_hash)
print()

# def test_generateFeatures():
#     # Test case with two empty strings as input
#     text1 = ""
#     text2 = ""
#     n = 2
#     expected_output = np.zeros(0)
#     assert np.array_equal(generateFeatures(text1, text2, n)[0], expected_output)

#     # Test case with two identical strings as input
#     text1 = "hello world"
#     text2 = "hello world"
#     n = 2
#     expected_output = np.ones(2)
#     print(generateFeatures(text1, text2, n)[0], "TO  BE ASSERTED")
#     assert np.array_equal(generateFeatures(text1, text2, n)[0], expected_output)

#     # Test case with two different strings as input
#     text1 = "hello world"
#     text2 = "goodbye world"
#     n = 2
#     expected_output = np.array([1, 1, 1, 0])
#     assert np.array_equal(generateFeatures(text1, text2, n)[0], expected_output)

#     # Test case with n=0
#     text1 = "hello world"
#     text2 = "goodbye world"
#     n = 0
#     expected_output = np.ones(4)
#     assert np.array_equal(generateFeatures(text1, text2, n)[0], expected_output)
# # Test case 2
# text1 = "The cat is black"
# text2 = "The dog is brown"
# n = 2
# context_vectors, frequency_hash, ranking_hash = generateFeatures(text1, text2, n)

# print("Test Case 2:")
# print("Context Vectors:")
# print(context_vectors)
# print("Frequency Hash:")
# print(frequency_hash)
# print("Ranking Hash:")
# print(ranking_hash)
# print()

# # Test case 3
# text1 = "I like pizza"
# text2 = "Pizza is delicious"
# n = 1
# context_vectors, frequency_hash, ranking_hash = generateFeatures(text1, text2, n)

# print("Test Case 3:")
# print("Context Vectors:")
# print(context_vectors)
# print("Frequency Hash:")
# print(frequency_hash)
# print("Ranking Hash:")
# print(ranking_hash)
# print()
# test_generateFeatures()