devtools::install_github("choisy/gamar")
library(gamar)
defpath("/Applications/Gama17.app")
# Extract the model parameters from the definition of the model sir.gaml
experiment1 <- getmodelparameter("/Users/nicolas/git/snubbies/models/snubbies.gaml","run")


simulation_duration <- 24 #  24 hours

B<-2 # number of simulations

simuls<-data.frame(
  v_max=0.3472222,
  s_max=0.5,
  explorer_snubbies=runif(B,0.001,0.1),
  viscosity_factor_habitat_1=1,
  viscosity_factor_habitat_2=0.9,
  viscosity_factor_habitat_3=0.5,
  viscosity_factor_habitat_4=0.1,
  viscosit_factor_habitat_5=0,
  security_factor_habitat_1=1,
  security_factor_habitat_2=0.9,
  security_factor_habitat_3=0.5,
  security_factor_habitat_4=0.1,
  security_factor_habitat_5=0
)
i <- 0

for (i in 1:nrow(simuls))
{
  local_experiment <- experiment1
  local_experiment <-  setparametervalue(local_experiment,"max_snubby_speed",simuls[i,"v_max"])
  local_experiment <-  setparametervalue(local_experiment,"max_snubby_survival_init",simuls[i,"s_max"])
  local_experiment <-  setparametervalue(local_experiment,"explorer_snubbies_init",simuls[i,"explorer_snubbies"])
  local_experiment <-  setparametervalue(local_experiment," viscosity_init_habitat_1",simuls[i,"viscosity_factor_habitat_1"])
  local_experiment <-  setparametervalue(local_experiment," viscosity_init_habitat_2",simuls[i,"viscosity_factor_habitat_2"])
  local_experiment <-  setparametervalue(local_experiment," viscosity_init_habitat_3",simuls[i,"viscosity_factor_habitat_3"])
  local_experiment <-  setparametervalue(local_experiment," viscosity_init_habitat_4",simuls[i,"viscosity_factor_habitat_4"])
  local_experiment <-  setparametervalue(local_experiment," viscosity_init_habitat_5",simuls[i,"viscosity_factor_habitat_5"])
  local_experiment <-  setparametervalue(local_experiment," security_init_habitat_1",simuls[i,"security_factor_habitat_1"])
  local_experiment <-  setparametervalue(local_experiment," security_init_habitat_2",simuls[i,"security_factor_habitat_2"])
  local_experiment <-  setparametervalue(local_experiment," security_init_habitat_3",simuls[i,"security_factor_habitat_3"])
  local_experiment <-  setparametervalue(local_experiment," security_init_habitat_4",simuls[i,"security_factor_habitat_4"])
  local_experiment <-  setparametervalue(local_experiment," security_init_habitat_5",simuls[i,"security_factor_habitat_5"])

  local_experiment <- setfinalstep(local_experiment,simulation_duration)
  
  local_experiment <- setoutputframerate(local_experiment,"map",10)
  local_experiment <- setoutputframerate(local_experiment,"reading_map",10)
  local_experiment <- setsimulationid(local_experiment,i)

  local_experiment <- setseed(local_experiment,1)

  if(i<2)
  {

    experimentplan <- addtoexperimentplan(simulation = local_experiment)
  }
  else
  {
    experimentplan <- addtoexperimentplan(simulation = local_experiment,experimentplan = experimentplan)
  }
  outFile <- paste0("./input_",formatC(i,width=nchar(nrow(simuls)),flag="0"),".xml")

  writemodelparameterfile(experimentplan,outFile)
}

runexpplan(experimentplan,hpc=2)

