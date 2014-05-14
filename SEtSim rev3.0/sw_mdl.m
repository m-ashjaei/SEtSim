%---------------------------------------------------------------------
% Copyright 2013 Mohammad Ashjaei <mohammad.ashjaei@mdh.se>
% This code is written in order to simulate switched Ethernet protocols.
%---------------------------------------------------------------------

function sw_mdl(block)

setup(block);

function setup(block)

% Register number of ports
block.NumInputPorts  = 16;
block.NumOutputPorts = 16;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
for in = 1:16
    block.InputPort(in).Dimensions        = 1;
    block.InputPort(in).DatatypeID  = 0;  % double
    block.InputPort(in).Complexity  = 'Real';
    block.InputPort(in).SamplingMode = 'Sample';
    block.InputPort(in).DirectFeedthrough = false;
end

% Override output port properties
for out = 1:16
    block.OutputPort(out).Dimensions       = 1;
    block.OutputPort(out).DatatypeID  = 0; % double
    block.OutputPort(out).Complexity  = 'Real';
    block.OutputPort(out).SamplingMode = 'sample';
end

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
global msg;
global sw;
global slave;
global architect;

% get the current switch number that function runs
sw_nbr = str2num(get_param(gcb, 'switch_number'));

% read the input ports and insert to input buffer if any
for p = 1:sw(sw_nbr).port_nbr
    if block.InputPort(p).Data > 0
        sw(sw_nbr).inBuffer{p} = insert(sw(sw_nbr).inBuffer{p}, block.InputPort(p).Data);
    end
end


% get messages from input buffer and insert to correct output buffer
% check the destination of messages

% port 1 always is master node connection
% for sending TM from master to all slave nodes
% elseif the asynchTM for global aperiodic messages are published from parent
% master node, it should be sent to children slaves
% the value 0.5 is TM from master to slaves 
message = get_head(sw(sw_nbr).inBuffer{1});
if architect == 1
    if (message == 0.5) && (sw_nbr == 1)
        sw(sw_nbr).inBuffer{1} = remove_msg(sw(sw_nbr).inBuffer{1}, message);
        for por = 3:sw(sw_nbr).port_nbr
            sw(sw_nbr).outBuffer{por} = insert(sw(sw_nbr).outBuffer{por}, message);
        end 
    elseif (message == 0.5) && (sw_nbr ~= 1)
        sw(sw_nbr).inBuffer{1} = remove_msg(sw(sw_nbr).inBuffer{1}, message);
        for por = 3:6
            sw(sw_nbr).outBuffer{por} = insert(sw(sw_nbr).outBuffer{por}, message);
        end    
    end
elseif architect == 2
    if message == 0.5
        sw(sw_nbr).inBuffer{1} = remove_msg(sw(sw_nbr).inBuffer{1}, message);
        for port = 7:sw(sw_nbr).port_nbr
            sw(sw_nbr).outBuffer{port} = insert(sw(sw_nbr).outBuffer{port}, message);
        end
    % in case of root switch asynchTM can be sent to its slave nodes as well    
    elseif (message == 0.25) && (sw_nbr == 1)
        sw(sw_nbr).inBuffer{1} = remove_msg(sw(sw_nbr).inBuffer{1}, message);
        for por = 3:sw(sw_nbr).port_nbr
            sw(sw_nbr).outBuffer{por} = insert(sw(sw_nbr).outBuffer{por}, message);
        end
    elseif (message == 0.25) && (sw_nbr ~= 1)
        sw(sw_nbr).inBuffer{1} = remove_msg(sw(sw_nbr).inBuffer{1}, message);
        for por = 3:6
            sw(sw_nbr).outBuffer{por} = insert(sw(sw_nbr).outBuffer{por}, message);
        end    
    end
elseif architect == 3
    if sw_nbr == 1
        if message == 0.5
            sw(1).inBuffer{1} = remove_msg(sw(1).inBuffer{1}, message);
            for por = 3:16
                sw(1).outBuffer{por} = insert(sw(1).outBuffer{por}, message);
            end 
        end
    end
end


%except 1(which is master node and there is no data message from that)
for i = 2:sw(sw_nbr).port_nbr
    message = get_head(sw(sw_nbr).inBuffer{i});
    if architect == 1
        % TM from parent master should be routed to slaves
        if (message == 0.5) && (i == 2)
            sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
            for por = 7:sw(sw_nbr).port_nbr
                sw(sw_nbr).outBuffer{por} = insert(sw(sw_nbr).outBuffer{por}, message);
            end
        % ap request from children should be routed to the master node    
        elseif (message == 0.5) && (i >= 3) && (i <= 6)
            sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
            sw(sw_nbr).outBuffer{1} = insert(sw(sw_nbr).outBuffer{1}, message);
        % ap request from slave nodes should be routed to the parent master
        elseif (message == 0.5) && (i >= 7)
            sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
            sw(sw_nbr).outBuffer{2} = insert(sw(sw_nbr).outBuffer{2}, message);
        %if this is data    
        elseif message >= 1
            current_sw_column = find(msg(message).SwitchInRout == sw_nbr);
            if ~isempty(current_sw_column)
                outPort = msg(message).SwitchPort(current_sw_column);
                sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
                sw(sw_nbr).outBuffer{outPort} = insert(sw(sw_nbr).outBuffer{outPort}, message);
            elseif (isempty(current_sw_column)) && (msg(message).destMasterNumber == sw_nbr)
                sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
                sw(sw_nbr).outBuffer{slave(msg(message).dest).swPortNumber} = insert(sw(sw_nbr).outBuffer{slave(msg(message).dest).swPortNumber}, message);
            end
        end
    elseif architect == 2
        %ap request from slaves, destination is master node which is port 1
        if message == 0.5
            sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
            sw(sw_nbr).outBuffer{1} = insert(sw(sw_nbr).outBuffer{1}, message);
        %global aperiodic request from slaves, send to parent master    
        elseif (message == 0.75) && (i > 6) && (sw_nbr ~= 1)
            sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
            sw(sw_nbr).outBuffer{2} = insert(sw(sw_nbr).outBuffer{2}, message);
        %global aperiodic request from children segments should be sent to master  
        elseif (message == 0.75) && (i < 7)
            sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
            sw(sw_nbr).outBuffer{1} = insert(sw(sw_nbr).outBuffer{1}, message);
        %global aperiodic request in root switch need to be sent to master
        elseif (message == 0.75) && (sw_nbr == 1)
            sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
            sw(sw_nbr).outBuffer{1} = insert(sw(sw_nbr).outBuffer{1}, message);
        %if this is data    
        elseif message >= 1
            if msg(message).gType == 0
                sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
                sw(sw_nbr).outBuffer{slave(msg(message).dest).swPortNumber} = insert(sw(sw_nbr).outBuffer{slave(msg(message).dest).swPortNumber}, message);
            elseif msg(message).gType == 1
                current_sw_column = find(msg(message).SwitchInRout == sw_nbr);
                if ~isempty(current_sw_column)
                    outPort = msg(message).SwitchPort(current_sw_column);
                    sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
                    sw(sw_nbr).outBuffer{outPort} = insert(sw(sw_nbr).outBuffer{outPort}, message);
                elseif (isempty(current_sw_column)) && (msg(message).destMasterNumber == sw_nbr)
                    sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
                    sw(sw_nbr).outBuffer{slave(msg(message).dest).swPortNumber} = insert(sw(sw_nbr).outBuffer{slave(msg(message).dest).swPortNumber}, message);
                end
            end
        end
    elseif architect == 3
        if message == 0.5
            % this is TM from parent switch
            if i == 2
                sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
                for por = 3:sw(sw_nbr).port_nbr
                    sw(sw_nbr).outBuffer{por} = insert(sw(sw_nbr).outBuffer{por}, message);
                end
            % this is ap request from slaves (or children switches)    
            else
                sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
                if sw_nbr == 1
                    sw(sw_nbr).outBuffer{1} = insert(sw(sw_nbr).outBuffer{1}, message);
                else
                    sw(sw_nbr).outBuffer{2} = insert(sw(sw_nbr).outBuffer{2}, message);
                end
            end
        elseif message >= 1
            current_sw_column = find(msg(message).SwitchInRout == sw_nbr);
            if ~isempty(current_sw_column)
                outPort = msg(message).SwitchPort(current_sw_column);
                sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
                sw(sw_nbr).outBuffer{outPort} = insert(sw(sw_nbr).outBuffer{outPort}, message);
            elseif (isempty(current_sw_column)) && (slave(msg(message).dest).segmentNumber == sw_nbr)
                sw(sw_nbr).inBuffer{i} = remove_msg(sw(sw_nbr).inBuffer{i}, message);
                sw(sw_nbr).outBuffer{slave(msg(message).dest).swPortNumber} = insert(sw(sw_nbr).outBuffer{slave(msg(message).dest).swPortNumber}, message);
            end
        end
    end
end

if architect == 2
    % get asynchTM from parent master, send to all slaves
    message = get_head(sw(sw_nbr).inBuffer{2});
    if message == 0.25
        for po = 7:sw(sw_nbr).port_nbr
            sw(sw_nbr).inBuffer{2} = remove_msg(sw(sw_nbr).inBuffer{2}, message);
            sw(sw_nbr).outBuffer{po} = insert(sw(sw_nbr).outBuffer{po}, message);
        end
    end
end

% put to output of block from the output buffer
for it = 1:sw(sw_nbr).port_nbr
    out_msg = get_head(sw(sw_nbr).outBuffer{it});
    if out_msg > 0
        block.OutputPort(it).Data = out_msg;
        sw(sw_nbr).outBuffer{it} = remove_msg(sw(sw_nbr).outBuffer{it}, out_msg);
    else
        block.OutputPort(it).Data = 0;
    end
end


function Update(block)


function Terminate(block)


