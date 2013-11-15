function [queue] = insert_to_ascend(queue, message_id)
% This function insert a message in a queue and sort the queue ascending
% based on the priority

global msg;

len = length(queue);
% If the queue is empty, put the message at the begining
if len == 0
    queue(1,1) = message_id;
    return;
end

% extract the priority of input message
message_prio = msg(message_id).prio;

%trace all elements of the queue
for i = 1:len
    id = queue(1, i);
    
    %if the element is empty
    if id == 0
        queue(1, i) = message_id;
        return;
    end
    
    %find the priority of message
    prio = msg(id).prio;
    
    %if the priority of message is less than the one in the queue, insert
    %the message after that in the queue
    if message_prio < prio
        if len == i
            queue(1, len+1) = queue(1, len);
            queue(1, len) = message_id;
        else
            for j = len:-1:i
                queue(1,j+1) = queue(1, j);
            end
            queue(1,i) = message_id;
        end
        return;
    end
end

%all the queue is checked, still the message is not inserted
queue(1, len+1) = message_id;

end