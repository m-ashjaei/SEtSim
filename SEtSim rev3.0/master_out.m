%---------------------------------------------------------------------
% Copyright 2013 Mohammad Ashjaei <mohammad.ashjaei@mdh.se>
% This code is written in order to simulate switched Ethernet protocols.
%---------------------------------------------------------------------

function master_out(block)

setup(block);

function setup(block)

% Register number of ports
block.NumInputPorts  = 0;
block.NumOutputPorts = 2;

% Setup port properties to be inherited or dynamic
%block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override output port properties
block.OutputPort(1).Dimensions       = 1;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'sample';

block.OutputPort(2).Dimensions       = 1;
block.OutputPort(2).DatatypeID  = 0; % double
block.OutputPort(2).Complexity  = 'Real';
block.OutputPort(2).SamplingMode = 'sample';

% Register parameters
block.NumDialogPrms     = 0;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [0 1]; %contineous sample time

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Update', @Update);
block.RegBlockMethod('Terminate', @Terminate); % Required

%end setup

function Start(block)

% get the current master number that function runs
ms_nbr = str2num(get_param(gcs, 'master_number'));

% data table run just in root master node, for configuration
if ms_nbr == 1
    data_table;
end


function Outputs(block)
global master;
global slave;
global sw;
global msg;
global cluster;
global switch_number;
global architect;

global sampleTime;
global master_number;
global ready_time_buffer;

global glob_per_win;
global cluster_win;
global loc_per_win;
global loc_aper_win;

global scope_disable;

% get the current master number
ms_nbr = str2num(get_param(gcs, 'master_number'));

% State0: broadcast the TM signal
master(ms_nbr).simTime = block.CurrentTime;
if master(ms_nbr).simTime >= master(ms_nbr).nextHit
    master(ms_nbr).nextHit = master(ms_nbr).simTime + master(ms_nbr).EC;
    master(ms_nbr).start_of_ec = master(ms_nbr).simTime;
    master(ms_nbr).state1 = 1;
    master(ms_nbr).outputMaster = insert(master(ms_nbr).outputMaster, master(ms_nbr).tm_id);
    master(ms_nbr).masterScopeOut = insert(master(ms_nbr).masterScopeOut, master(ms_nbr).tm_id);
    master(ms_nbr).tm_scope_done = 0;

    if architect == 2
        master(ms_nbr).outputMaster = insert(master(ms_nbr).outputMaster, master(ms_nbr).asynch_tm_id);
        master(ms_nbr).masterScopeOut = insert(master(ms_nbr).masterScopeOut, master(ms_nbr).asynch_tm_id);
    end
    
    % reset global bandwidths   
    for swit = 1:switch_number
        for por = 1:sw(ms_nbr).port_nbr
            master(ms_nbr).synch_local_up_filled(swit, por) = 0;
            master(ms_nbr).synch_local_down_filled(swit, por) = 0;

            master(ms_nbr).asynch_local_up_filled(swit, por) = 0;
            master(ms_nbr).asynch_local_down_filled(swit, por) = 0;
            
            master(ms_nbr).synch_global_up_filled(swit, por) = 0;
            master(ms_nbr).synch_global_down_filled(swit, por) = 0;
            
            for clust = 1:cluster
                master(ms_nbr).asynch_global_up_filled(swit, por, clust) = 0;
                master(ms_nbr).asynch_global_down_filled(swit, por, clust) = 0;
            end
        end
    end
end


% insert data from buffer to master output
block.OutputPort(1).Data = get_head(master(ms_nbr).outputMaster);
if get_head(master(ms_nbr).outputMaster) == 0.5
    master(ms_nbr).tm_signal = master(ms_nbr).tm_data;
    master(ms_nbr).tm_data = 0;
elseif get_head(master(ms_nbr).outputMaster) == 0.25
    master(ms_nbr).asynch_tm_signal = master(ms_nbr).asynch_tm_data;
    master(ms_nbr).asynch_tm_data = 0;
end
master(ms_nbr).outputMaster = remove_msg(master(ms_nbr).outputMaster, get_head(master(ms_nbr).outputMaster));

% State2: schedule the periodic message and generate the next TM
if master(ms_nbr).state2 == 1

    % check if any local/internal periodic message is ready in current master, insert to local periodic ready queue
    % in case of single-master architecture, we have just local periodic
    % and local aperiodic messages, hence ready queues
    for i = 1:master(ms_nbr).msg_nbr
        if architect == 1
            if slave(msg(i).source).parentNumber == ms_nbr
                if msg(i).gType == 0
                    if msg(i).pType == 0
                        msg(i).tickCount = msg(i).tickCount + 1;
                        if msg(i).tickCount == msg(i).period
                            master(ms_nbr).local_sync_readyQ = insert_to_ascend(master(ms_nbr).local_sync_readyQ, msg(i).id);
                            msg(i).tickCount = 0 - msg(i).offset;
                            msg(i).readyTime = block.CurrentTime + master(ms_nbr).EC;
                            ready_time_buffer{i} = insert(ready_time_buffer{i}, msg(i).readyTime);
                        end
                    end
                end
            end
        elseif architect == 2
            if msg(i).sourceMasterNumber == ms_nbr
                if msg(i).gType == 0
                    if msg(i).pType == 0
                        msg(i).tickCount = msg(i).tickCount + 1;
                        if msg(i).tickCount == msg(i).period
                            master(ms_nbr).local_sync_readyQ = insert_to_ascend(master(ms_nbr).local_sync_readyQ, msg(i).id);
                            msg(i).tickCount = 0 - msg(i).offset;
                            msg(i).readyTime = block.CurrentTime + master(ms_nbr).EC;
                            ready_time_buffer{i} = insert(ready_time_buffer{i}, msg(i).readyTime);
                        end
                    end
                end
            end
        elseif architect == 3
            if ms_nbr == 1
                if msg(i).pType == 0
                    msg(i).tickCount = msg(i).tickCount + 1;
                    if msg(i).tickCount == msg(i).period
                        master(ms_nbr).local_sync_readyQ = insert_to_ascend(master(ms_nbr).local_sync_readyQ, msg(i).id);
                        msg(i).tickCount = 0 - msg(i).offset;
                        msg(i).readyTime = block.CurrentTime + master(ms_nbr).EC;
                        ready_time_buffer{i} = insert(ready_time_buffer{i}, msg(i).readyTime);
                    end
                end
            end
        end
    end


    % check if any global/external periodic message is ready, insert to global
    % periodic ready queue in all masters, this is done just in root master
    % since there is just one struct for messages
    if architect ~= 3
        if ms_nbr == 1
            for i = 1:master(ms_nbr).msg_nbr
                if msg(i).gType == 1
                    if msg(i).pType == 0
                        msg(i).tickCount = msg(i).tickCount + 1;
                        if msg(i).tickCount == msg(i).period
                            for msnbr = 1:master_number
                                master(msnbr).global_sync_readyQ = insert_to_ascend(master(msnbr).global_sync_readyQ, msg(i).id);
                            end
                            msg(i).tickCount = 0 - msg(i).offset;
                            msg(i).readyTime = block.CurrentTime + master(ms_nbr).EC;
                            ready_time_buffer{i} = insert(ready_time_buffer{i}, msg(i).readyTime);
                        end
                    end
                end
            end
        end
    end
    
     
    % start the scheduling, check local/internal periodic message in all bins
    [id, master(ms_nbr).local_sync_readyQ] = get_from_head(master(ms_nbr).local_sync_readyQ);
    element = 1;
    col = 1;
    if architect == 1
        flag_sch = 0;
        while id ~= 0
            if (master(ms_nbr).synch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + msg(id).exec) <= loc_per_win
                if (msg(id).exec + max(master(ms_nbr).synch_local_down_filled(msg(id).destMasterNumber, slave(msg(id).dest).swPortNumber), master(ms_nbr).synch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + ((length(msg(id).SwitchInRout) + 1) * msg(id).exec))) <= loc_per_win
                    for iter = 1:length(msg(id).SwitchInRout)
                        if msg(id).SwitchInRout == 0
                            flag_sch = 1;
                        elseif (msg(id).exec + max(master(ms_nbr).synch_local_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)), master(ms_nbr).synch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + (iter * msg(id).exec))) <= loc_per_win
                            flag_sch = 1;
                        else 
                            flag_sch = 0;
                            break;
                        end
                    end

                    if flag_sch == 1
                        master(ms_nbr).local_sync_readyQ = remove_from_queue(master(ms_nbr).local_sync_readyQ, id);                    
                        master(ms_nbr).synch_local_down_filled(msg(id).destMasterNumber, slave(msg(id).dest).swPortNumber) = ...
                                       msg(id).exec + max(master(ms_nbr).synch_local_down_filled(msg(id).destMasterNumber, slave(msg(id).dest).swPortNumber), master(ms_nbr).synch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + ((length(msg(id).SwitchInRout) + 1) * msg(id).exec));
                        if msg(id).SwitchInRout ~= 0 
                            for iter = 1:length(msg(id).SwitchInRout)
                                master(ms_nbr).synch_local_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)) = ... 
                                        msg(id).exec + max( master(ms_nbr).synch_local_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)), master(ms_nbr).synch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + (iter * msg(id).exec));
                            end
                        end
                        master(ms_nbr).synch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) = master(ms_nbr).synch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + msg(id).exec;
                        master(ms_nbr).tm_data(col) = id;
                        col = col + 1;
                        [id, master(ms_nbr).local_sync_readyQ] = get_from_head(master(ms_nbr).local_sync_readyQ);
                        element = 1;
                        continue;
                    end 
                end
            end
            element = element + 1;
            [id, master(ms_nbr).local_sync_readyQ] = get_next(master(ms_nbr).local_sync_readyQ, element);
        end
    elseif architect == 2
        while id ~= 0
            if (master(ms_nbr).synch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + msg(id).exec) <= loc_per_win
                if (msg(id).exec + max(master(ms_nbr).synch_local_down_filled(msg(id).destMasterNumber, slave(msg(id).dest).swPortNumber), msg(id).exec + master(ms_nbr).synch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber))) <= loc_per_win
                    master(ms_nbr).local_sync_readyQ = remove_from_queue(master(ms_nbr).local_sync_readyQ, id);
                    master(ms_nbr).synch_local_down_filled(msg(id).destMasterNumber, slave(msg(id).dest).swPortNumber) = msg(id).exec + max(master(ms_nbr).synch_local_down_filled(msg(id).destMasterNumber, slave(msg(id).dest).swPortNumber), msg(id).exec + master(ms_nbr).synch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber));
                    master(ms_nbr).synch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) = master(ms_nbr).synch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + msg(id).exec;
                    master(ms_nbr).tm_data(col) = id;
                    col = col + 1;
                    [id, master(ms_nbr).local_sync_readyQ] = get_from_head(master(ms_nbr).local_sync_readyQ);
                    element = 1;
                    continue;
                end
            end
            element = element + 1;
            [id, master(ms_nbr).local_sync_readyQ] = get_next(master(ms_nbr).local_sync_readyQ, element);
        end
    elseif architect == 3
        flag_sch = 0;
        while id ~= 0
            if (master(1).synch_local_up_filled(slave(msg(id).source).segmentNumber, slave(msg(id).source).swPortNumber) + msg(id).exec) <= loc_per_win
                if (msg(id).exec + max(master(1).synch_local_down_filled(slave(msg(id).dest).segmentNumber, slave(msg(id).dest).swPortNumber), master(1).synch_local_up_filled(slave(msg(id).source).segmentNumber, slave(msg(id).source).swPortNumber) + ((length(msg(id).SwitchInRout) + 1) * msg(id).exec))) <= loc_per_win
                    for iter = 1:length(msg(id).SwitchInRout)
                        if msg(id).SwitchInRout == 0
                            flag_sch = 1;
                        elseif (msg(id).exec + max(master(1).synch_local_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)), master(1).synch_local_up_filled(slave(msg(id).source).segmentNumber, slave(msg(id).source).swPortNumber) + (iter * msg(id).exec))) <= loc_per_win
                            flag_sch = 1;
                        else 
                            flag_sch = 0;
                            break;
                        end
                    end

                    if flag_sch == 1
                        master(1).local_sync_readyQ = remove_from_queue(master(1).local_sync_readyQ, id);                    
                        master(1).synch_local_down_filled(slave(msg(id).dest).segmentNumber, slave(msg(id).dest).swPortNumber) = ...
                                       msg(id).exec + max(master(1).synch_local_down_filled(slave(msg(id).dest).segmentNumber, slave(msg(id).dest).swPortNumber), master(1).synch_local_up_filled(slave(msg(id).source).segmentNumber, slave(msg(id).source).swPortNumber) + ((length(msg(id).SwitchInRout) + 1) * msg(id).exec));
                        if msg(id).SwitchInRout ~= 0 
                            for iter = 1:length(msg(id).SwitchInRout)
                                master(1).synch_local_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)) = ... 
                                        msg(id).exec + max( master(1).synch_local_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)), master(1).synch_local_up_filled(slave(msg(id).source).segmentNumber, slave(msg(id).source).swPortNumber) + (iter * msg(id).exec));
                            end
                        end
                        master(1).synch_local_up_filled(slave(msg(id).source).segmentNumber, slave(msg(id).source).swPortNumber) = master(1).synch_local_up_filled(slave(msg(id).source).segmentNumber, slave(msg(id).source).swPortNumber) + msg(id).exec;
                        master(1).tm_data(col) = id;
                        col = col + 1;
                        [id, master(1).local_sync_readyQ] = get_from_head(master(1).local_sync_readyQ);
                        element = 1;
                        continue;
                    end 
                end
            end
            element = element + 1;
            [id, master(1).local_sync_readyQ] = get_next(master(1).local_sync_readyQ, element);
        end
    end

    % start the scheduling, check local/internal aperiodic message in all bins
    [id, master(ms_nbr).local_async_readyQ] = get_from_head(master(ms_nbr).local_async_readyQ);
    element = 1;
    if architect == 1
        flag_sch = 0;
        while id ~= 0
            if (master(ms_nbr).asynch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + msg(id).exec) <= loc_aper_win
                if (msg(id).exec + max(master(ms_nbr).asynch_local_down_filled(msg(id).destMasterNumber, slave(msg(id).dest).swPortNumber), master(ms_nbr).asynch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + ((length(msg(id).SwitchInRout) + 1) * msg(id).exec))) <= loc_aper_win
                    for iter = 1:length(msg(id).SwitchInRout)
                        if msg(id).SwitchInRout == 0
                            flag_sch = 1;
                        elseif (msg(id).exec + max(master(ms_nbr).asynch_local_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)), master(ms_nbr).asynch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + (iter * msg(id).exec))) <= loc_aper_win
                            flag_sch = 1;
                        else 
                            flag_sch = 0;
                            break;
                        end
                    end

                    if flag_sch == 1
                        master(ms_nbr).local_async_readyQ = remove_from_queue(master(ms_nbr).local_async_readyQ, id);                    
                        master(ms_nbr).asynch_local_down_filled(msg(id).destMasterNumber, slave(msg(id).dest).swPortNumber) = ...
                                       msg(id).exec + max(master(ms_nbr).asynch_local_down_filled(msg(id).destMasterNumber, slave(msg(id).dest).swPortNumber), master(ms_nbr).asynch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + ((length(msg(id).SwitchInRout) + 1) * msg(id).exec));
                        if msg(id).SwitchInRout ~= 0            
                            for iter = 1:length(msg(id).SwitchInRout)
                                master(ms_nbr).asynch_local_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)) = ... 
                                          msg(id).exec + max( master(ms_nbr).asynch_local_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)), master(ms_nbr).asynch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + (iter * msg(id).exec));
                            end
                        end
                        master(ms_nbr).asynch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) = master(ms_nbr).asynch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + msg(id).exec;
                        master(ms_nbr).tm_data(col) = id;
                        col = col + 1;
                        [id, master(ms_nbr).local_async_readyQ] = get_from_head(master(ms_nbr).local_async_readyQ);
                        element = 1;
                        continue;
                    end 
                end
            end
            element = element + 1;
            [id, master(ms_nbr).local_async_readyQ] = get_next(master(ms_nbr).local_async_readyQ, element);
        end
    elseif architect == 2
        while id ~= 0
            if (master(ms_nbr).asynch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + msg(id).exec) <= loc_aper_win
                if (msg(id).exec + max(master(ms_nbr).asynch_local_down_filled(msg(id).destMasterNumber, slave(msg(id).dest).swPortNumber), msg(id).exec + master(ms_nbr).asynch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber))) <= loc_aper_win
                    master(ms_nbr).local_async_readyQ = remove_from_queue(master(ms_nbr).local_async_readyQ, id);
                    master(ms_nbr).asynch_local_down_filled(slave(msg(id).dest).swPortNumber) = msg(id).exec + max(master(ms_nbr).asynch_local_down_filled(msg(id).destMasterNumber, slave(msg(id).dest).swPortNumber), msg(id).exec + master(ms_nbr).asynch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber));
                    master(ms_nbr).asynch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) = master(ms_nbr).asynch_local_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + msg(id).exec;
                    master(ms_nbr).tm_data(col) = id;
                    col = col + 1;
                    [id, master(ms_nbr).local_async_readyQ] = get_from_head(master(ms_nbr).local_async_readyQ);
                    element = 1;
                    continue;
                end
            end
            element = element + 1;
            [id, master(ms_nbr).local_async_readyQ] = get_next(master(ms_nbr).local_async_readyQ, element);
        end
    elseif architect == 3
        flag_sch = 0;
        while id ~= 0
            if (master(1).asynch_local_up_filled(slave(msg(id).source).segmentNumber, slave(msg(id).source).swPortNumber) + msg(id).exec) <= loc_per_win
                if (msg(id).exec + max(master(1).asynch_local_down_filled(slave(msg(id).dest).segmentNumber, slave(msg(id).dest).swPortNumber), master(1).asynch_local_up_filled(slave(msg(id).source).segmentNumber, slave(msg(id).source).swPortNumber) + ((length(msg(id).SwitchInRout) + 1) * msg(id).exec))) <= loc_per_win
                    for iter = 1:length(msg(id).SwitchInRout)
                        if msg(id).SwitchInRout == 0
                            flag_sch = 1;
                        elseif (msg(id).exec + max(master(1).asynch_local_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)), master(1).asynch_local_up_filled(msg(id).SwitchInRout(1), slave(msg(id).source).swPortNumber) + (iter * msg(id).exec))) <= loc_per_win
                            flag_sch = 1;
                        else 
                            flag_sch = 0;
                            break;
                        end
                    end

                    if flag_sch == 1
                        master(1).local_async_readyQ = remove_from_queue(master(1).local_async_readyQ, id);                    
                        master(1).asynch_local_down_filled(slave(msg(id).dest).segmentNumber, slave(msg(id).dest).swPortNumber) = ...
                                       msg(id).exec + max(master(1).asynch_local_down_filled(slave(msg(id).dest).segmentNumber, slave(msg(id).dest).swPortNumber), master(1).asynch_local_up_filled(slave(msg(id).source).segmentNumber, slave(msg(id).source).swPortNumber) + ((length(msg(id).SwitchInRout) + 1) * msg(id).exec));
                        if msg(id).SwitchInRout ~= 0 
                            for iter = 1:length(msg(id).SwitchInRout)
                                master(1).asynch_local_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)) = ... 
                                        msg(id).exec + max( master(1).asynch_local_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)), master(1).asynch_local_up_filled(slave(msg(id).source).segmentNumber, slave(msg(id).source).swPortNumber) + (iter * msg(id).exec));
                            end
                        end
                        master(1).asynch_local_up_filled(slave(msg(id).source).segmentNumber, slave(msg(id).source).swPortNumber) = master(1).asynch_local_up_filled(slave(msg(id).source).segmentNumber, slave(msg(id).source).swPortNumber) + msg(id).exec;
                        master(1).tm_data(col) = id;
                        col = col + 1;
                        [id, master(1).local_async_readyQ] = get_from_head(master(1).local_async_readyQ);
                        element = 1;
                        continue;
                    end 
                end
            end
            element = element + 1;
            [id, master(1).local_async_readyQ] = get_next(master(1).local_async_readyQ, element);
        end
    end
    

    % start the scheduling, check global/external periodic message in all bins
    if architect ~= 3
        [id, master(ms_nbr).global_sync_readyQ] = get_from_head(master(ms_nbr).global_sync_readyQ);
        element = 1;
        flag_sch = 0;
        while id ~= 0
            if architect == 1
                source = msg(id).sourceMasterNumber;
                destination = msg(id).destMasterNumber;
            elseif architect == 2
                source = ms_nbr;
                destination = slave(msg(id).dest).segmentNumber;
            end
            if (master(ms_nbr).synch_global_up_filled(source, slave(msg(id).source).swPortNumber) + msg(id).exec) <= glob_per_win
                if (msg(id).exec + max(master(ms_nbr).synch_global_down_filled(destination, slave(msg(id).dest).swPortNumber), master(ms_nbr).synch_global_up_filled(source, slave(msg(id).source).swPortNumber) + ((length(msg(id).SwitchInRout) + 1) * msg(id).exec))) <= glob_per_win
                    for iter = 1:length(msg(id).SwitchInRout)
                        if (msg(id).exec + max(master(ms_nbr).synch_global_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)), master(ms_nbr).synch_global_up_filled(source, slave(msg(id).source).swPortNumber) + (iter * msg(id).exec))) <= glob_per_win
                            flag_sch = 1;
                        else 
                            flag_sch = 0;
                            break;
                        end
                    end

                    if flag_sch == 1
                        master(ms_nbr).global_sync_readyQ = remove_from_queue(master(ms_nbr).global_sync_readyQ, id);                    
                        master(ms_nbr).synch_global_down_filled(destination, slave(msg(id).dest).swPortNumber) = ...
                                       msg(id).exec + max(master(ms_nbr).synch_global_down_filled(destination, slave(msg(id).dest).swPortNumber), master(ms_nbr).synch_global_up_filled(msg(id).sourceMasterNumber, slave(msg(id).source).swPortNumber) + ((length(msg(id).SwitchInRout) + 1) * msg(id).exec));
                        for iter = 1:length(msg(id).SwitchInRout)
                            master(ms_nbr).synch_global_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)) = ... 
                                      msg(id).exec + max( master(ms_nbr).synch_global_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter)), master(ms_nbr).synch_global_up_filled(source, slave(msg(id).source).swPortNumber) + (iter * msg(id).exec));
                        end
                        master(ms_nbr).synch_global_up_filled(source, slave(msg(id).source).swPortNumber) = master(ms_nbr).synch_global_up_filled(source, slave(msg(id).source).swPortNumber) + msg(id).exec;
                        if architect == 1
                            if slave(msg(id).source).parentNumber == ms_nbr
                                master(ms_nbr).tm_data(col) = id;
                                col = col + 1;
                            end 
                        elseif architect == 2
                            if msg(id).sourceMasterNumber == ms_nbr
                                master(ms_nbr).tm_data(col) = id;
                                col = col + 1;
                            end
                        end
                        [id, master(ms_nbr).global_sync_readyQ] = get_from_head(master(ms_nbr).global_sync_readyQ);
                        element = 1;
                        continue;
                    end 
                end
            end
            element = element + 1;
            [id, master(ms_nbr).global_sync_readyQ] = get_next(master(ms_nbr).global_sync_readyQ, element);
        end


        % start the scheduling, check global/external aperiodic message in all bins
        [id, master(ms_nbr).global_async_readyQ] = get_from_head(master(ms_nbr).global_async_readyQ);
        if architect == 2
            col = 1;
        end
        element = 1;
        flag_sch = 0;
        while id ~= 0
            if architect == 1
                source = msg(id).sourceMasterNumber;
                destination = msg(id).destMasterNumber;
            elseif architect == 2
                source = ms_nbr;
                destination = slave(msg(id).dest).segmentNumber;
            end
            if (master(ms_nbr).asynch_global_up_filled(source, slave(msg(id).source).swPortNumber, msg(id).cluster) + msg(id).exec) <= cluster_win
                if (msg(id).exec + max(master(ms_nbr).asynch_global_down_filled(destination, slave(msg(id).dest).swPortNumber, msg(id).cluster), master(ms_nbr).asynch_global_up_filled(source, slave(msg(id).source).swPortNumber, msg(id).cluster) + ((length(msg(id).SwitchInRout) + 1) * msg(id).exec))) <= cluster_win
                    for iter = 1:length(msg(id).SwitchInRout)
                        if (msg(id).exec + max(master(ms_nbr).asynch_global_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter), msg(id).cluster), master(ms_nbr).asynch_global_up_filled(source, slave(msg(id).source).swPortNumber, msg(id).cluster) + (iter * msg(id).exec))) <= cluster_win
                            flag_sch = 1;
                        else 
                            flag_sch = 0;
                            break;
                        end
                    end

                    if flag_sch == 1
                        master(ms_nbr).global_async_readyQ = remove_from_queue(master(ms_nbr).global_async_readyQ, id);                    
                        master(ms_nbr).asynch_global_down_filled(destination, slave(msg(id).dest).swPortNumber, msg(id).cluster) = ...
                                       msg(id).exec + max(master(ms_nbr).asynch_global_down_filled(destination, slave(msg(id).dest).swPortNumber, msg(id).cluster), master(ms_nbr).asynch_global_up_filled(source, slave(msg(id).source).swPortNumber, msg(id).cluster) + ((length(msg(id).SwitchInRout) + 1) * msg(id).exec));
                        for iter = 1:length(msg(id).SwitchInRout)
                            master(ms_nbr).asynch_global_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter), msg(id).cluster) = ... 
                                      msg(id).exec + max(master(ms_nbr).asynch_global_down_filled(msg(id).SwitchInRout(iter), msg(id).SwitchPort(iter), msg(id).cluster), master(ms_nbr).asynch_global_up_filled(source, slave(msg(id).source).swPortNumber, msg(id).cluster) + (iter * msg(id).exec));
                        end
                        master(ms_nbr).asynch_global_up_filled(source, slave(msg(id).source).swPortNumber, msg(id).cluster) = master(ms_nbr).asynch_global_up_filled(source, slave(msg(id).source).swPortNumber, msg(id).cluster) + msg(id).exec;
                        if msg(id).ClParentMaster == ms_nbr
                            if architect == 1
                                master(ms_nbr).tm_data(col) = id;
                            elseif architect == 2
                                master(ms_nbr).asynch_tm_data(col) = id;
                            end
                            col = col + 1;
                        end 
                        [id, master(ms_nbr).global_async_readyQ] = get_from_head(master(ms_nbr).global_async_readyQ);
                        element = 1;
                        continue;
                    end 
                end
            end
            element = element + 1;
            [id, master(ms_nbr).global_async_readyQ] = get_next(master(ms_nbr).global_async_readyQ, element);
        end

        if master(ms_nbr).asynch_tm_data == 0   
            master(ms_nbr).asynch_tm_signal = 0;
        end
    end
       
    master(ms_nbr).state2 = 0;

end


if scope_disable == 0
    % Scope generator
    if master(ms_nbr).tm_scope_done == 0
        master(ms_nbr).mout_scope_id = get_head(master(ms_nbr).masterScopeOut);
        if master(ms_nbr).mout_scope_id > 0
            master(ms_nbr).masterScopeOut = remove_msg(master(ms_nbr).masterScopeOut, master(ms_nbr).mout_scope_id);
            master(ms_nbr).msout_duration = 0;
            master(ms_nbr).tm_scope_done = 1;
        end
    end

    master(ms_nbr).msout_duration = master(ms_nbr).msout_duration + sampleTime;
    if master(ms_nbr).msout_duration <= master(ms_nbr).tm_size
            master(ms_nbr).scope_out = master(ms_nbr).mout_scope_id;
    else
            master(ms_nbr).tm_scope_done = 0;
            master(ms_nbr).scope_out = 0;
            master(ms_nbr).msout_duration = 0;
    end 
block.OutputPort(2).Data = master(ms_nbr).scope_out;
end

function Update(block)

function Terminate(block)

