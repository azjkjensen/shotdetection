function fileListCell = getFileListing(fldr,ext)

tmp = dir(fullfile(fldr,['*.' ext]));
if isempty(tmp)
    fileListCell = []; 
    tmpListing = dir(fldr);
    for i = 1 : length(tmpListing)
        if (tmpListing(i).isdir) && ...
           (~strcmp(tmpListing(i).name, '.')) && ...
           (~strcmp(tmpListing(i).name, '..'))
            subfldr = tmpListing(i).name;     
            tmpp = dir(fullfile(fldr,subfldr,['*.' ext]));
            tmpCell = cell(length(tmpp),1);
            for j = 1 : length(tmpp)
                tmpCell{j} = tmpp(j).name;
                tmpCell{j} = fullfile(fldr, subfldr, tmpCell{j});
            end 
           % tmpCell = fullfile(fldr,subfldr,char(tmpCell));
            fileListCell = [fileListCell;tmpCell];
        end
        
    end
else

    
fileListCell = cell(length(tmp),1);
for i = 1 : length(tmp) 
    fileListCell{i} = fullfile(fldr,tmp(i).name); 
end



end