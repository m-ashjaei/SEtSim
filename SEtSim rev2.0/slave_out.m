function slave_out(block)

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


function Outputs(block)
global slave;
global master;
global msg;
global sampleTime;
global tm_win;
global synch_win;
global loc_per_win;
global glob_per_win;
global ready_time_buffer;
global architect;

% get the slave number
slave_nbr = str2num(get_param(gcs, 'slave_number'));


% get the current master number that function runs
mst_nbr = slave(slave_nbr).segmentNumber;

% State1: check the aperiodic messages if they are ready and send SIG to master, after TM receiving
if slave(slave_nbr).state1 == 1
    if architect == 1
        % check if any local/internal aperiodic message in current slave is ready, 
        % insert to ap signal to send to its master node
        col = 1;
        for i = 1:master(mst_nbr).msg_nbr
            if msg(i).source == slave_nbr
                if msg(i).pType == 1
                    msg(i).tickCount = msg(i).tickCount + 1;
                    if msg(i).tickCount == msg(i).dynPeriod
                        msg(i).readyTime = block.CurrentTime + master(mst_nbr).EC;
                    elseif msg(i).tickCount > msg(i).dynPeriod
                        slave(slave_nbr).ap_req(col) = msg(i).id;
                        col = col + 1;
                        msg(i).tickCount = 1 - msg(i).offset;
                        if (msg(i).part == 0) || (msg(i).part == 1)
                            msg(i).dynPeriod = msg(i).period + randi([0 2],1,1);
                        elseif msg(i).part > 1
                            msg(i).dynPeriod = msg(i-1).dynPeriod;
                        end
                        ready_time_buffer{i} = insert(ready_time_buffer{i}, msg(i).readyTime);
                        slave(slave_nbr).ap_id = 0.5;
                    end
                end
            end
        end
    elseif architect == 2
        % check if any global/external aperiodic messag in current slave is ready,
        % insert to G-ap signal to send to parent master node to schedule
        col = 1;
        for i = 1:master(mst_nbr).msg_nbr
            if msg(i).source == slave_nbr
                if msg(i).pType == 1
                    if msg(i).gType == 0
                        msg(i).tickCount = msg(i).tickCount + 1;
                        if msg(i).tickCount == msg(i).dynPeriod
                            msg(i).readyTime = block.CurrentTime + master(mst_nbr).EC;
                        elseif msg(i).tickCount > msg(i).dynPeriod
                            slave(slave_nbr).ap_req(col) = msg(i).id;
                            col = col + 1;
                            msg(i).tickCount = 1 - msg(i).offset;
                            if (msg(i).part == 0) || (msg(i).part == 1)
                                msg(i).dynPeriod = msg(i).period + randi([0 2],1,1);
                            elseif msg(i).part > 1
                                msg(i).dynPeriod = msg(i-1).dynPeriod;
                            end
                            ready_time_buffer{i} = insert(ready_time_buffer{i}, msg(i).readyTime);
                            slave(slave_nbr).ap_id = 0.5;
                        end
                    end
                end
            end
        end
        col = 1;
        for j = 1:master(mst_nbr).msg_nbr
            if msg(j).source == slave_nbr
                if msg(j).pType == 1
                    if msg(j).gType == 1
                        msg(j).tickCount = msg(j).tickCount + 1;
                        if msg(j).tickCount == msg(j).dynPeriod
                            msg(j).readyTime = block.CurrentTime + master(mst_nbr).EC;
                        elseif msg(j).tickCount > msg(j).dynPeriod
                            slave(slave_nbr).global_ap_req(col) = msg(j).id;
                            col = col + 1;
                            msg(j).tickCount = 1 - msg(j).offset;
                            if (msg(j).part == 0) || (msg(j).part == 1)
                                msg(j).dynPeriod = msg(j).period + randi([0 2],1,1);
                            elseif msg(j).part > 1
                                msg(j).dynPeriod = msg(j - 1).dynPeriod;
                            end
                            ready_time_buffer{j} = insert(ready_time_buffer{j}, msg(j).readyTime);
                            slave(slave_nbr).global_ap_id = 0.75;
                        end
                    end
                end
            end
        end
    elseif architect == 3
        col = 1;
        for i = 1:master(1).msg_nbr
            if msg(i).source == slave_nbr
                if msg(i).pType == 1
                    msg(i).tickCount = msg(i).tickCount + 1;
                    if msg(i).tickCount == msg(i).dynPeriod
                        msg(i).readyTime = block.CurrentTime + master(1).EC;
                    elseif msg(i).tickCount > msg(i).dynPeriod
                        slave(slave_nbr).ap_req(col) = msg(i).id;
                        col = col + 1;
                        msg(i).tickCount = 1 - msg(i).offset;
                        if (msg(i).part == 0) || (msg(i).part == 1)
                            msg(i).dynPeriod = msg(i).period;% + randi([0 2],1,1);
                        elseif msg(i).part > 1
                            msg(i).dynPeriod = msg(i-1).dynPeriod;
                        end
                        ready_time_buffer{i} = insert(ready_time_buffer{i}, msg(i).readyTime);
                        slave(slave_nbr).ap_id = 0.5;
                    end
                end
            end
        end
    end

    %insert to output and scope buffers
    if slave(slave_nbr).ap_id == 0.5
        slave(slave_nbr).output = insert(slave(slave_nbr).output, slave(slave_nbr).ap_id);
        slave(slave_nbr).out_scope_buffer = insert(slave(slave_nbr).out_scope_buffer, slave(slave_nbr).ap_id);
        slave(slave_nbr).ap_id = 0;
    end
    
    if architect == 2
        if slave(slave_nbr).global_ap_id == 0.75
            slave(slave_nbr).output = insert(slave(slave_nbr).output, slave(slave_nbr).global_ap_id);
            slave(slave_nbr).out_scope_buffer = insert(slave(slave_nbr).out_scope_buffer, slave(slave_nbr).global_ap_id);
            slave(slave_nbr).global_ap_id = 0;
        end
    end
    
    slave(slave_nbr).slout_scope_done = 0;
    
    
    slave(slave_nbr).state2 = 1;
    slave(slave_nbr).state1 = 0;
end

% State2: decode the TM signal, send the scheduled messages to other slaves
if slave(slave_nbr).state2 == 1
    message_id = get_head(slave(slave_nbr).tm_rec);

    while message_id > 0
        if msg(message_id).source == slave_nbr
            slave(slave_nbr).tm_rec = remove_msg(slave(slave_nbr).tm_rec, message_id);
            slave(slave_nbr).output = insert(slave(slave_nbr).output, message_id); 
            slave(slave_nbr).out_scope_buffer = insert(slave(slave_nbr).out_scope_buffer, message_id);
        else
            slave(slave_nbr).tm_rec = remove_msg(slave(slave_nbr).tm_rec, message_id);
        end
        message_id = get_head(slave(slave_nbr).tm_rec);
    end
    
    if architect == 2
        if slave(slave_nbr).asynch_tm_rec ~= 0
            message_id = get_head(slave(slave_nbr).asynch_tm_rec);
            while message_id > 0
                if msg(message_id).source == slave_nbr
                    slave(slave_nbr).asynch_tm_rec = remove_msg(slave(slave_nbr).asynch_tm_rec, message_id);
                    slave(slave_nbr).output = insert(slave(slave_nbr).output, message_id); 
                    slave(slave_nbr).out_scope_buffer = insert(slave(slave_nbr).out_scope_buffer, message_id);
                else
                    slave(slave_nbr).asynch_tm_rec = remove_msg(slave(slave_nbr).asynch_tm_rec, message_id);
                end
                message_id = get_head(slave(slave_nbr).asynch_tm_rec);
            end
        end
    end

    slave(slave_nbr).state3 = 1;
    slave(slave_nbr).state2 = 0;
end

%send message or aperiodic signals
block.OutputPort(1).Data = get_head(slave(slave_nbr).output);
slave(slave_nbr).output = remove_msg(slave(slave_nbr).output, get_head(slave(slave_nbr).output));


% Scope generator
if slave(slave_nbr).slout_scope_done == 0
    slave(slave_nbr).slout_scope_msg = get_head(slave(slave_nbr).out_scope_buffer);
    % if the message id ap signal (local & global)
    if (slave(slave_nbr).slout_scope_msg == 0.5) || (slave(slave_nbr).slout_scope_msg == 0.75)
        slave(slave_nbr).out_scope_buffer = remove_msg(slave(slave_nbr).out_scope_buffer, slave(slave_nbr).slout_scope_msg);
        slave(slave_nbr).slout_duration = 0;
        slave(slave_nbr).slout_scope_done = 1;
    % if the message is data, (periodic and aperiodic)  
    % different if-cases is due to having different windows within EC
    elseif slave(slave_nbr).slout_scope_msg >= 1
        if (msg(slave(slave_nbr).slout_scope_msg).pType == 0) && (msg(slave(slave_nbr).slout_scope_msg).gType == 0) && (block.CurrentTime >= master(mst_nbr).start_of_ec + tm_win)
            slave(slave_nbr).out_scope_buffer = remove_msg(slave(slave_nbr).out_scope_buffer, slave(slave_nbr).slout_scope_msg);
            slave(slave_nbr).slout_duration = 0;
            slave(slave_nbr).slout_scope_done = 1;
            slave(slave_nbr).msg_trans_time = 1;
        elseif (msg(slave(slave_nbr).slout_scope_msg).pType == 0) && (msg(slave(slave_nbr).slout_scope_msg).gType == 1) && (block.CurrentTime >= master(mst_nbr).start_of_ec + tm_win + loc_per_win)
            slave(slave_nbr).out_scope_buffer = remove_msg(slave(slave_nbr).out_scope_buffer, slave(slave_nbr).slout_scope_msg);
            slave(slave_nbr).slout_duration = 0;
            slave(slave_nbr).slout_scope_done = 1;
            slave(slave_nbr).msg_trans_time = 1;
        elseif (msg(slave(slave_nbr).slout_scope_msg).pType == 1) && (msg(slave(slave_nbr).slout_scope_msg).gType == 0) && (block.CurrentTime >= master(mst_nbr).start_of_ec + tm_win + synch_win)
            slave(slave_nbr).out_scope_buffer = remove_msg(slave(slave_nbr).out_scope_buffer, slave(slave_nbr).slout_scope_msg);
            slave(slave_nbr).slout_duration = 0;
            slave(slave_nbr).slout_scope_done = 1;
            slave(slave_nbr).msg_trans_time = 1;
        elseif (msg(slave(slave_nbr).slout_scope_msg).pType == 1) && (msg(slave(slave_nbr).slout_scope_msg).gType == 1) && (block.CurrentTime >= master(mst_nbr).start_of_ec + tm_win + synch_win + glob_per_win)
            slave(slave_nbr).out_scope_buffer = remove_msg(slave(slave_nbr).out_scope_buffer, slave(slave_nbr).slout_scope_msg);
            slave(slave_nbr).slout_duration = 0;
            slave(slave_nbr).slout_scope_done = 1;
            slave(slave_nbr).msg_trans_time = 1;
        else
            slave(slave_nbr).msg_trans_time = 0;
        end
    end
end

% show messages id in scope considering their sizes
slave(slave_nbr).slout_duration = slave(slave_nbr).slout_duration + sampleTime;
if slave(slave_nbr).slout_scope_msg == 0.5
    if slave(slave_nbr).slout_duration <= slave(slave_nbr).ap_size
        slave(slave_nbr).scope_out = slave(slave_nbr).slout_scope_msg;
    else
        slave(slave_nbr).slout_scope_done = 0;
        slave(slave_nbr).scope_out = 0;
        slave(slave_nbr).slout_duration = 0;
    end
elseif slave(slave_nbr).slout_scope_msg == 0.75
    if slave(slave_nbr).slout_duration <= slave(slave_nbr).ap_size
        slave(slave_nbr).scope_out = slave(slave_nbr).slout_scope_msg;
    else
        slave(slave_nbr).slout_scope_done = 0;
        slave(slave_nbr).scope_out = 0;
        slave(slave_nbr).slout_duration = 0;
    end
elseif (slave(slave_nbr).slout_scope_msg >= 1) && (slave(slave_nbr).msg_trans_time == 1)
    if slave(slave_nbr).slout_duration <= msg(slave(slave_nbr).slout_scope_msg).exec
        slave(slave_nbr).scope_out = msg(slave(slave_nbr).slout_scope_msg).refMsgID;
    else
        slave(slave_nbr).slout_scope_done = 0;
        slave(slave_nbr).scope_out = 0;
        slave(slave_nbr).slout_duration = 0;
    end
end

block.OutputPort(2).Data = slave(slave_nbr).scope_out;


function Update(block)


function Terminate(block)



