clear
%% load file of interest and extract relevant data

input_filename = 'Ataro paper movements/1_4_2019-09-24_15-55_measured_torque';
load([input_filename '.mat'], 'logsout')

joint_angle_Shoulder = data_from_logsout(logsout, 'joint_angle', 'Shoulder');
joint_angle_Elbow = data_from_logsout(logsout, 'joint_angle', 'Elbow');

load([input_filename '.mat'], 'joint_torque_Elbow')
load([input_filename '.mat'], 'joint_torque_Shoulder')

constant_signal.Data = zeros(length(joint_angle_Elbow.Data),1);
constant_signal.Time = joint_angle_Elbow.Time;

interpolated = 1;

[joint_angle_Elbow,~] = Cut_and_interpolate_signal(joint_angle_Elbow,interpolated);
[joint_angle_Shoulder,~] = Cut_and_interpolate_signal(joint_angle_Shoulder,interpolated);
[joint_torque_Elbow,~] = Cut_and_interpolate_signal(joint_torque_Elbow,interpolated);
[joint_torque_Shoulder,~] = Cut_and_interpolate_signal(joint_torque_Shoulder,interpolated);
[constant_signal,time_vec] = Cut_and_interpolate_signal(constant_signal,interpolated);

muscles = {'biart_extensor','biart_flexor','Elbow_extensor','Elbow_flexor','Shoulder_Anteversion','Shoulder_Retroversion'};
signals = {'u_open','u_closed','u_total','lambda','l_MTU','dot_l_MTU','l_CE','F_CE','F_SEE','F_MTU','activation'};

for i_muscle = 1:length(muscles)
    for i_signal = 1:length(signals)
        selectmuscle = muscles{i_muscle};
        selectsignal = signals{i_signal};
        eval(['[',selectsignal,'_tmp, ~] = data_from_logsout(logsout, selectsignal , selectmuscle);']);
        eval(['[',selectsignal,'(:,i_muscle), time_vec] = Cut_and_interpolate_signal(',selectsignal,'_tmp,interpolated);']);
        clear([selectsignal,'_tmp']);
    end
end

%% write data in cell array
signal_cell{1,1} = 'u^{central}';
signal_cell{1,2} = u_open(:,1); %just select one u_open chanel to represent the EP input
signal_cell{2,1} = 'u^{top-down}';
signal_cell{2,2} = [u_open lambda];
signal_cell{3,1} = 'u';
signal_cell{3,2} = u_total;
signal_cell{4,1} = 'a';
signal_cell{4,2} = activation;
signal_cell{5,1} = 'F^{CE}';
signal_cell{5,2} = F_CE;
signal_cell{6,1} = 'F^{MTU}';
signal_cell{6,2} = F_MTU;
signal_cell{7,1} = 'T';
signal_cell{7,2} = [transpose(joint_torque_Elbow) transpose(joint_torque_Shoulder)];
signal_cell{8,1} = 'q';
signal_cell{8,2} = [transpose(joint_angle_Elbow) transpose(joint_angle_Shoulder)];



%% prepare data for gomi wrapper:
% This is the central step in preparing data: generate two arrays with the
% same number of lines (time steps). The first contains all signals that
% relate to the control (actuation). The second contains the world state of
% the system:

select_level = 4;
actuation = horzcat(signal_cell{1:select_level,2});
world = horzcat(signal_cell{select_level+1:end,2});


%% call wrapper
% in this step, MC is calculated by calling the wrapper function:
[MC_result.discrete_mean, MC_result.discrete, MC_result.cont_mean, MC_result.cont] = gomi_wrapper(world,actuation);

%% plot results

Plot_results(time_vec, world, actuation,MC_result);


%% helper functions for preparing the data (only relevant for this example).

function [signal_out,time_vec_interp] = Cut_and_interpolate_signal(signal_in,interpolated)
%only use the time points for t<1s
data_window = find(signal_in.Time>=0.3 & signal_in.Time<=1.1); %in accordance with the data in 'Ataro paper movements variations', where the data where shifted by 0.3s and cut off after 0.8s simulation time
data_window(end+1)=data_window(end)+1; %to include the next value above 1.1
signal_out = signal_in.Data(data_window);
time_vec = signal_in.Time(data_window)-0.3;

if interpolated
    %interpolate to get equidistant points
    time_vec_interp = time_vec(1):0.001:0.8; %time_vec(end); %in accordance with the data in 'Ataro paper movements variations', where the data where shifted by 0.3s and cut off after 0.8s simulation time
    signal_out = interp1(time_vec,signal_out,time_vec_interp);
    
end
end


function Plot_results(time_vec, world, actuation,MC_result)
%% normalize the data
for i = 1:size(world,2)
    world(:,i) = (world(:,i)-world(1,i))/max(abs(world(:,i)-world(1,i)));
end
for i = 1:size(actuation,2)
    actuation(:,i) = (actuation(:,i)-actuation(1,i))/max(abs(actuation(:,i)-actuation(1,i)));
end


%% plot the data
% set format settings for figures
fontsizefigures = 15;
linewidthfigures = 2;

figure('DefaultAxesFontSize',fontsizefigures,'DefaultLineLineWidth',linewidthfigures);
subplot 311; hold all; subplot 312; hold all; subplot 313; hold all
subplot 312
title('World');
plot(time_vec, world)
subplot 313
title('Actuation');
plot(time_vec, actuation)
subplot 311
plot(time_vec(1:end-1) , MC_result.discrete)
plot(time_vec(1:end-1) , MC_result.cont, '--')
title(['MCdiscr = ' num2str(MC_result.discrete_mean) ' MCcont = ' num2str(MC_result.cont_mean)])
end
