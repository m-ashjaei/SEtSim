%---------------------------------------------------------------------
% Copyright 2013 Mohammad Ashjaei <mohammad.ashjaei@mdh.se>
% This code is written in order to simulate switched Ethernet protocols.
%---------------------------------------------------------------------


% This function insert a data in a queue
function queue = insert(queue, data)

len = length(queue);
for j=1:len
    id = queue(1,j);
    if id == 0
        queue(1,j) = data;
        return;
    end
end
queue(1, len+1) = data;