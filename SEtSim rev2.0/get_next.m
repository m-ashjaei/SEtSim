function [message_id, queue] = get_next(queue, element_number)
% This function returns the next message id in the queue by defining the
% queue element number

len = length(queue);

% If the queue is empty or nothing in that
if len == 0
    message_id = 0;
    return;
end

% If the element is out of band 
if element_number > len
    message_id = 0;
    return;
end

% Get the specific element, need to use remove function after that
message_id = queue(1, element_number);

end