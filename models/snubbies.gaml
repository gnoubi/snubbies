/***
* Name: snubbies
* Author: nicolas
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model snubbies

/* Insert your model definition here */



global
{
	file groups_file <- file("../includes/groups/groups.shp"); // read the shapefile of the groups
	file habitat <- file("../includes/source2P/source2P.shp"); // read the shapefile of the habitats
	float mean_snubby_speed <- 50#km/#day; // mean spread of a travelling monkey per day
	
	
	geometry shape<- envelope(habitat); // define the area under study (universe)
	init
	{
		create habitats from:habitat with:[DN::int(read("DN"))]; // create the agent "habitats" with its shapefile attribute 
		step <- 1#day; // model step; one iteration is one day
		create Snubby_group from:groups_file with:[id::int(read("ID")),name::string(read("NAME1")),init_population::int(read("POPULATION"))] // create the agent "groups file" with its shapefile attributes 
		{
			Snubby_group my_group <- self; //the group which the snubbies that are going to be created belongs to
			
			create Snubby number:init_population // create individual monkeys based on the population size in each group 
			{
				location <- any_location_in(my_group.shape); // location anywhere within the group perimeter
			}
		}
		
		
	}
}


species habitats
{
	int DN;
	aspect base
	{
		// draw shape color:#gray;
		// draw shape color:DN=1 ? #green : (DN=2 ? #blue : (DN=3 ? #yellow :  (DN=4 ? #orange :  #red)));
		draw shape color:DN=1 ? rgb([0, 128, 0]) : (DN=2 ? rgb([0, 255,0]) : (DN=3 ? rgb([128, 128, 0]) :  (DN=4 ? rgb([255, 128, 0]) :  rgb([255, 0, 0]))));
	}
}



species Snubby_group
{
	int id;
	string name;
	int init_population;
	int current_population;
	
	aspect base
	{
		//draw shape color:#gray;
		draw shape color:rgb("gray",180);
	}
}

species Snubby skills:[moving]
{
	Snubby_group origin;
	Snubby_group current <-nil;
	float my_speed;
	
	aspect base 
	{
		draw circle(100#m) color:#blue;
	}
}


experiment run
{
	output
	{
		display map type:opengl // draw the maps
		{
			species habitats aspect:base;
			species Snubby_group aspect:base;
			species Snubby aspect:base;
		}
		

	}
}
