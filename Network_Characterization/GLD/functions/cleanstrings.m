function [cleanStr] = cleanStrings(thisStr)
            
    keep_indices = [strfind(thisStr,'e-')+1 strfind(thisStr,'e+')+1];
    throw_indices = [strfind(thisStr,'-') strfind(thisStr,'+')];

    %only remove and replace with blanks the unique in both lists
    totIndex = [keep_indices throw_indices];
    uniqueIndex = unique(totIndex);
    count = histc(totIndex,uniqueIndex);
    indices = uniqueIndex(count == 1);
    thisStr(indices) = ' ';
    cleanStr = thisStr;
    
end 