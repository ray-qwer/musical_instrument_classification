function [lists,loc] = getInstrumentFile(name,cur)
    listing = dir(cur);
    loc = cur;
    if length(listing) <= 2
        lists = [];
        return;
    else
        for i = 3:length(listing)
            if(listing(i).name == name & listing(i).isdir)
                loc = cur+"\"+listing(i).name;
                lists = dir(loc);
                lists(2) = []; lists(1) = [];
                return;
            elseif listing(i).isdir
                loc = cur+"\"+listing(i).name;
                [lists,loc] = getInstrumentFile(name, loc);
                if ~isempty(lists)
                    return;
                end
            else
                lists = [];
            end
        end
    end
end