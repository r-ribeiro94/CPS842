# Rogerio Ribeiro, 500527368
# Assignment 2
# CPS 842

require './search.rb'
require './dictionary.rb'
require './stemmer.rb'

# The query file information, like the query terms, and the relevant terms.
class QueryFileInfo

    attr_accessor :query, :relevant

    def initialize
        @query = ""
        @relevant = []
    end
end

# Gets the stopwords, from stopwords.txt, and stores them in an array called list.
def get_stopword_list
    list = []
    
    begin
        File.open("stopwords.txt", "r") do |file|
            file.each_line { |line| list.push( line.chomp ) }
        end
    rescue
        puts "The file 'stopwords.txt' was not found."
        exit
    end

    return list
end

def perform_stopword_removal(terms)
    terms.delete_if { |t| @stopwords.include?( t ) }
end

def perform_stemming(terms)
    terms.map { |t| t.stem }
end


message = "Usage: ruby eval.rb [stemOn] [stopOn]\n\n"

# Gets the users, command-line argument.
ARGV.each do |args|
    if ( args == "help" )
        puts message 
        exit
    elsif ( args == "stemOn" )
        @flag_stem = true
    elsif ( args == "stopOn" )
        @flag_stop = true
        @stopwords = get_stopword_list
    else
        puts "Incorrect argument #{args}."
        puts message
        exit
    end
end

ARGV.clear

# Open file query.text
begin
    @file_query = File.open("query.text", "r")
rescue
    puts "The file 'query.text' not found.\n\n"
    exit
end

# Open file qrels.txt
begin
    @file_qrels = File.open("qrels.text", "r")
rescue
    puts "The file 'qrels.txt' not found.\n\n"
    exit
end

# Read the information from the files that are given, into memory.
@info = Hash.new
@current_op = "" #current operator

@file_query.each_line do |line|
    next if line == nil or line == ""
    
    # if special character, change current operation
    if (line[0] == ".")
        @current_op = line[1]
        
        if (@current_op == "I") # on new query id
            @qid = line.split[1].to_i
            @info[@qid] = QueryFileInfo.new
        end
        
    # else perform query on the current operator.  
    else 
        if (@current_op == "W")
            @info[@qid].query += line.chomp + " "
        end
    end
       
end

@file_qrels.each_line do |line|
    id_q, id_d = line.split
    @info[id_q.to_i].relevant.push( id_d.to_i )
end

# Create a Vector Space Model for searching
vsm = VectorSpaceModel.new( "data/index", 3204 )

puts

# Run querys
@info.each do |k,v|
    next if k == 0 or v.relevant.empty?

    # Prepare Query (cleaning up, stemming and stopword removal)
    query = v.query
    query.gsub!(/[^A-Za-z0-9' ]/, ' ')
    query.downcase!
    
    if (@flag_stem or @flag_stop)
    
        query_terms = query.split
        
        if (@flag_stop) 
            query_terms = perform_stopword_removal(query_terms)
        end
        if (@flag_stem)
            query_terms = perform_stemming(query_terms)
        end
        
        query = query_terms.join(" ")
    
    end
    
    # Runs the VSM search on the query
    results = vsm.search( query )
    
    # Compares the search results to that of the qrels, relevant results.
    retrieved = results.map { |r| r[0] }
    
    map_sum = 0.0
    num_rel = 0
    
    (retrieved.first(25)).each_with_index do |r,i|    
        if (v.relevant.include?( r ))
            num_rel += 1
            map_sum += (1.0 * num_rel / (i+1))
        end
    end
    
    r_precision =  1.0 * ( (retrieved.first(v.relevant.size)) & (v.relevant) ).size / (v.relevant).size
    map = map_sum / (v.relevant).size
    
    # Display Results
    puts "#{k}:"
    puts " R-Precision = #{r_precision}"
    puts " MAP = #{map}"
    
end