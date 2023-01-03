listing = dir('..\music_samples');
if length(listing) <= 2
    return;
end
[lists,loc] = getInstrumentFile("horn","..");

