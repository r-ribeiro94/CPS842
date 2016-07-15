# Rogerio Ribeiro, 500527368
# Assignment 1
# CPS 842

class TermData
    
    attr_reader :t_idf, :postings
    
    def initialize
        @t_idf = 0      # term document frequency
        @postings = {} # list of posting data
    end
    
    def addData( docid, position )
        
        if not @postings.has_key?( docid )
            @t_idf += 1
            @postings[docid] = PostingData.new
        end
        
        @postings[docid].addData( position )
        
    end
    
end


class PostingData

    attr_reader :freq, :positions

    def initialize
        @freq = 0
        @positions = []
    end
    
    def addData( pos )
        @freq += 1
        positions.push( pos )
    end
    
end


class DocumentInfo
    
    attr_reader :title, :authors
    
    def initialize(doctitle, docauthors)
        @title = doctitle
        @authors = docauthors
    end
    
end