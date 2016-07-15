# CPS 842
# Rogerio Ribeiro
# 500527368

# This program just includes helper functions for gui

require 'json'
require './recommender_engine'

def update(name, movie)
			
			# Loads the user_data.json file and reads into a hash.
			user_hash = JSON.load(File.read("./json/user_data.json"))

			# Loads the movie_list.json file, which has all the movie titles.
			movie_hash = File.read('./json/movie_list.json')
			movie_data = JSON.parse(movie_hash)

			movies_in_list = Array.new
			
			#Sorts movie titles alphabetically
			sorted_movie = movie_data.sort_by{|a| a['tit']}

			i = 0
			size_hash = sorted_movie.length

			#Refeshes array
			movies_in_list = Array.new

			#go through whole hash of movies, until end
			while i < size_hash do 

				included_movie = sorted_movie[i]['tit'].to_s.downcase
				
				# check if the movie given by user is in the has and if it is push into an array,
				# movies_in_list.
				if included_movie.include?(movie.downcase)
					movies_in_list.push(sorted_movie[i]['tit'].to_s.downcase)
				end

				#increment
				i += 1
			end

			# Check if the user exists in the user_hash
			if user_hash.has_key?(name)
				if movies_in_list.include?(movie.downcase)
					# If the movie list is bigger than 1, show user movies with similar names. 
					if movies_in_list.length > 1
						puts "Their are two movie options, which one do you choose?\n"
						puts movies_in_list
						option = gets.chomp
						
						puts "From 0-5, what is your rating?"
						rating = gets.chomp
						
						if rating.to_i <= 5
							user_hash[name][option.downcase] = rating.to_i
						else
							puts "That's not a number from 0-5. Try again!"
						end
					
					# When the movie list is not bigger than 1
					else

						# check if the user has rated anything, if not push rating into array
						# else put the ratings of the user in array
						if user_hash[name].length == 0
							puts "From 0-5, what is your rating?"
							rating = gets.chomp

							if rating.to_i <= 5
								user_hash[name] = {movie.downcase => rating.to_i}
							else
								puts "That's not a number from 0-5. Try again!"
							end
						else
							puts "From 0-5, what is your rating?"
							rating = gets.chomp

							if rating.to_i <= 5
							user_hash[name][movie.downcase] = rating.to_i
							else
								puts "That's not a number from 0-5. Try again!"
							end
						end
					end
				# If they input a movie that is incorrect, show similar named movies. 
				else
					puts "Sorry, that movie is not in the database. These are the similar movies: \n"
					puts movies_in_list
				end
			else
				if movies_in_list.include?(movie.downcase)
					puts "From 0-5, what is your rating?"
						rating = gets.chomp
						
						if rating.to_i <= 5
							user_hash[name] = {movie.downcase => rating.to_i}
						else
							puts "That's not a number from 0-5. Try again!"
						end
					
				else
					puts "Sorry, that movie is not in the database."
				end
			end

			# user_hash[name] = {movie => rating.to_i}
			File.write("./json/user_data.json", JSON.dump(user_hash))
end

# Based on letter the user has chosen, it will display the movie titles that start with the letter.
def display(letter)
		user_hash = JSON.load(File.read("./json/user_data.json"))

		movie_hash = File.read('./json/movie_list.json')
		movie_data = JSON.parse(movie_hash)

		movies_by_letter = Array.new
		
		i = 0
		size_hash = sorted_movie.length

		# goes throught whole movie_list and sees if the movie title starts with the given letter.
		while i < size_hash do 
			if sorted_movie[i]['tit'].to_s.downcase.start_with?(letter)
				movies_by_letter.push(sorted_movie[i]['tit'])
			end

			#increment
			i+=1
		end

		puts movies_by_letter
end
 