# Rogerio Ribeiro, 500527368
# Assignment 2
# CPS 842

require './dictionary.rb'

# Vector Data, which has a norm, term id and a weight. 
# The termid[i] has a weight of weight[i]
class VectorData
	
	attr_accessor :norm, :t_id, :w

	def initialize
		@norm = 0
		@t_id = []
		@w = []

	end
end

# The creation of the Vector Space Model
class VectorSpaceModel

	attr_reader :index

	# Loads the index into memory
	def initialize(index_filename, number_of_docs)

		if File.exists?(index_filename)
			File.open(index_filename, "rb") do |file|
				@index = Marshal.load(file.read)
			end
		else
			puts "Sorry, this file doesn't exist. \n Perhaps you haven't run 'invert.rb' yet?"
			exit
		end

		#Collects information on the document vector
		@vdocs = Hash.new
		t_i = 0 #term

		@index.each do |term, data|
			data.postings.each do |doc_id, doc_data|

				idf = Math.log(number_of_docs/data.term_doc_freq)
				weight = (1 + Math.log(doc_data.freq)) * idf

				if @vdocs[doc_id] == nil
					@vdocs[doc_id] = VectorData.new
				end

				@vdocs[doc_id].norm += weight * weight
				@vdocs[doc_id].t_id.push(t_i)
				@vdocs[doc_id].w.push(weight)
			end

			t_i += 1
		end

		@vdocs.each_value do |v|
			v.norm = Math.sqrt(v.norm)
		end

		@vdocs = Hash[@vdocs.sort_by { |k,v| k}]
	end

	# The search function in the VSM, that'll search the query. 
	def search(query)

		@vquery = VectorData.new
		query_terms = query.split
		t_i = 0

		# For each term in the dictionary.
		@index.each do |term, data|

			# Calculate the weight for the query vector
			if(query_terms.include?(term))

				weight = (1 + Math.log(query_terms.count(term)))

				@vquery.norm = weight*weight
				@vquery.t_id.push(t_i)
				@vquery.w.push(weight)
			end

				t_i += 1
		end

		@vquery.norm = Math.sqrt(@vquery.norm)

		# Returns empty if their are no terms matched to the index
		return [] if (@vquery.norm == 0)

		# The array to collect the relevance scores
		scores = []

		# Calculates the similarity between each document and query
		@vdocs.each do |d_id, doc|

			weights_sum = 0

			# Multiplies their weights to find the corresponding weights
			# This is using the cosine similarity formula
			@vquery.t_id.each_with_index do |termid, i|
				if(doc.t_id.include?(termid))
					k = doc.t_id.index(termid)
					weights_sum += @vquery.w[i] * doc.w[k]
				end
			end

			# Skip if the weights_sum is equal to 0
			next if(weights_sum == 0)

			# Applying the cosine similarity formula
			sim = (weights_sum) / (doc.norm * @vquery.norm)

			scores.push([d_id, sim])
		end

		# Sorts the array by the highest relevance and returns the array
		return scores.sort{ |x,y| y[1] <=> x[1]}

	end
end
