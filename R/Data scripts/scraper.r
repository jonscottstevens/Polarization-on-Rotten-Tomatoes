# First, we load the rvest package, which is a web-scraping package for R
library(rvest) 

# We'll also need the str_count function from stringr
library(stringr)

# Now let's define a function that scrapes any RT user review page and returns a data frame

getPageOfUserReviews <- function(url){
	# Read in a page of RT user reviews
	html <- read_html(url)
	
	# Extract the user reviews
	Reviews <- html_nodes(html, ".user_review")
	
	# Sometimes a page is missing, for some reason
	if(length(Reviews)==0){return("")}
	
	# Exclude reviews with no score
	noScore <- c(which(grepl("class=\"wts", Reviews)), which(grepl("class=\"ni", Reviews)), which(grepl("class=\"\"", Reviews)))
	if(length(noScore)>0){Reviews <- Reviews[-1*noScore]}
	
	# Extract text of reviews; return an empty string if the page contains no review text
	Text <- html_text(Reviews)
	if(length(Text)==0){return("")}
	
	# Raw html for the star ratings gives us pictures of stars and 1/2's... let's turn these in to numerical ratings
	ratingCode <- html_nodes(html, ".fl")
	Rating <- sapply(ratingCode, str_count, pattern="star")
	halfStars <- sapply(ratingCode, function(x){as.numeric(grepl("½", x))/2})
	Rating <- Rating + halfStars
	
	# Return data frame with review text and score for each valid review
	return(data.frame(Rating,Text))
}

# Now let's do this for all pages of reviews for any given movie

getUserReviews <- function(movie){

	# Turn movie ID into URL for the first page of reviews
	firstURL <- sprintf("https://www.rottentomatoes.com/m/%s/reviews/?type=user", movie)
	firstPage <- read_html(firstURL)
	
	# Locate the footer with the number of pages of reviews
	footer <- html_text(html_nodes(firstPage, ".pageInfo"))[1]
	
	# Use string splitting to extract number of pages
	pages <- strsplit(footer, "Page 1 of ")[[1]][2]

	# Construct and return a big data frame with all the reviews
	masterDF <- getPageOfUserReviews(firstURL)
	print(1)
	if(pages>1){
		for(n in 2:pages){
			print(n)
			url <- sprintf("https://www.rottentomatoes.com/m/%s/reviews/?page=%s&type=user", movie, toString(n))
			pageOfReviews <- getPageOfUserReviews(url)
			if(typeof(pageOfReviews)!="character"){
				masterDF <- rbind(masterDF, pageOfReviews)
			}
		}
	}
	return(masterDF)
}

# Create movie data

ready_player_one <- getUserReviews("ready_player_one")
write.csv(ready_player_one, "Movie Data/ready_player_one.csv")

star_wars_the_last_jedi <- getUserReviews("star_wars_the_last_jedi")
write.csv(star_wars_the_last_jedi, "Movie Data/star_wars_the_last_jedi.csv")

black_panther_2018 <- getUserReviews("black_panther_2018")
write.csv(black_panther_2018, "Movie Data/black_panther_2018.csv")

sherlock_gnomes <- getUserReviews("sherlock_gnomes")
write.csv(sherlock_gnomes, "Movie Data/sherlock_gnomes.csv")

tomb_raider_2018 <- getUserReviews("tomb_raider_2018")
write.csv(tomb_raider_2018, "Movie Data/tomb_raider_2018.csv")

a_wrinkle_in_time_2018 <- getUserReviews("a_wrinkle_in_time_2018")
write.csv(a_wrinkle_in_time_2018, "Movie Data/a_wrinkle_in_time_2018.csv")

love_simon <- getUserReviews("love_simon")
write.csv(love_simon, "Movie Data/love_simon.csv")

paul_apostle_of_christ <- getUserReviews("paul_apostle_of_christ")
write.csv(paul_apostle_of_christ, "Movie Data/paul_apostle_of_christ.csv")

gods_not_dead_a_light_in_darkness <- getUserReviews("gods_not_dead_a_light_in_darkness")
write.csv(gods_not_dead_a_light_in_darkness, "Movie Data/gods_not_dead_a_light_in_darkness.csv")

peter_rabbit_2018 <- getUserReviews("peter_rabbit_2018")
write.csv(peter_rabbit_2018, "Movie Data/peter_rabbit_2018.csv")

the_death_of_stalin <- getUserReviews("the_death_of_stalin")
write.csv(the_death_of_stalin, "Movie Data/the_death_of_stalin.csv")

jumanji_welcome_to_the_jungle <- getUserReviews("jumanji_welcome_to_the_jungle")
write.csv(jumanji_welcome_to_the_jungle, "Movie Data/jumanji_welcome_to_the_jungle.csv")

annihilation <- getUserReviews("annihilation")
write.csv(annihilation, "Movie Data/annihilation.csv")

the_shape_of_water_2017 <- getUserReviews("the_shape_of_water_2017")
write.csv(the_shape_of_water_2017, "Movie Data/the_shape_of_water_2017.csv")

ferdinand <- getUserReviews("ferdinand")
write.csv(ferdinand, "Movie Data/ferdinand.csv")

coco_2017 <- getUserReviews("coco_2017")
write.csv(coco_2017, "Movie Data/coco_2017.csv")