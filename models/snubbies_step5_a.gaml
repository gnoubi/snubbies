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
		create habitats from:habitat with:[DN::int(read("DN"))]
		{
			switch(DN)
			{
				match 1 {viscosity<-viscosity_init_habitat_1; } 
				match 2 {viscosity<-viscosity_init_habitat_2; } 
				match 3 {viscosity<-viscosity_init_habitat_3; } 
				match 4 {viscosity<-viscosity_init_habitat_4; } 
				match 5 {viscosity<-viscosity_init_habitat_5; } 
			}
			switch(DN)
			{
				match 1 {security<-security_init_habitat_1; } 
				match 2 {security<-security_init_habitat_2; } 
				match 3 {security<-security_init_habitat_3; } 
				match 4 {security<-security_init_habitat_4; } 
				match 5 {security<-security_init_habitat_5; } 
			}
		} 
		create Snubby_group from:groups_file with:[id::int(read("ID")),name::string(read("NAME1")),init_population::int(read("POPULATION"))] // create the agent "groups file" with its shapefile attributes 
		{
			Snubby_group my_group <- self; //the group which the snubbies that are going to be created belongs to
			create Snubby number:init_population // create individual monkeys based on the population size in each group 
			{
				location <- any_location_in(my_group.shape); // location anywhere within the group perimeter
				origin <- my_group;
				current <- my_group;
			}
			
		}		
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

species habitats
{
	int DN;
	float viscosity;
	float security;
	aspect base
	{		
		switch (DN)
		{
				match 1 {draw shape color:rgb([0, 128, 0]); } 
				match 2 {draw shape color:rgb([0, 255,0]); } 
				match 3 {draw shape color:rgb([128, 128, 0]); } 
				match 4 {draw shape color:rgb([255, 128, 0]); } 
				match 5 {draw shape color:rgb([255, 0, 0]); } 
		}
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
		draw shape color:rgb("gray",180);
	}
}


species Snubby  skills:[moving]
{
	init {
		shape <- point(0,0);
	}
	Snubby_group origin;
	Snubby_group current <-nil;
	int origin_group_id ->{origin.id};
	int current_group_id ->{current=nil?-1:current.id};
	bool is_exploring <- false;
	rgb color <- #blue;
	
	reflex walk when: is_exploring = true
	{
		habitats local_habitat <- one_of(habitats overlapping(self.location));
		do wander speed:local_habitat.viscosity*max_snubby_speed bounds:world_boundaries_shape amplitude:60.0;
	}
	
	reflex stay when:is_exploring
	{
		list<Snubby_group> local_group <- Snubby_group overlapping(self.location);
		if(!empty(local_group))
		{
			is_exploring <- false;
			current <- one_of(local_group);
		}
		
	}
	
	reflex be_explorer when: is_exploring = false
	{
		bool explore <- flip(explorer_snubbies_hour);
		if(explore = true)
		{
			is_exploring <- true;
		}
	}
	
	reflex be_killed when:is_exploring
	{
		habitats local_habitat <- one_of(habitats overlapping(self.location));
		if(local_habitat!=nil)
		{
			float secu <- local_habitat.security;
			float probability_to_die <- local_habitat.security*max_snubby_survival_hour;
			if(flip(probability_to_die)) {
				create Snubby number:1 {
					origin <- myself.current;
					current <- myself.current;
					location <- any_location_in(current.shape);
	
				}
				do die;		
			}
			
		}
	}
			
	aspect base 
	{
		draw circle(500#m) color:origin!=current? #red:#blue;
	}
}






experiment run
{
	parameter "simulation_id" var:simulation_id;
	parameter "v_max" var:max_snubby_speed;
	parameter "s_max" var:max_snubby_survival_init;
	parameter "explorer_snubbies" var:explorer_snubbies_init;
	
	parameter "viscosity_factor_habitat_1" var:viscosity_init_habitat_1;
	parameter "viscosity_factor_habitat_2" var:viscosity_init_habitat_2;
	parameter "viscosity_factor_habitat_3" var:viscosity_init_habitat_3;
	parameter "viscosity_factor_habitat_4" var:viscosity_init_habitat_4;
	parameter "viscosity_factor_habitat_5" var:viscosity_init_habitat_5;
	parameter "security_factor_habitat_1" var:security_init_habitat_1;
	parameter "security_factor_habitat_2" var:security_init_habitat_2;
	parameter "security_factor_habitat_3" var:security_init_habitat_3;
	parameter "security_factor_habitat_4" var:security_init_habitat_4;
	parameter "security_factor_habitat_5" var:security_init_habitat_5;
	
	output
	{
		/* display color map + groups + monkeys */
		display map 
		{
			species world_boundaries aspect:base;
			species habitats aspect:base;
			species Snubby_group aspect:base;
			species Snubby aspect:base;
		}
	}
}
