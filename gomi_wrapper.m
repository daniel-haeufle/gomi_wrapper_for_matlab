function [MC_discrete_mean, MC_discrete, MC_cont_mean, MC_cont] = gomi_wrapper(world, actuation)

data_for_MC = [world actuation];

%% wrapper to call gomi:

world_idx = '0';
if size(world,2)>1
    for i_w = 2:size(world,2)
        world_idx = [world_idx ',' num2str(i_w-1)];
    end
end

act_idx = num2str(i_w);
if size(actuation,2)>1
    for i_a = 2:size(actuation,2)
        act_idx = [act_idx ',' num2str(i_w+i_a-1)];
    end
end
%%

%
MC_bins_param = '300'; % number of bins for discrete MC
MC_k_param = '100'; % number of considered neibouring values for continuous MC
data_file = 'data_file.csv'; %define filename to transfer data to gomi

csvwrite(data_file,data_for_MC) % write file to load with gomi

% continuous:
system(['./gomi -file ' data_file ' -wi ' world_idx ' -ai ' act_idx ' -c -k ' MC_k_param ' -s -mi MI_W -o data_file_MC_out_cont.csv -v']);

MC_cont = gomi_wrapper_import_MC_CSV_file('data_file_MC_out_cont.csv'); %reimport MC data
MC_cont_mean = mean(MC_cont);

% discrete:
system(['./gomi -mi MI_W -wi ' world_idx ' -ai ' act_idx ' -sparse -s -bins ' MC_bins_param ' -file ' data_file ' -o data_file_MC_out_discr.csv -v']);

MC_discrete = gomi_wrapper_import_MC_CSV_file('data_file_MC_out_discr.csv'); %reimport MC data
MC_discrete_mean = mean(MC_discrete);

delete data_file_MC_out_cont.csv
delete data_file_MC_out_discr.csv
delete data_file.csv

