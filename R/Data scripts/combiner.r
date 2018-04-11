# A simple script for reading in individual movie data files and combining them into one .csv file

tlj <- read.csv("Movie data/star_wars_the_last_jedi.csv")[,2:3]
tlj$Movie <- rep("The Last Jedi" ,nrow(tlj))

rp1 <- read.csv("Movie data/ready_player_one.csv")[,2:3]
rp1$Movie <- rep("Ready Player One" ,nrow(rp1))

bp <- read.csv("Movie data/black_panther_2018.csv")[,2:3]
bp$Movie <- rep("Black Panther" ,nrow(bp))

awit <- read.csv("Movie data/a_wrinkle_in_time_2018.csv")[,2:3]
awit$Movie <- rep("A Wrinkle in Time" ,nrow(awit))

a <- read.csv("Movie data/annihilation.csv")[,2:3]
a$Movie <- rep("Annihilation" ,nrow(a))

co <- read.csv("Movie data/coco_2017.csv")[,2:3]
co$Movie <- rep("Coco" ,nrow(co))

f <- read.csv("Movie data/ferdinand.csv")[,2:3]
f$Movie <- rep("Ferdinand" ,nrow(f))

gind <- read.csv("Movie data/gods_not_dead_a_light_in_darkness.csv")[,2:3]
gind$Movie <- rep("Gods not Dead" ,nrow(gind))

j <- read.csv("Movie data/jumanji_welcome_to_the_jungle.csv")[,2:3]
j$Movie <- rep("Jumanji" ,nrow(j))

lsi <- read.csv("Movie data/love_simon.csv")[,2:3]
lsi$Movie <- rep("Love Simon" ,nrow(lsi))

paoc <- read.csv("Movie data/paul_apostle_of_christ.csv")[,2:3]
paoc$Movie <- rep("Paul Apostle of Christ" ,nrow(paoc))

pr <- read.csv("Movie data/peter_rabbit_2018.csv")[,2:3]
pr$Movie <- rep("Peter Rabbit" ,nrow(pr))

sg <- read.csv("Movie data/sherlock_gnomes.csv")[,2:3]
sg$Movie <- rep("Sherlock Gnomes" ,nrow(sg))

tdos <- read.csv("Movie data/the_death_of_stalin.csv")[,2:3]
tdos$Movie <- rep("The Death of Stalin" ,nrow(tdos))

tsow <- read.csv("Movie data/the_shape_of_water_2017.csv")[,2:3]
tsow$Movie <- rep("The Shape of Water" ,nrow(tsow))

tr <- read.csv("Movie data/tomb_raider_2018.csv")[,2:3]
tr$Movie <- rep("Tomb Raider" ,nrow(tr))

combined <- rbind(tlj, rp1, bp, awit, a, co, f, gind, j, lsi, paoc, pr, sg, tdos, tsow, tr)
combined$ID <- 1:nrow(combined)

write.csv(combined, "rottenTomatoesUserReviews.csv", row.names=FALSE)