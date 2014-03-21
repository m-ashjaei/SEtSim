%---------------------------------------------------------------------
% Copyright 2013 Mohammad Ashjaei <mohammad.ashjaei@mdh.se>
% This code is written in order to simulate switched Ethernet protocols.
%---------------------------------------------------------------------

function slave_in(block)

setup(block);

function setup(block)

% Register number of ports
block.NumInputPorts  = 1;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
block.InputPort(1).Dimensions        = 1;
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).SamplingMode = 'sample';

% Override output port properties
block.OutputPort(1).Dimensions       = 1;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'sample';

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
global sampleTime;
global msg;
global tm_win;
global synch_win;
global loc_per_win;
global glob_per_win;
global receive_time_buffer;
global architect;

% get the current slave number that function runs
slave_nbr = str2num(get_param(gcs, 'slave_number'));


% get the current master number that this function runs
if architect == 1
    mst_nbr = slave(slave_nbr).parentNumber;
elseif architect == 2
    mst_nbr = slave(slave_nbr).segmentNumber;
elseif architect == 3
    mst_nbr = 1;
end


% State0: wait for TM signal from master
input = block.InputPort(1).Data;
if (architect == 1) || (architect == 3)
    if input == 0.5
        slave(slave_nbr).tm_rec = master(mst_nbr).tm_signal;
        slave(slave_nbr).in_scope_buffer = insert(slave(slave_nbr).in_scope_buffer, slave(slave_nbr).tm_id);
        slave(slave_nbr).slin_scope_done = 0;
        slave(slave_nbr).state1 = 1;
    end
elseif architect == 2
    if input == 0.5
        slave(slave_nbr).tm_rec = master(mst_nbr).tm_signal;
        slave(slave_nbr).in_scope_buffer = insert(slave(slave_nbr).in_scope_buffer, slave(slave_nbr).tm_id);
        slave(slave_nbr).flagInput = 1;
        slave(slave_nbr).slin_scope_done = 0;
    elseif slave(slave_nbr).flagInput == 1
        if input == 0.25
            if master(slave(slave_nbr).parentNumber).asynch_tm_signal ~= 0
                slave(slave_nbr).asynch_tm_rec = master(slave(slave_nbr).parentNumber).asynch_tm_signal;
                slave(slave_nbr).in_scope_buffer = insert(slave(slave_nbr).in_scope_buffer, slave(slave_nbr).asynch_tm_id);
            end
            slave(slave_nbr).state1 = 1;
            slave(slave_nbr).flagInput = 0;
        end
    end
end


% State3: wait to receive any message from other slaves
if slave(slave_nbr).state3 == 1
    
    if block.CurrentTime < master(mst_nbr).nextHit - sampleTime
        if block.InputPort(1).Data >= 1
            
            slave(slave_nbr).in_scope_buffer = insert(slave(slave_nbr).in_scope_buffer, block.InputPort(1).Data);
            %if the message is local/internal periodic
            if (msg(block.InputPort(1).Data).pType == 0) && (msg(block.InputPort(1).Data).gType == 0)
                msg(block.InputPort(1).Data).receiveTime = block.CurrentTime + tm_win + ...
                                                       msg(block.InputPort(1).Data).exec + slave(slave_nbr).synchAccumulationTime;
                receive_time_buffer{block.InputPort(1).Data} = insert(receive_time_buffer{block.InputPort(1).Data}, msg(block.InputPort(1).Data).receiveTime);                                   
                slave(slave_nbr).synchAccumulationTime = msg(block.InputPort(1).Data).exec + slave(slave_nbr).synchAccumulationTime;
            %if the message is global/external periodic    
            elseif (msg(block.InputPort(1).Data).pType == 0) && (msg(block.InputPort(1).Data).gType == 1)
                msg(block.InputPort(1).Data).receiveTime = block.CurrentTime + tm_win + loc_per_win + ...
                                                       msg(block.InputPort(1).Data).exec + slave(slave_nbr).GsynchAccumulationTime;
                receive_time_buffer{block.InputPort(1).Data} = insert(receive_time_buffer{block.InputPort(1).Data}, msg(block.InputPort(1).Data).receiveTime);                                   
                slave(slave_nbr).GsynchAccumulationTime = msg(block.InputPort(1).Data).exec + slave(slave_nbr).GsynchAccumulationTime;    
            %if the message is local/internal Aperiodic    
            elseif (msg(block.InputPort(1).Data).pType == 1) && (msg(block.InputPort(1).Data).gType == 0)
                msg(block.InputPort(1).Data).receiveTime = block.CurrentTime + tm_win + synch_win + ...
                                                       msg(block.InputPort(1).Data).exec + slave(slave_nbr).AsynchAccumulationTime;
                receive_time_buffer{block.InputPort(1).Data} = insert(receive_time_buffer{block.InputPort(1).Data}, msg(block.InputPort(1).Data).receiveTime);                                   
                slave(slave_nbr).AsynchAccumulationTime = msg(block.InputPort(1).Data).exec + slave(slave_nbr).AsynchAccumulationTime;
            %if the message is global/external Aperiodic    
            elseif (msg(block.InputPort(1).Data).pType == 1) && (msg(block.InputPort(1).Data).gType == 1)
                msg(block.InputPort(1).Data).receiveTime = block.CurrentTime + tm_win + synch_win + glob_per_win + ...
                                                       msg(block.InputPort(1).Data).exec + slave(slave_nbr).GAsynchAccumulationTime;
                receive_time_buffer{block.InputPort(1).Data} = insert(receive_time_buffer{block.InputPort(1).Data}, msg(block.InputPort(1).Data).receiveTime);                                   
                slave(slave_nbr).GAsynchAccumulationTime = msg(block.InputPort(1).Data).exec + slave(slave_nbr).GAsynchAccumulationTime;    
            end
            
        end
    else
        
       %reset the flag and time accumulations
       slave(slave_nbr).state3 = 0; 
       slave(slave_nbr).synchAccumulationTime = 0;
       slave(slave_nbr).GsynchAccumulationTime = 0;
       slave(slave_nbr).AsynchAccumulationTime = 0;
       slave(slave_nbr).GAsynchAccumulationTime = 0;
    end
    
end


% Scope generator
% get the first message from scope buffer 
if slave(slave_nbr).slin_scope_done == 0
    slave(slave_nbr).slin_scope_msg = get_head(slave(slave_nbr).in_scope_buffer);
    %if message is tm signal
    if slave(slave_nbr).slin_scope_msg == 0.5
        slave(slave_nbr).in_scope_buffer = remove_msg(slave(slave_nbr).in_scope_buffer, slave(slave_nbr).slin_scope_msg);
        slave(slave_nbr).slin_duration = 0;
        slave(slave_nbr).slin_scope_done = 1;
    % if message is normal message    
    elseif slave(slave_nbr).slin_scope_msg >= 1
        if block.CurrentTime >= msg(slave(slave_nbr).slin_scope_msg).receiveTime
            slave(slave_nbr).in_scope_buffer = remove_msg(slave(slave_nbr).in_scope_buffer, slave(slave_nbr).slin_scope_msg);
            slave(slave_nbr).slin_duration = 0;
            slave(slave_nbr).slin_scope_done = 1;
            slave(slave_nbr).msg_rec_time = 1;
        else
            slave(slave_nbr).msg_rec_time = 0;
        end
    % if message is asynchTM signal    
    elseif slave(slave_nbr).slin_scope_msg == 0.25
        slave(slave_nbr).in_scope_buffer = remove_msg(slave(slave_nbr).in_scope_buffer, slave(slave_nbr).slin_scope_msg);
        slave(slave_nbr).slin_duration = 0;
        slave(slave_nbr).slin_scope_done = 1;
    end
end

% show the message id in scope according to its size
slave(slave_nbr).slin_duration = slave(slave_nbr).slin_duration + sampleTime;
if slave(slave_nbr).slin_scope_msg == 0.5
    if slave(slave_nbr).slin_duration <= slave(slave_nbr).tm_size
        slave(slave_nbr).scope_in = slave(slave_nbr).tm_id;
    else
        slave(slave_nbr).slin_scope_done = 0;
        slave(slave_nbr).scope_in = 0;
        slave(slave_nbr).slin_duration = 0;
    end
elseif (slave(slave_nbr).slin_scope_msg >= 1) && (slave(slave_nbr).msg_rec_time == 1)
    if slave(slave_nbr).slin_duration <= msg(slave(slave_nbr).slin_scope_msg).exec
        slave(slave_nbr).scope_in = msg(slave(slave_nbr).slin_scope_msg).refMsgID;
    else
        slave(slave_nbr).slin_scope_done = 0;
        slave(slave_nbr).scope_in = 0;
        slave(slave_nbr).slin_duration = 0;
    end
elseif slave(slave_nbr).slin_scope_msg == 0.25
    if slave(slave_nbr).slin_duration <= slave(slave_nbr).tm_size
        slave(slave_nbr).scope_in = slave(slave_nbr).asynch_tm_id;
    else
        slave(slave_nbr).slin_scope_done = 0;
        slave(slave_nbr).scope_in = 0;
        slave(slave_nbr).slin_duration = 0;
    end
end

block.OutputPort(1).Data = slave(slave_nbr).scope_in;


function Update(block)

function Terminate(block)


