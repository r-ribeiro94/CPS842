# CPS 842
# Rogerio Ribeiro
# 500527368

# This program, is the recommender engine, for the users. It calculates, the sim scores and pearson collection, and gets closest neighbour via similarity scores.
# It is used by the gui.rb, to return users recommended movies.

include Math

require 'json'

def sim_score(p1, p2)

	file = File.read('./json/user_data.json')
	data_hash = JSON.parse(file)

	# Returns ratio Euclidean distance score of person1(p1) and person2(p2)
	
	both_viewed = Hash.new # Array that holds both rated items of person1 and person2

	data_hash[p1].each do |key, value|

		if data_hash[p2].include?(key)
			both_viewed[key] = 1
		end
	end

	# Checks if they both have a common rating item
	if both_viewed.length == 0
		return 0
	end

	array_of_eclidean_distance = Array.new
	sum_of_eclidean_distance = 0

	# Get Euclidean distance
	data_hash[p1].each do |key, value|
		if data_hash[p2].include?(key)
			array_of_eclidean_distance.push((data_hash[p1][key] - data_hash[p2][key]) ** 2)
		end

		sum_of_eclidean_distance = array_of_eclidean_distance.inject{|sum, x| sum + x}
	end

	return 1/(1+sqrt(sum_of_eclidean_distance))
end

def pearson_correlation(p1, p2)

	file = File.read('./json/user_data.json')
	data_hash = JSON.parse(file)
	
	both_rated = Hash.new
	
	# check if they rated the same movie, and their ratings into hash both_rated
	data_hash[p1].each do |key, value|
		if data_hash[p2].include?(key)
			both_rated[key] = 1
		end
	end

	num_ratings = both_rated.length
	
	# check for number of ratings in common
	if num_ratings == 0
		return 0
	end

	pref_sum1 = Array.new
	pref_sum2 = Array.new

	sqrpref_sum1 = Array.new
	sqrpref_sum2 = Array.new

	product_sum_of_users = Array.new

	both_rated.each do |key,value|
		
		# adds all Preference Sums
		pref_sum1.push(data_hash[p1][key])
		pref_sum2.push(data_hash[p2][key])

		# Squares sum up of preference of each user
		sqrpref_sum1.push((data_hash[p1][key]) ** 2)
		sqrpref_sum2.push((data_hash[p2][key]) ** 2)

		# sum up the Product Sum of each user
		product_sum_of_users.push(data_hash[p1][key] * data_hash[p2][key])
	end

	# calculates the pearson score, stores the numerator and denominator and divides numerator/denominator
	numerator = product_sum_of_users.inject{|sum,x|sum+x} - (pref_sum1.inject{|sum,x|sum+x}*pref_sum2.inject{|sum,x|sum+x}/num_ratings)
	denominator = sqrt((sqrpref_sum1.inject{|sum,x|sum+x} - (pref_sum1.inject{|sum,x|sum+x} ** 2)/num_ratings) * (sqrpref_sum2.inject{|sum,x|sum+x} - (pref_sum2.inject{|sum,x|sum+x} ** 2)/num_ratings))
		if denominator == 0
			return 0
		else
			r = numerator/denominator
			return r
		end

end

# Gets the user that is the most similar
def closest_neighbours(person, number_of_users)

	file = File.read('./json/user_data.json')
	data_hash = JSON.parse(file)

	scores = Array.new
	person_collection = Array.new

	# Returns the number of similar uses to a specific person
	data_hash.each do |key,value|
		if key != person
			person_collection.push(key)
			scores.push(pearson_correlation(person, key))
		end
	end

	final_score = scores.zip(person_collection)

	# Sort the highest similar person to lowest
	final_score.sort!{|x,y| y <=> x}
	final_score[0 .. number_of_users - 1]
end

def recommendations(person)
	
	file = File.read('./json/user_data.json')
	data_hash = JSON.parse(file)

	totals = Hash.new
	simSums = Hash.new # Simular Sums
	rankings_list = Array.new
	recommendations_list = Array.new

	# Gets the recommendation for the user, by using weighted sum of the other user's
	data_hash.each do |other,value|
		# Make sure it is not calculate for the same person
		if other == person
			next
		end
		sim = pearson_correlation(person,other)

		# Only get positive values
		if sim <= 0 
			next
		end

		# Get only movies that the user has not seen
		data_hash[other].each do |item, value| 

			if data_hash[person].has_key?(item) == false or data_hash[person][item] == 0

				# Similarity * score
				totals.default = 0
				totals[item] += data_hash[other][item] * sim

				# Sum of similarities
				simSums.default = 0
				simSums[item] += sim
			end
		end
	end

	movies = Array.new
	# Create a normalized list
	totals.each do |item, total|
		movies.push(item)
		rankings_list.push(total/simSums[item])
	end

	# Rank from highest to lowest score
	rankings_list.zip(movies).sort!{|x,y| y <=> x}

	# Returns the recommended items
	rankings_list.zip(movies).each do |score, recommend_item|
		recommendations_list.push(recommend_item)
	end

	return recommendations_list

end