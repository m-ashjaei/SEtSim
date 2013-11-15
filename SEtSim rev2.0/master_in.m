function master_in(block)

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
block.InputPort(1).DirectFeedthrough = true;

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
global master;
global slave;
global slave_number;
global sampleTime;
global tm_win;
global msg;
global architect;

% get the current master number that function runs
ms_nbr = str2num(get_param(gcs, 'master_number'));

% State1: wait for aperiodic requests
% this state takes time equally as tm_win time
% depends on the architecture read the input of master nodes
if master(ms_nbr).state1 == 1
    if block.CurrentTime < master(ms_nbr).start_of_ec + tm_win
        input = block.InputPort(1).Data;
        if architect == 1 || architect == 3
            master(ms_nbr).scope_buffer = insert(master(ms_nbr).scope_buffer, input);
        elseif architect == 2
            if input == 0.5
                master(ms_nbr).scope_buffer = insert(master(ms_nbr).scope_buffer, input);
            elseif input == 0.75
                master(ms_nbr).scope_buffer = insert(master(ms_nbr).scope_buffer, input);
            end
        end
    else 
        if architect == 1
            for slv_nbr = 1:slave_number
                if slave(slv_nbr).parentNumber == ms_nbr
                    for iter = 1:length(slave(slv_nbr).ap_req)
                        if slave(slv_nbr).ap_req(iter) > 0
                            if msg(slave(slv_nbr).ap_req(iter)).gType == 1
                                master(ms_nbr).global_async_readyQ = insert_to_ascend(master(ms_nbr).global_async_readyQ, slave(slv_nbr).ap_req(iter));
                            elseif msg(slave(slv_nbr).ap_req(iter)).gType == 0
                                master(ms_nbr).local_async_readyQ = insert_to_ascend(master(ms_nbr).local_async_readyQ, slave(slv_nbr).ap_req(iter));
                            end
                        end
                    end
                    slave(slv_nbr).ap_req = 0;
                end
            end
        elseif architect == 2
            for slv_nbr = 1:slave_number
                if slave(slv_nbr).segmentNumber == ms_nbr
                    for iter = 1:length(slave(slv_nbr).ap_req)
                        if slave(slv_nbr).ap_req(iter) > 0
                            master(ms_nbr).local_async_readyQ = insert_to_ascend(master(ms_nbr).local_async_readyQ, slave(slv_nbr).ap_req(iter));
                        end
                    end
                    slave(slv_nbr).ap_req = 0;
                end
            end

            for slv_nbr = 1:slave_number
                if slave(slv_nbr).parentNumber == ms_nbr
                    for iter = 1:length(slave(slv_nbr).global_ap_req)
                        if slave(slv_nbr).global_ap_req(iter) > 0
                            master(ms_nbr).global_async_readyQ = insert_to_ascend(master(ms_nbr).global_async_readyQ, slave(slv_nbr).global_ap_req(iter));
                        end
                    end
                    slave(slv_nbr).global_ap_req = 0;
                end
            end
        elseif architect == 3
            for slv_nbr = 1:slave_number
                if ms_nbr == 1
                    for iter = 1:length(slave(slv_nbr).ap_req)
                        if slave(slv_nbr).ap_req(iter) > 0
                            master(ms_nbr).local_async_readyQ = insert_to_ascend(master(ms_nbr).local_async_readyQ, slave(slv_nbr).ap_req(iter));
                        end
                    end
                    slave(slv_nbr).ap_req = 0;
                end
            end
        end

        master(ms_nbr).state2 = 1;
        master(ms_nbr).state1 = 0;
        
    end
end


% Scope generator
if master(ms_nbr).ap_scope_done == 1
    %select the message id from buffer
    master(ms_nbr).min_scope_id = get_head(master(ms_nbr).scope_buffer);
    if master(ms_nbr).min_scope_id > 0
        master(ms_nbr).scope_buffer = remove_msg(master(ms_nbr).scope_buffer, master(ms_nbr).min_scope_id);
        master(ms_nbr).msin_duration = 0;
        master(ms_nbr).ap_scope_done = 0;
    end
end

% show the message id in scope considering the size of message
master(ms_nbr).msin_duration = master(ms_nbr).msin_duration + sampleTime;
if master(ms_nbr).msin_duration <= master(ms_nbr).ap_size
    master(ms_nbr).scope_in = master(ms_nbr).min_scope_id;
    %master(ms_nbr).ap_scope_done = 0;
else
    master(ms_nbr).scope_in = 0;
    master(ms_nbr).ap_scope_done = 1;
end

block.OutputPort(1).Data = master(ms_nbr).scope_in;

function Update(block)

function Terminate(block)

