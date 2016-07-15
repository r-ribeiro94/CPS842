# CPS 842
# Rogerio Ribeiro
# 500527368

# This program runs the command line interface, for users to rate the selected movies out of a database.
require 'json'
require './recommender_engine.rb'
require './library.rb'

# Loads the user_data.json file and reads into a hash.
user_hash = JSON.load(File.read("./json/user_data.json"))

# Loads the movie_list.json file, which has all the movie titles.
movie_hash = File.read('./json/movie_list.json')
# Parse the json file into a hash
movie_data = JSON.parse(movie_hash)

# Ask for User Name
puts "Enter Username or 'q' to quit: "
name = gets.chomp.downcase
system "clear"
if(name == 'q')
	puts "Goodbye!"
	exit
end

# Check if the user already exists in the user_hash
# If the use exists then excute code, else execute different code
if user_hash.has_key?(name)
	puts "Welcome Back, " << name << "!\n"
	puts "What would you like to do?"
	puts "-- Type 'display' to display movies."
	puts "-- Type 'update' to update a movie."
	puts "-- Type 'delete' to delete a previous rating."
	puts "-- Type 'recommend' to recommend movies."
	puts "-- Type 'exit' to exit the command line."
else
	puts "Hello, " << name <<". Welcome to the movie rating database."
	puts "What would you like to do?"
	puts "-- Type 'display' to display movies."
	puts "-- Type 'update' to update a movie."
	puts "-- Type 'recommend' to recommend movies."
	puts "-- Type 'exit' to exit the command line."
end

# Loop till exit
loop do

	puts "Input your command, type 'help' if you forgot the commands"
	choice = gets.chomp.downcase
	break if choice == 'exit'
	system "clear"

	#Sorts movie titles alphabetically
	# sorted_movie = movie_data.sort_by{|a| a['tit']}

	movies_by_letter = Array.new
	movies_in_list = Array.new

	case choice
	when 'update'
			
			puts "Select a movie: "
			movie = gets.chomp
			# puts movie

			update(name, movie)

	when 'display'

			puts "Choose a letter, for a list of movies."
			letter = gets.chomp.downcase

			display(letter)

	when 'recommend'

		# If their are no recomendations, then tell user, else show recommendations.
		if recommendations(name.to_s).length == 0
			puts "Sorry, their is not enough data for reccomendations."
		else
			puts "\n" << recommendations(name.to_s).to_s
			puts "\n"
		end

	when 'help'

		# help case
		puts "Welcome to the help directory, below are the commands."
		puts "-- Type 'display' to display movies."
		puts "-- Type 'update' to update a movie."
		puts "-- Type 'delete' to delete a previous rating."
		puts "-- Type 'recommend' to recommend movies."
		puts "-- Type 'exit' to exit the command line."

	when 'delete'


		# Refereshes the read, incase the user has added any new entries on command line.
		# Loads the user_data.json file and reads into a hash.
		user_hash = JSON.load(File.read("./json/user_data.json"))
		
		puts "This is your array of ratings: " << user_hash[name].to_s

		
		if user_hash[name].length == 0
			puts "Sorry but you have yet to rate a movie."
		else 
			puts "Select a movie which you want to be deleted from your list: "
			movie = gets.chomp.downcase

			if user_hash[name].has_key?(movie)
				user_hash[name].delete_if{|key, value| key == movie}
			else
				puts "That movie, has not been rated by you. Try again!"
			end

			puts "Update array of ratings: " << user_hash[name].to_s
		end

		# Write to the json file
		File.write("./json/user_data.json", JSON.dump(user_hash))
	else
		puts "Sorry, that does not seem to be a correct command!"
	end
end

puts "Goodbye " << name << "!" 

#REFERENCES

# puts movies_by_letter
# if user_hash.has_key?(name) and rating.to_i <= 5
# 	user_hash[name][movie] = rating.to_i
# else
# 	user_hash[name] = {movie => 0}
# end

# File.write("user_data.json", JSON.dump(user_hash))