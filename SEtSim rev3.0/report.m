%---------------------------------------------------------------------
% Copyright 2013 Mohammad Ashjaei <mohammad.ashjaei@mdh.se>
% This code is written in order to simulate switched Ethernet protocols.
%---------------------------------------------------------------------

% this m file make a report from the simulator
% it should be run after simulator

global slave_number;
global master;
global switch_number;
global message_nbr;
global non_frag_msg;
global msg;
global avb_set;

global node_number;
global avb_number;

% report the minimum, maximum and average of end-to-end delay for all
% messages
global ready_time_buffer;
global receive_time_buffer;

if avb_set == 1
    fprintf('number of nodes: %i \n', node_number);
    fprintf('number of AVB switches: %i \n', avb_number);
       
    for msg_nbr = 1:message_nbr
        delay = 0;
        for j = 1:length(receive_time_buffer{msg_nbr})
            delay(j) = receive_time_buffer{msg_nbr}(j) - ready_time_buffer{msg_nbr}(j);
        end
        min_delay = min(delay);
        max_delay = max(delay);
        mean_delay = mean(delay);
        if mean_delay > 0
            fprintf('message %i RT: min %4.0f avg %4.0f max %4.0f \n', msg(msg_nbr).id, min_delay * 10000, mean_delay * 10000, max_delay * 10000); 
        else
            fprintf('Message %i is not received! \n', msg_nbr);
        end
    end
elseif avb_set == 0

    % EC duration take from the datatable file
    ec = master(1).EC * 10000;

    % slave numbers and message numbers report
    fprintf('number of slaves: %i \n', slave_number);
    fprintf('number of switches: %i \n', switch_number);
    fprintf('number of total messages: %i \n', non_frag_msg);


    %extract number of periodic and aperiodic messages considering local/global
    loc_per_count = 0;
    glob_per_count = 0;
    loc_aper_count = 0;
    glob_aper_count = 0;

    for i = 1:message_nbr
        if msg(i).pType == 0
            if msg(i).gType == 0
                if msg(i).defNum == 0
                    loc_per_count = loc_per_count + 1;
                else
                    if msg(i).defNum == msg(i).part
                        loc_per_count = loc_per_count + 1;
                    end
                end
            elseif msg(i).gType == 1
                if msg(i).defNum == 0
                    glob_per_count = glob_per_count + 1;
                else
                    if msg(i).defNum == msg(i).part
                        glob_per_count = glob_per_count + 1;
                    end
                end
            end
        elseif msg(i).pType == 1
            if msg(i).gType == 0
                if msg(i).defNum == 0
                    loc_aper_count = loc_aper_count + 1;
                else
                    if msg(i).defNum == msg(i).part
                        loc_aper_count = loc_aper_count + 1;
                    end
                end
            elseif msg(i).gType == 1
                if msg(i).defNum == 0
                    glob_aper_count = glob_aper_count + 1;
                else
                    if msg(i).defNum == msg(i).part
                        glob_aper_count = glob_aper_count + 1;
                    end
                end
            end
        end
    end
    fprintf('number of local periodic messages: %i \n', loc_per_count);
    fprintf('number of global periodic messages: %i \n', glob_per_count);
    fprintf('number of local Aperiodic messages: %i \n', loc_aper_count);
    fprintf('number of global Aperiodic messages: %i \n', glob_aper_count);


    %elementary cycle size report
    fprintf('Elementary Cycle Size: %ius \n', ec);

    % calculate the delay
    delay = 0;
    for msg_nbr = 1:message_nbr
        if msg(msg_nbr).defNum == 0
            delay = 0;
            for j = 1:length(receive_time_buffer{msg_nbr})
                delay(j) = receive_time_buffer{msg_nbr}(j) - ready_time_buffer{msg_nbr}(j);
            end
            min_delay = min(delay);
            max_delay = max(delay);
            mean_delay = mean(delay);
            if mean_delay > 0
                fprintf('message %i RT: min %i avg %i max %i \n', msg(msg_nbr).refMsgID, ceil(min_delay*10000/ec), ceil(mean_delay*10000/ec), ceil(max_delay*10000/ec)); 
                %fprintf('mes %i: %i %f %i %i %i %f %f %f \n', msg(msg_nbr).refMsgID, msg(msg_nbr).prio, msg(msg_nbr).exec * 10000, msg(msg_nbr).period, ...
                %            msg(msg_nbr).gType, msg(msg_nbr).pType,  ceil(min_delay*10000/ec), ceil(mean_delay*10000/ec), ceil(max_delay*10000/ec)); 
                %disp(msg_nbr)
                %str = strcat('A', num2str(msg(msg_nbr).refMsgID + 1));            
                %xlswrite('message.xls', [msg(msg_nbr).refMsgID, msg(msg_nbr).prio, msg(msg_nbr).exec * 10000, msg(msg_nbr).period, msg(msg_nbr).gType, msg(msg_nbr).pType, ceil(min_delay*10000/ec), ceil(mean_delay*10000/ec), ceil(max_delay*10000/ec)], 1, str);
            else
                fprintf('Message %i is not received! \n', msg_nbr);
            end
        elseif msg(msg_nbr).defNum > 0
            if msg(msg_nbr).part == msg(msg_nbr).defNum
                delay = 0;
                for j = 1:length(receive_time_buffer{msg_nbr})
                    delay(j) = receive_time_buffer{msg_nbr}(j) - ready_time_buffer{msg_nbr}(j);
                end
                min_delay = min(delay);
                max_delay = max(delay);
                mean_delay = mean(delay);
                if mean_delay > 0
                    fprintf('message %i RT: min %i avg %i max %i \n', ...
                            msg(msg_nbr).refMsgID, min_delay*10000/ec, mean_delay*10000/ec, max_delay*10000/ec);       
                else
                    fprintf('Message %i is not received! \n', msg(msg_nbr).refMsgID);
                end
            end
        end
    end
end

%save('message_struct', 'message');


