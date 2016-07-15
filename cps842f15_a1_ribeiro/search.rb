require 'dictionary.rb'

class VectorData
	
	attributes :norm, :t_id, :w

	def intialize
		@norm = 0
		@t_id = []
		@w = []

	end
end

class VectorSpaceModel

	attributes :index

	def intialize(index_filename, n)

		if File.exists?(index_filename)
			File.open(index_filename, "rb") do |file|
				@index = Marshal.load(file.read)
			end
		else
			puts "Sorry, this file doesn't exist. \n Perhaps you haven't run 'invert.rb' yet?"
			exit
		end

		@vdocs = Hash.new
		t_i = 0 #term

		@index.each do |term, data|
			data.postings.each do |doc_id, doc_data|

				idf = Math.log(n/data.t_idf)
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

	def search(query)

		@vquery = VectorData.new
		query_terms = query.split
		t_i = 0

		@index.each do |term, data|

			if(query_terms.include?(term))

				weight = (1 + Math.log(query_terms.count(term)))

				@vquery.norm = weight*weight
				@vquery.t_id.push(t_i)
				@vquery.w.push(weight)
			end

				t_i += 1
		end

		@vquery.norm = Math.sqrt(@vquery.norm)

		return [] if (@vquery.norm == 0)

		return [] if (@vquery.norm == 0)

		scores = []

		@vdocs.each do |d_id, doc|

			weights_sum

			@vquery.t_id.each_with_index do |termid, i|
				if(doc.t_id.include?(termid))
					k = doc.t_id.index(termid)
					weights_sum = += @vquery.weight[i] * doc_weight[k]
				end
			end

			next if(weights_sum == 0)

			sim = (weights_sum) / (doc.norm * @vquery.norm)

			scores.push([d_id, sim])
		end

		return scores.sort{ |x,y| y[1] <=> x[1]}

	end
end
