/***
* Name: snubbies
* Author: Patrick Giraudou and Nicolas Marilleau 
***/

model snubbies

global
{
	file groups_file <- file("../includes/groups/groups.shp"); // read the shapefile of the groups
	file habitat <- file("../includes/source2P/source2P.shp"); // read the shapefile of the habitats
	file world_enveloppe <- file("../includes/source2P_envconc/source2P_envconc.shp");

	float max_snubby_speed <-30#km/#day;
	float max_snubby_survival_init <- 0.5;
	float max_snubby_survival_hour <- 0.0;

	float viscosity_init_habitat_1 <- 0.9;
	float viscosity_init_habitat_2 <- 0.7;
	float viscosity_init_habitat_3 <- 0.5;
	float viscosity_init_habitat_4 <- 0.2;
	float viscosity_init_habitat_5 <- 0.1;
	
	float security_init_habitat_1 <- 1.0;
	float security_init_habitat_2 <- 0.9;
	float security_init_habitat_3 <- 0.5;
	float security_init_habitat_4 <- 0.1;
	float security_init_habitat_5 <- 0.0;

	float explorer_snubbies_init <- 0.1; //0.01;
	float explorer_snubbies_hour<- 0.0;
	
	int simulation_id <- rnd(1000);
	
	geometry shape<- envelope(world_enveloppe); // define the area under study (universe)
	date starting_date <- date([2018,11,6,0,0,0]);
	geometry world_boundaries_shape;

	
	init
	{
		step <- 1 #hour;
		max_snubby_survival_hour<- convert_probability_from_year_to_hour(max_snubby_survival_init);
		explorer_snubbies_hour <- convert_probability_from_year_to_hour(explorer_snubbies_init);
		create world_boundaries from: world_enveloppe
		{}
		world_boundaries_shape <- first(world_boundaries).shape;				
	}
	
	float convert_probability_from_year_to_hour(float value)
	{
		return value/8760; //365*24
	}
}

species world_boundaries
{
	aspect base
	{
		draw shape color:#black;
	}
}


experiment run
{
	parameter "simulation_id" var:simulation_id;
	
	output
	{
		/* display color map + groups + monkeys */
		display map 
		{
			species world_boundaries aspect:base;
		}
	}
}
