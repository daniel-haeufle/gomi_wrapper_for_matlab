% retrieve time series object for specific logged signal
%
% [Values, Pathname] = data_from_logsout(logsout, signalname, subsystemname)
%
% logsout is the logging signal Dataset from Simulink
% signalname is a string with the name of the signal
% subsystemname is a string with the name of the subsystem containing the
% signal, or a substring containing part of the name
%
% Values returns a timeseries object of the logged signal
% Pathname returns the sub-system-location of the block including the
% signal name
%
% typical call: [Values, Pathname] = data_from_logsout(logsout, 'WM_delta_x' , 'Shank')
%
% could be further used as
% eval([Pathname '=Values'])
% to create a variable with the name of the signal including subsystem path

% to display all available signals uncomment the following line
%data_display_logsout_signals(logsout)

function [Values, Pathname] = data_from_logsout(logsout, signalname, subsystemname)
logsout_selectedElements = logsout.getElement(signalname);
if strcmp(class(logsout_selectedElements),'Simulink.SimulationData.Signal') %#ok<STISA>
    logsout_finalElement = logsout_selectedElements;
else
    counter = 0;
    for i1 = 1:logsout_selectedElements.numElements
        if ~isempty( strfind(logsout_selectedElements.getElement(i1).BlockPath.getBlock(1) , subsystemname) )
            logsout_finalElement = logsout_selectedElements.getElement(i1);
            counter=counter+1;
        end
    end
    %counter and this if query added by Katrin
    if counter == 0
        disp(['No signal with name ',signalname,' found']);
    end
end
Pathname = logsout_finalElement.BlockPath.getBlock(1);
blockidx = strfind(logsout_finalElement.BlockPath.getBlock(1),'/');
Pathname = Pathname(blockidx(1)+1:blockidx(end)-1);
Pathname = strrep(Pathname, '/', '__');
Pathname = strrep(Pathname, ' ', '_');
Pathname = strrep(Pathname, '-', '_');
Pathname = [Pathname '__' signalname];
Values = logsout_finalElement.Values;
end

