% this function lists all logged signals and their respective sub-system
% block path

function data_display_logsout_signals(logsout)

for i1 = 1:logsout.numElements
    SelectElement = logsout.getElement(i1);
    Pathname = SelectElement.BlockPath.getBlock(1);
    blockidx = strfind(Pathname,'/');
    Pathname = Pathname(blockidx(1)+1:blockidx(end)-1);
    disp([ logsout.getElement(i1).Name ' : ' Pathname])
end
end

