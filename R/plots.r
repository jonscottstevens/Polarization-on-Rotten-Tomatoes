# Read the combined user review data set for 16 top box office movies on Rotten Tomatoes
combined <- read.csv("rottenTomatoesUserReviews.csv")

# Convert user review text to unicode
combined$Text <- iconv(combined$Text, to="UTF-8")

# Look first at two films with the same RT critic score average, but very different user reviews -- Star Wars: The Last Jedi and Black Panther
twoFilms <- subset(combined, is.element(Movie, c("The Last Jedi", "Black Panther")))

# We're using ggplot2 with classic theme

library(ggplot2)
theme_set(theme_classic())

# A density plot of user review scores (0.5 -- 5 stars) for TLJ and BP
ggplot(twoFilms, aes(Rating))+ geom_density(aes(fill = Movie), alpha=0.5) + labs(title="Density plot", subtitle="Rotten Tomatoes audience scores", x="Audience Score", y="Density")

# Now let's look at two films with similar user review scores, but very different critic reviews -- Sherlock Gnomes and Black Panther

twoFilmsB <- subset(combined, is.element(Movie, c("Sherlock Gnomes", "Black Panther")))
ggplot(twoFilmsB, aes(Rating))+ geom_density(aes(fill = Movie), alpha=0.5) + labs(title="Density plot", subtitle="Rotten Tomatoes audience scores", x="Audience Score", y="Density")



# To do word clouds we'll need the tm (text mining) package and the wordcloud package

library(tm)
library(wordcloud)

# A function for creating a wordcloud-ready data frame from the user reviews of any set of movies; may specify review ratings (0.5 stars only by default)

prepareForCloud <- function(movies, ratings=c(0.5), ignore=c(), filter=0){
	# Create a subset of the combined data set
	df <- subset(combined, is.element(Movie, movies) & is.element(Rating, ratings))
	
	# Create a tm corpus object
	dfCorpus <- Corpus(VectorSource(df$Text))

	# A long stop word list
	source("stopWords.r")

	# Add other words we don't want in our word cloud, which are given by the 'ignore' parameter
	stopWords<-c(stopWords, ignore)

	# Create a term matrix
	dfMatrix <- TermDocumentMatrix(dfCorpus, control = list(removePunctuation = TRUE, stopwords = stopWords, removeNumbers = TRUE, tolower = TRUE))

	# Create a new data frame for wordcloud

	dfWordFreqs <- sort(rowSums(as.matrix(dfMatrix)), decreasing=TRUE)
	newDF <- data.frame(word=names(dfWordFreqs), freq=dfWordFreqs)
	
	# The 'filter' parameter excludes words that are mostly specific to one film, requiring a word to occur at least n times in reviews of other films
	if(filter>0){
		secondaryOccurrences <- function(w){
			compare <- subset(combined, is.element(Rating, ratings))
			occurrenceSummary <- summary(compare[grep(tolower(w), tolower(compare$Text)), "Movie"])
			return(sum(occurrenceSummary) - max(occurrenceSummary))
		}
		newDF$secondary <- sapply(newDF$word, secondaryOccurrences)
		newDF <- subset(newDF, secondary >= filter)
	}

	# Return the data frame
	return(newDF)
}

# Word cloud for 0.5-star user reviews of The Last Jedi

tlj <- prepareForCloud(movies=c("The Last Jedi"), ignore=c("movie", "film", "star", "wars"))
wordcloud(tlj$word, tlj$freq, max.words = 180, random.order = FALSE, colors=brewer.pal(8, "Dark2"))

# Word cloud for 0.5-star user reviews of The Shape of Water, the movie in the data set with the second highest difference between critics and users

tsow <- prepareForCloud(movies=c("The Shape of Water"), ignore=c("movie", "film", "shape", "water"))
wordcloud(tsow$word, tsow$freq, max.words = 180, random.order = FALSE, colors=brewer.pal(8, "Dark2"))

# Load data on critic scores
scores <- read.csv("scores.csv")

# Calculate difference between average critic score and average user score (the delta score) for each movie

library(dplyr)
reviewSummary <- summarize(group_by(combined, Movie), Rating = round(mean(Rating), 1))
scores$UserReviews <- sapply(scores$Movie, function(m){return(subset(reviewSummary, Movie==m)$Rating)})
scores$ReviewDelta <- scores$Critic - scores$UserReviews

# We'll want to ignore words in the titles of the movies
titleWords <- tolower(strsplit(paste(scores$Movie, collapse=" "), split=" ")[[1]])

# A word cloud to compare movies where critic scores are higher than user (positive delta) to movies where user scores are higher (negative delta)

positive <- prepareForCloud(movies=subset(scores, ReviewDelta>=0)$Movie, ignore=c(titleWords), filter=4)
positiveUnique <- subset(positive, is.element(word, subset(negative, freq>1)$word)==FALSE) # look only at words mostly unique to positive set
wordcloud(positiveUnique$word, positiveUnique$freq, max.words = 150, random.order = FALSE, colors=brewer.pal(8, "Dark2"), scale=c(3, 0.5))



# Finally, let's look at some correlations

# Total number of user reviews for each movie
scores$NumReviews <- sapply(scores$Movie, function(m){return(nrow(subset(combined, Movie==m)))})

# Log proportion of reviews that contain the word "SJW"

clean <- function(r){return(gsub("[[:punct:]]", "", tolower(iconv(r, to="UTF-8"))))} # lowercase, punctuation-free unicode
contains <- function(r, w){return(grepl(tolower(w), clean(r)))} # whether a given review contains a given word
countReviews <- function(word, movie){return(sum(sapply(subset(combined, Movie==movie)$Text, function(x){return(as.numeric(contains(x, word)))})))}
scores$reviewsSJW <- sapply(scores$Movie, function(x){return(countReviews("sjw", x))}) / scores$NumReviews


# Correlation tests

cor.test(scores$ReviewDelta, scores$reviewsSJW)
cor.test(scores$ReviewDelta, scores$UserReviews)

# Plots

ggplot(scores, aes(log(reviewsSJW+.001), ReviewDelta)) + geom_point() + geom_smooth(method="lm") + labs(title="Difference in RT user vs. critic review scores", subtitle="By proportion of user reviews containing the word 'SJW'", x="Log proportion of reviews containing word 'SJW'", y="Critic score - user score")



# Write a csv of combined movie data with delta scores for each individual review, to be used in machine learning exercise

combined$CriticScore <- sapply(combined$Movie, function(m){return(subset(scores, Movie==m)$Critic)})
combined$Delta <- combined$CriticScore - combined$Rating

write.csv(combined, "RTDelta.csv")