function read_matrix = sampleMatReader(filename) 
    inp = load(filename);
    read_matrix = inp.images;
end