# Rogerio Ribeiro, 500527368
# Assignment 1
# CPS 842

require 'benchmark'

require './dictionary.rb'
require './stemmer.rb'
require './invert.rb'

def get_stopword_list
	list = []

	begin 
		File.open(@filename_stopwords, "r") do |file|
			file.each_line{ |line| list.push(line.chomp)}
		end
	rescue
		puts "File '#{@filename_stopwords}' was not found!"
		puts "You are missing a crucial file to commence stopwords. \n\n"
		exit
	end

	return list
end

def perform_stopword_removal(terms)
	terms.delete_if{ |t| @stopwords.include?(t) }
end

def perform_stemming(terms)
	terms.map{ |t| t.stem}
end

@out = File.open("results.txt", "w")

@filename_index = "data/index"
@filename_docinfo = "data/doc_info"
@filename_stopwords = "stopwords.txt"

message = "Sorry something went wrong try: test.rb [stemOn] [stopOn]"

if not File.exists?(@filename_index)
		puts "File '#{@filename_index}' was missing."
		puts "You need to generate 'invert.rb' to generate '#{@filename_index}'.\n\n"
		exit
end

begin
	File.open(@filename_docinfo, "rb") do |file|
		@docinfo = Marshal.load(file.read)
	end

rescue
	puts "File '#{@filename_docinfo} was missing."
	puts "You need to generate 'invert.rb' to generate '#{@filename_index}'.\n\n"
	exit
end

ARGV.each do |args|

	if(args == "stemOn")
		@flag_stem = true
	elsif (args == "stopOn")
		@flag_stop = true
		@stopwords = get_stopword_list
	else
		puts "Incorrect Argument #{args}"
		puts message
		exit
	end
end

ARGV.clear

vsm = VectorSpaceModel.new(@filename_index, @docinfo,size)

while (true)

	puts
		print "Enter Term: "

		term = gets

		if(term == "ZZEND\n")
			puts "Goodbye!"
			@out.close
			exit
		end

		orig = term
		term.gsub!(/[^A-Za-z0-9']/,' ')
		term.downcase!

		if(@flag_stem or @flag_stop)

			terms = term.split

			if(@flag_stop)
				terms = perform_stopword_removal(terms)
			end
			if(@flag_stem)
				terms = perform_stemming(terms)
			end

			term = terms.join(" ")
		end

		results = vsm.search(term)

		if(term.empty?)
			puts
			puts "Sorry there is no such document."
			puts
			next
		end

		results.each_with_index do |r,i|
			break if i >= 25


			puts
			printf("%2d) ", i+1)
			puts "#{@docinfo[r[0]].title}"
			puts "Author[s]: #{@docinfo[0].authors}"
			puts
		end

		@out.puts "Original Query: #{orig}"
		@out.puts "Prepared Query: #{query}"
		@out.puts

		results.each_with_index do |r,i|
			@out.prinf("%4d) ", i+1)
			@out.printf("%04d:", r[0])
			@out.print " #{r[1]}"
			@out.puts
			@out.puts "Title: #{@docinfo[r[0]].title}"
			@out.puts "Author[s]: #{@docinfo[r[0]].authors}"
		end

		@out.puts "----------------------------------------------------------------"
		@out.puts
		@out.flush

end


