The data structure that is being used in this assignment is Hashes. The index is created via a hash, the dicitionary with all the information is saved in the data folder under doc_info. The algorithm I used to count the amount of times the term has occured, was by making a simple hash table that stored the amount of time each term occured in the whole sentence. I also used an algorithm to extract the correct documents, by checking if the term inputted by the user was in this abstract of the document.

To ensure that you use the system properly, you must run test.rb in the following way. It will create your inverted index, as well as the two necessary files. Once you run test.rb, it will prompt you to enter a term of your choices. It retrieves the DocId, title, author, publishing date, and term frequency. (I was not able to complete the rest)

To run test.rb you must run it like so,

	ruby test.rb [fileName] [stemOn] [stopOn]

	Ex: ruby test.rb cacm.all [stemOn] [stopOn]

To run without stemming and stopwords run it like so, 
	
	ruby test.rb [fileName]

If you would like to quit, the test.rb then enter ZZEND.


