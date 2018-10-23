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
	file groups_file <- file("../includes/groups/groups.shp");
	file habitat <- file("../includes/source2P/source2P.shp");
	float mean_snubby_speed <- 50#km/#day;
	
	
	geometry shape<- envelope(habitat);
	init
	{
		create habitats from:habitat with:[DN::int(read("DN"))];
		step <- 1#day;
		create Snubby_group from:groups_file with:[id::int(read("ID")),name::string(read("NAME1")),init_population::int(read("POPULATION"))]
		{
			Snubby_group my_group <- self; //the group which the snubbies that are going to be created belongs to
			
			create Snubby number:init_population
			{
				location <- any_location_in(my_group.shape);
			}
		}
		
		
	}
}


species habitats
{
	int DN;
	aspect base
	{
		draw shape color:#gray;
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
		draw shape color:#gray;
	}
}

species Snubby skills:[moving]
{
	Snubby_group origin;
	Snubby_group current <-nil;
	float my_speed;
	
	aspect base 
	{
		draw circle(500#m) color:#red;
	}
}


experiment run
{
	output
	{
		display map type:opengl
		{
			species habitats aspect:base;
			species Snubby_group aspect:base;
			species Snubby aspect:base;
		}
		

	}
}
