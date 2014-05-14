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

% get the node number    
node_nbr = str2num(get_param(gcb, 'node_number'));

% compute the activation time of the messages belog to this node
for i = 1:node(node_nbr).msg_nbr
    if msg(i).source == node_nbr
        if block.CurrentTime - msg(i).tickCount >= (msg(i).period / 10)
            msg(i).tickCount = block.CurrentTime;
            msg(i).readyTime = block.CurrentTime;
            ready_time_buffer{i} = insert(ready_time_buffer{i}, msg(i).readyTime);
            node(node_nbr).output = insert(node(node_nbr).output, i); 
        end
    end
end

% send messages
block.OutputPort(1).Data = get_head(node(node_nbr).output);
node(node_nbr).output = remove_msg(node(node_nbr).output, get_head(node(node_nbr).output));

% read from input
input = block.InputPort(1).Data;
if input > 0
     msg(input).receiveTime = block.CurrentTime + msg(input).exec;
     receive_time_buffer{input} = insert(receive_time_buffer{input}, msg(input).receiveTime);
end



function Update(block)

function Terminate(block)


