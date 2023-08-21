clear all;
load TG119_super.mat

%% Set Optimization

cst(:,6) = [];

%Core
cst{1, 6}{1} = DoseObjectives.matRad_SquaredOverdosing(100, 20);
%cst{2, 6}{2}=DoseConstraints.matRad_MinMaxDose(0, 30, 2, 100);

%Target
cst{2, 6}{1} = DoseObjectives.matRad_SquaredDeviation(1000, 60);
cst{2, 6}{2} = DoseConstraints.matRad_MinMaxDose(59, 61, 1, 1000);

%Body
cst{3, 6}{1} = DoseObjectives.matRad_SquaredOverdosing(30, 30);
%cst{1, 6}{1}=DoseConstraints.matRad_MinMaxDose(0, 20, 1, 0.9);


%% IPOPT
opti = matRad_OptimizerIPOPT;
opti.options.max_iter = 1000;
opti.options.max_cpu_time = 3600;
opti.options.dual_inf_tol              = 1e-2; % (Opt2)
opti.options.constr_viol_tol           = 1e-2; % (Opt3)
opti.options.acceptable_iter           = 5;    % (Acc1)
opti.options.acceptable_tol            = 1e10; % (Acc2) %The scale of our objective function is variable, so we relax this tolerance
opti.options.acceptable_obj_change_tol = 1e-4; % (Acc6), Solved To Acceptable Level if (Acc1),...,(Acc6) fullfiled

pln.propOpt.optimizer = opti;

tic;
resultGUI = matRad_fluenceOptimization(dij,cst,pln);
time = toc;

%% Super AMS_sim
opti = matRad_OptimizerSuperization;
opti.feasibility_seeker = "AMS_sequential";
opti.max_iter = 1000;
opti.max_time = 3600;
opti.lambda = 1.5;
opti.weighted = true;
opti.control_sequence = 'weight';
opti.weight_decay = 1;
opti.warm_start = true;
pln.propOpt.optimizer = opti;


tic;
resultGUI_super = matRad_fluenceOptimization(dij,cst,pln);
time = toc;


%% Plot IPOPT

hfPlan = figure; 
hfPlan.WindowState = 'Maximized';
axIpoptPlan = subplot(2,2,1);
title('IPOPT plan');
matRad_plotSliceWrapper(gca,ct,cst,1,resultGUI.physicalDose,plane,slice,[],0.75,[],[],doseWindow,[],[],[],[],'LineWidth',2);
xlim([30 138]);
ylim([55 115]);

usedOpt = resultGUI.usedOptimizer;

hFvals = figure;
hFvals.WindowState = 'Maximized';
%title('Convergence');
subplot(2,2,1);plot(0:numel(usedOpt.allObjectiveFunctionValues)-1,usedOpt.allObjectiveFunctionValues,'x'); xlabel('# Iteration'); ylabel('Obj. Function'); grid('minor'); set(gca,'YScale','log'); hold on;
subplot(2,2,2);plot(usedOpt.timeIter,usedOpt.allObjectiveFunctionValues,'x'); xlabel('Time [s]'); ylabel('Obj. Function'); grid('minor'); set(gca,'YScale','log'); hold on;
subplot(2,2,3);plot(0:numel(usedOpt.allConstraintViolations)-1,usedOpt.allConstraintViolations,'x'); xlabel('# Iteration'); ylabel('Constr. Violation'); grid('minor'); hold on;
subplot(2,2,4);plot(usedOpt.timeIter,usedOpt.allConstraintViolations,'x'); xlabel('Time [s]'); ylabel('Constr. Violation'); grid('minor'); hold on;

%% Plot AMS

figure(hfPlan);

axSuperPlan = subplot(2,2,2);
title('Superiorized plan');
matRad_plotSliceWrapper(gca,ct,cst,1,resultGUI_super.physicalDose,plane,slice,[],0.75,[],[],doseWindow,[],[],[],[],'LineWidth',2);
xlim([30 138]);
ylim([55 115]);


usedOpt = resultGUI_super.usedOptimizer;

figure(hFvals);
legEntries = {'IPOPT','Superiorization'};
axObjVsIter  = subplot(2,2,1); plot(0:numel(usedOpt.allObjectiveFunctionValues)-1,usedOpt.allObjectiveFunctionValues,'x');  legend(legEntries); 
axObjVsTime  = subplot(2,2,2); plot(usedOpt.timeIter,usedOpt.allObjectiveFunctionValues,'x');                               legend(legEntries);
axViolVsIter = subplot(2,2,3) ;plot(0:numel(usedOpt.allConstraintViolations)-1,usedOpt.allConstraintViolations,'x');        legend(legEntries);
axViolVsTime = subplot(2,2,4); plot(usedOpt.timeIter,usedOpt.allConstraintViolations,'x');                                  legend(legEntries); 

%% 


absDiffCube = resultGUI.physicalDose-resultGUI_super.physicalDose;

diffMax = max(abs(absDiffCube(:)));
diffWindow = [-diffMax diffMax];

figure(hfPlan);
axDiffPlan = subplot(2,2,3);
title('IPOPT plan - Sup. Plan');
matRad_plotSliceWrapper(gca,ct,cst,1,absDiffCube,plane,slice,[],0.75,[],diffMap,diffWindow,[],[],[],[],'LineWidth',2);
xlim([30 138]);
ylim([55 115]);



%% Obtain dose statistics
% Two more columns will be added to the cst structure depicting the DVH and
% standard dose statistics such as D95,D98, mean dose, max dose etc.
[dvh,qi]               = matRad_indicatorWrapper(cst,pln,resultGUI);
[dvh_super,qi_super] = matRad_indicatorWrapper(cst,pln,resultGUI_super);

%% Show DVHs
figure(hfPlan);
axDVHs = subplot(2,2,4);
title('DVHs');
matRad_showDVH(dvh,cst,pln,1)
hold on
matRad_showDVH(dvh_super,cst,pln,2)

names1 = cellfun(@(c) sprintf('%s - IPOPT',c),cst(:,2),'UniformOutput',false);
names2 = cellfun(@(c) sprintf('%s - Sup.',c),cst(:,2),'UniformOutput',false);

allNames = [names1 names2];

legend(allNames{:},'Location','NorthOutside','NumColumns',2);

%%
exportgraphics(hfPlan,'super_script1_plan.png');
exportgraphics(hFvals,'super_script1_vals.png');

exportgraphics(axObjVsIter,'super_script1_objVsIter.png');
exportgraphics(axObjVsTime,'super_script1_objVsTime.png');
exportgraphics(axViolVsIter,'super_script1_violVsIter.png');
exportgraphics(axViolVsTime,'super_script1_violVsTime.png');

exportgraphics(axSuperPlan,'super_script1_superPlan.png');
exportgraphics(axIpoptPlan,'super_script1_ipoptPlan.png');
exportgraphics(axDiffPlan,'super_script1_diffPlan.png');
exportgraphics(axDVHs,'super_script1_dvhs.png');

%%
close all;
save('super_script1.mat');

%%
hfPlan = figure;
usedOpt = resultGUI.usedOptimizer;
semilogy(0:numel(usedOpt.allObjectiveFunctionValues)-1,usedOpt.allObjectiveFunctionValues,'x'); hold on;
usedOpt = resultGUI_super.usedOptimizer;
semilogy(0:numel(usedOpt.allObjectiveFunctionValues)-1,usedOpt.allObjectiveFunctionValues,'x'); 
grid minor;
xlabel('#Iterations');
ylabel('Objective function value');
legend({'Optimization','Superiorization'});
cleanfigure; matlab2tikz('super_script_1_objvsiter.tikz','showInfo',true,'width','\figurewidth','height','\figureheight');

%%
hfPlan = figure;
usedOpt = resultGUI.usedOptimizer;
semilogy(usedOpt.timeIter,usedOpt.allObjectiveFunctionValues,'x'); hold on;
usedOpt = resultGUI_super.usedOptimizer;
semilogy(usedOpt.timeIter,usedOpt.allObjectiveFunctionValues,'x'); 
grid minor;
xlabel('time [s]');
ylabel('Objective function value');
legend({'Optimization','Superiorization'})
cleanfigure; matlab2tikz('super_script_1_objvstime.tikz','showInfo',true,'width','\figurewidth','height','\figureheight');

%%
hfPlan = figure;
usedOpt = resultGUI.usedOptimizer;
plot(0:numel(usedOpt.allConstraintViolations)-1,usedOpt.allConstraintViolations,'x'); hold on;
usedOpt = resultGUI_super.usedOptimizer;
plot(0:numel(usedOpt.allConstraintViolations)-1,usedOpt.allConstraintViolations,'x'); 
grid minor;
xlabel('#Iterations');
ylabel('Constraint violation');
legend({'Optimization','Superiorization'});
cleanfigure; matlab2tikz('super_script_1_constrvsiter.tikz','showInfo',true,'width','\figurewidth','height','\figureheight');

%%
hfPlan = figure;
usedOpt = resultGUI.usedOptimizer;
plot(usedOpt.timeIter,usedOpt.allConstraintViolations,'x'); hold on;
usedOpt = resultGUI_super.usedOptimizer;
plot(usedOpt.timeIter,usedOpt.allConstraintViolations,'x'); 
grid minor;
xlabel('time [s]');
ylabel('Constraint violation');
legend({'Optimization','Superiorization'})
cleanfigure; matlab2tikz('super_script_1_constrvstime.tikz','showInfo',true,'width','\figurewidth','height','\figureheight');
