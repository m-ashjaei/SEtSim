%---------------------------------------------------------------------
% Copyright 2013 Mohammad Ashjaei <mohammad.ashjaei@mdh.se>
% This code is written in order to simulate switched Ethernet protocols.
%---------------------------------------------------------------------

% defragmentation of large messages

function [frag_msg_nbr, fragment_message] = msg_defragment(message, message_nbr)

for ms = 1:message_nbr
    % local messages should not bigger than 160 microseconds
    if message(ms).gType == 0
        if message(ms).exec >= 0.016
            message(ms).defNum = ceil(message(ms).exec / 0.010);
        end
    % global messages should not bigger than 160 microseconds
    elseif message(ms).gType == 1
        if message(ms).exec >= 0.016
            message(ms).defNum = ceil(message(ms).exec / 0.005);
        end
    end
end

% update the message structure based on defragmentation
col = 0;
for ms = 1:message_nbr
    if message(ms).defNum > 0
        partCount = 0;
        for i = 1:message(ms).defNum
            partCount = partCount + 1;
            fragment_message(col + i) = message(ms); 
            fragment_message(col + i).exec = message(ms).exec / message(ms).defNum;
            fragment_message(col + i).id = col + i;
            fragment_message(col + i).part = partCount;
        end
        col = col + message(ms).defNum;
    elseif message(ms).defNum == 0
        fragment_message(col + 1) = message(ms); 
        fragment_message(col + 1).id = col + 1;
        col = col + 1;
    end
end

frag_msg_nbr = col;
end