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
	float max_snubby_speed <-30#km/#day;
	float max_snubby_survival_init <- 0.5;
	float max_snubby_survival_hour <- 0.0;

	float viscosity_init_habitat_1 <- 1.0;
	float viscosity_init_habitat_2 <- 0.9;
	float viscosity_init_habitat_3 <- 0.5;
	float viscosity_init_habitat_4 <- 0.1;
	float viscosity_init_habitat_5 <- 0.0;
	
	float security_init_habitat_1 <- 1.0;
	float security_init_habitat_2 <- 0.9;
	float security_init_habitat_3 <- 0.5;
	float security_init_habitat_4 <- 0.1;
	float security_init_habitat_5 <- 0.0;

	float explorer_snubbies_init <- 0.01;
	float explorer_snubbies_hour<- 0.0;
	
	
	geometry shape<- envelope(habitat); // define the area under study (universe)
	init
	{
		step <- 1#hour;
		max_snubby_survival_hour<- convert_probability_from_year_to_hour(max_snubby_survival_init);
		explorer_snubbies_hour <- convert_probability_from_year_to_hour(explorer_snubbies_init);
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
				 shape <- circle(	500#m);
	
			}
		}
		
		
	}
	
	
	
	/* save a shapefile of the snubbies into the folder outputs*/
	reflex save_snubbies when:every(1#year ) and cycle!=0
	{
		write "../outputs/snubbies_"+current_date.year+"_"+cycle+".shp";
//	save Snubby  attributes: ["name"::name,"origin"::origin_group_id,"current"::current_group_id]  to:"../outputs/snubbies_"+current_date.year+"_"+cycle+".shp" type:"shp";
	}
	
	/* save a summary of group composition into the folder outputs*/
	reflex save_groups when:every(1#year ) and cycle!=0
	{
		list<int> line<-[];
		
		ask Snubby_group
		{
			Snubby_group me <- self;
			list<int> line<- [];
			ask Snubby_group
			{
				line <- line + Snubby count(each.current = self and each.origin=me);
			}
			save line    to:"../outputs/population_"+current_date.year+"_"+cycle+".shp" type:"shp" rewrite: false;
			
		}
	}
	
	float convert_probability_from_year_to_hour(float value)
	{
		return exp( ln(value)/8760); //365*24
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
		//draw shape color:#gray;
		draw shape color:rgb("gray",180);
	}
}

species Snubby skills:[moving]
{
	Snubby_group origin;
	Snubby_group current <-nil;
	int origin_group_id ->{origin.id};
	int current_group_id ->{current=nil?-1:current.id};
	float my_speed;
	reflex walk
	{
		do wander speed:max_snubby_speed amplitude:60.0;
	}
	
	aspect base 
	{
		draw circle(500#m) color:#blue;
	}
}




experiment run
{
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
//		display map //type:opengl // draw the maps
//		{
//			species habitats aspect:base;
//			species Snubby_group aspect:base;
//			species Snubby aspect:base;
//		}

		/* display groups + monkeys only*/
		display reading_map //type:gui // draw the maps
		{
			species Snubby_group aspect:base;
			species Snubby aspect:base;
		}

	}
}
