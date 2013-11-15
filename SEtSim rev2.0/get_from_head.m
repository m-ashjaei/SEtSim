function [message_id, queue] = get_from_head(queue)
% This function returns the message id which is in the head of the queue

len = length(queue);

% If the queue is empty or nothing in that
if len == 0
    message_id = 0;
    return;
end

% Get the first one and re-order the others
message_id = queue(1, 1);

end

