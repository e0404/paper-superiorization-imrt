load HEAD_AND_NECK.mat

pln.radiationMode = 'photons';  
pln.machine       = 'Generic';
pln.propOpt.bioOptimization = 'none';    
pln.numOfFractions         = 1;
pln.propStf.gantryAngles   = [0:360/7:359];
%pln.propStf.gantryAngles   = [0];
pln.propStf.couchAngles    = zeros(1, numel(pln.propStf.gantryAngles));
pln.propStf.bixelWidth     = 5;
pln.propStf.numOfBeams      = numel(pln.propStf.gantryAngles);
pln.propStf.isoCenter       = ones(pln.propStf.numOfBeams,1) * matRad_getIsoCenter(cst,ct,0);


pln.propDoseCalc.doseGrid.resolution.x = 3; % [mm]
pln.propDoseCalc.doseGrid.resolution.y = 3; % [mm]
pln.propDoseCalc.doseGrid.resolution.z = 3; % [mm]

%pln.propDoseCalc.doseGrid.resolution = ct.resolution;
pln.propOpt.runSequencing = 0;
pln.propOpt.runDAO        = 0;
stf                      = matRad_generateStf(ct,cst,pln);


dij = matRad_calcPhotonDose(ct,stf,pln,cst);

save HEAD_AND_NECK_super.mat