The document postings are ordered by the documents id. The search results return all relevant results (where the cosine similarity > 0). If you run test.rb, you will be only getting the 25 results. 

The weighting scheme that was used in this program is the Standard TD-IDF:

	weight_of_doc = tf * idf = (1+log(f)) * (N/df), where N is the number of documents.
	weight_of_query = (1+log(f))

The programs that were used in this assignment was:
	eval.rb (evaluates the MAP and R-Precision)
	search.rb (searches the query using the Vector Space Model)
	dictionary.rb (used for modularity)
	stemmer.rb (library for stemming)
	test.rb (used to test the searching)

Their are three different programs that need to be run and each one has a different way.
Note: For everything to work in unison, you MUST run invert.rb first.

Running invert.rb:

	ruby invert.rb [document] [stemOn] [stopOn] 

	Example: ruby invert.rb cacm.all stemOn stopOn

Running test.rb:
	
	ruby test.rb [stemOn] [stopOn]

Running eval.rb 
	
	ruby eval.rb [stemOn] [stopOn]

Note: When running any of the program you don't need to have stemming or stoping, you can have none or just one. Just make sure that they're typed the same way though when using any program.

Note: You can also end test.rb, by saying ZZEND.

The index will generate the doc_info, which has the cacm.all files information stored in a hash file. The doc_info is generated by running the invert.rb and is stored in the data folder.

