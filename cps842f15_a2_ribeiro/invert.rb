# Rogerio Ribeiro, 500527368
# Assignment 2
# CPS 842

require 'benchmark'
require 'fileutils'

require './dictionary.rb'
require './stemmer.rb'

def extract_document(terms)

	text = terms.gsub(/[^A-Za-z0-9' ]/, ' ')
	text = text.gsub(/(?<last>[a-z])(?<first>[A-Z])/, '\k<last> \k<first>')
	words = text.downcase.split

	all = terms.split(" ")
	pos = 0

	if @flag_stop
		words = words.delete_if {|t| @stopwords.include?(t)}
	end

	words.each do |w|

		if(all[pos] != nil) and not (all[pos].downcase.include?(w))
			pos += 1
			redo
		end

		if @flag_stem
			w = w.stem
		end

		if not @hash.has_key?(w)
			@hash[w] = TermData.new
		end

		@hash[w].addData(@docid, (@docpos+pos))
		pos += 1
	end

	@docpos += all.size
end

def get_stopword_list
	
	list = []

	File.open("stopwords.txt", "r") do |file|
		file.each_line do |line|
			list.push(line.chomp)
		end
	end

	return list
end

message = "Sorry something went wrong try: ruby invert.rb <document file name> [stemOn] [stopOn]\n\n"

if ARGV.length < 1
	puts"Error!! You seem to have some missing arguments."
	puts message
	exit
end

@filename = ARGV.shift

if File.exists?(@filename)
	@file = File.open(@filename, "r")
else
	puts"Error!! File #{@filename} does not exist."
	puts message
	exit
end

if ARGV.include?("stemOn")
	@flag_stem = true
end

if ARGV.include?("stopOn")
	@flag_stop = true
	@stopwords = get_stopword_list
end

@hash = Hash.new
@docinfo = Hash.new
@current_op = ""

@docid
@doctitle
@docauthors
@docpos

# time the inverted index creation
time = Benchmark.realtime do

    while (line = @file.gets)
        next if line == nil or line == ""
        
        if (line[0] == ".")
            @current_op = line[1]
            
            if (@current_op == "I") 
            
                if not @docid == nil
                    @docinfo[@docid] = DocumentInfo.new(@doctitle.chomp(" "), @docauthors.chomp(", "))
                end
                
                @docid = line.split[1].to_i
                @doctitle = ""
                @docauthors = ""
                @docpos = 0
            end
               
        else 
            case @current_op 
             
                when "T" # on title
                    @doctitle += line.chomp + " "
                    extract_document(line)
                    
                when "W" # on abstract
                    extract_document(line)
                    
                when "A" # on author
                    @docauthors += line.chomp + ", "
                    extract_document(line)

                when "N", "X", "B" # skip to next on those
                    next
            end
        end
    end
    
    @docinfo[@docid] = DocumentInfo.new(@doctitle.chomp(" "), @docauthors.chomp(", "))

end

@file.close

@hash = Hash[@hash.sort_by { |k,v| k }]

#prints benchmark
puts
puts "Inverted Index Creation Time: #{time}\n\n"

unless File.directory?("data")
	FileUtils.mkdir_p("data")
end

File.open("data/index", "wb") do |savefile|
	savefile.write(Marshal.dump(@hash))
end

File.open("data/doc_info", "wb") do |savefile|
	savefile.write(Marshal.dump(@docinfo))
end