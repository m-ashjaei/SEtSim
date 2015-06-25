%---------------------------------------------------------------------
% Copyright 2013 Mohammad Ashjaei <mohammad.ashjaei@mdh.se>
% This code is written in order to simulate switched Ethernet protocols.
%---------------------------------------------------------------------

function node(block)

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

global node;
global msg;
global ready_time_buffer;
global receive_time_buffer;
global sampleTime;
global Rate;

% get the node number    
node_nbr = str2num(get_param(gcb, 'node_number'));

% update the FIFO queue in the node
for i = 1:node(node_nbr).msg_nbr
    if msg(i).source == node_nbr
        if block.CurrentTime - msg(i).tickCount >= (msg(i).period / 10)
            msg(i).tickCount = block.CurrentTime;
            msg(i).readyTime = block.CurrentTime;
            ready_time_buffer{i} = insert(ready_time_buffer{i}, msg(i).readyTime);
            if msg(i).class == 1
                node(node_nbr).outBufferClassA = insert(node(node_nbr).outBufferClassA, msg(i).id);
            elseif msg(i).class == 2
                node(node_nbr).outBufferClassB = insert(node(node_nbr).outBufferClassB, msg(i).id);
            elseif msg(i).class == 3
                node(node_nbr).outBufferClassBE = insert(node(node_nbr).outBufferClassBE, msg(i).id);
            end
        end
    end
end

% if the queue is empty set the credit to zero
% otherwise, we check the credit if we have to send
% if we dont have credit, the message stays in the queue
messageA = get_head(node(node_nbr).outBufferClassA);
if messageA <= 0
    node(node_nbr).creditA = 0;
else
    if node(node_nbr).creditA >= 0
        if node(node_nbr).freePort == 0
            node(node_nbr).output = insert(node(node_nbr).output, messageA);
            node(node_nbr).creditA = node(node_nbr).creditA - (msg(messageA).exec * 10 * Rate / 1000 * node(node_nbr).sendSlopeA);
            node(node_nbr).outBufferClassA = remove_msg(node(node_nbr).outBufferClassA, messageA);
            node(node_nbr).freePort = 1;
            node(node_nbr).currentMsg = messageA;
        elseif node(node_nbr).freePort == 1
            node(node_nbr).creditA = node(node_nbr).creditA + sampleTime * node(node_nbr).idleSlopeA;
        end
    else
        node(node_nbr).creditA = node(node_nbr).creditA + sampleTime * node(node_nbr).idleSlopeA;
    end
end

messageB = get_head(node(node_nbr).outBufferClassB);
if messageB <= 0
    node(node_nbr).creditB = 0;
else
    if node(node_nbr).creditB >= 0
        if node(node_nbr).freePort == 0
            node(node_nbr).output = insert(node(node_nbr).output, messageB);
            node(node_nbr).creditB = node(node_nbr).creditB - msg(messageB).exec * 10 * Rate / 1000 * node(node_nbr).sendSlopeB;
            node(node_nbr).outBufferClassB = remove_msg(node(node_nbr).outBufferClassB, messageB);
            node(node_nbr).freePort = 1;
            node(node_nbr).currentMsg = messageB;
        elseif node(node_nbr).freePort == 1
            node(node_nbr).creditB = node(node_nbr).creditB + sampleTime * node(node_nbr).idleSlopeB;
        end
    else
        node(node_nbr).creditB = node(node_nbr).creditB + sampleTime * node(node_nbr).idleSlopeB;
    end
end

messageBE = get_head(node(node_nbr).outBufferClassBE);
if messageBE > 0
    if node(node_nbr).freePort == 0
        node(node_nbr).output = insert(node(node_nbr).output, messageBE);
        node(node_nbr).outBufferClassBE = remove_msg(node(node_nbr).outBufferClassBE, messageBE);
        node(node_nbr).freePort = 1;
        node(node_nbr).currentMsg = messageBE;
    end
end


if node(node_nbr).currentMsg > 0
    msg(node(node_nbr).currentMsg).execDyn = msg(node(node_nbr).currentMsg).execDyn - sampleTime;
    if msg(node(node_nbr).currentMsg).execDyn < 0
        node(node_nbr).freePort = 0;
        msg(node(node_nbr).currentMsg).delay = msg(node(node_nbr).currentMsg).exec;
    end
end


% send messages
block.OutputPort(1).Data = get_head(node(node_nbr).output);
node(node_nbr).output = remove_msg(node(node_nbr).output, get_head(node(node_nbr).output));

% read from input
input = block.InputPort(1).Data;
if input > 0
    msg(input).receiveTime = block.CurrentTime + msg(input).delay + msg(input).exec;
    receive_time_buffer{input} = insert(receive_time_buffer{input}, msg(input).receiveTime);
end



function Update(block)

function Terminate(block)


