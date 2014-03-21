%---------------------------------------------------------------------
% Copyright 2013 Mohammad Ashjaei <mohammad.ashjaei@mdh.se>
% This code is written in order to simulate switched Ethernet protocols.
%---------------------------------------------------------------------

% remove a specific data from a queue
function queue = remove_msg(queue, msg)

len = length(queue);

cell = find(queue == msg);
for i = cell:len - 1
    queue(1,i) = queue(1, i+1);
end
queue(1, len) = 0;