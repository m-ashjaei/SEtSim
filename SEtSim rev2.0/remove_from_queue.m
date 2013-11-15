function [queue] = remove_from_queue(queue, message_id)
% This function remove a message from a queue and re-sort the queue again
% based on the priority

len = length(queue);

% If the queue is empty, nothing to remove, return
if len == 0
    return;
end

% Find the message in the queue and remove that, re-order the queue then
cell = find(queue == message_id);
for i = cell:len - 1
    queue(1,i) = queue(1, i+1);
end
queue(1, len) = 0;

end