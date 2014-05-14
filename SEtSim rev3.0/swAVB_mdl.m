%---------------------------------------------------------------------
% Copyright 2013 Mohammad Ashjaei <mohammad.ashjaei@mdh.se>
% This code is written in order to simulate switched Ethernet protocols.
%---------------------------------------------------------------------

function AVB_mdl(block)

setup(block);

function setup(block)

% Register number of ports
block.NumInputPorts  = 6;
block.NumOutputPorts = 6;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
for in = 1:6
    block.InputPort(in).Dimensions        = 1;
    block.InputPort(in).DatatypeID  = 0;  % double
    block.InputPort(in).Complexity  = 'Real';
    block.InputPort(in).SamplingMode = 'Sample';
    block.InputPort(in).DirectFeedthrough = false;
end

% Override output port properties
for out = 1:6
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

% get the current master number that function runs
avb_nbr = str2num(get_param(gcb, 'avb_number'));

% data table run just in root master node, for configuration
if avb_nbr == 1
    data_table;
end



function Outputs(block)
global msg;
global avbSW;
global node;
global Rate;
global maxFrameSize;

% get the current switch number
avb_nbr = str2num(get_param(gcb, 'avb_number'));

% read the input ports and insert to input buffer if any
for p = 1:avbSW(avb_nbr).port_nbr
    if block.InputPort(p).Data > 0
        avbSW(avb_nbr).inBuffer{p} = insert(avbSW(avb_nbr).inBuffer{p}, block.InputPort(p).Data);
    end
end

% service the input buffer (route to the right output buffer)
for i = 1:avbSW(avb_nbr).port_nbr
    message = get_head(avbSW(avb_nbr).inBuffer{i});
    if message > 0
        avbSW(avb_nbr).inBuffer{i} = remove_msg(avbSW(avb_nbr).inBuffer{i}, message);
        if msg(message).class == 1
            avbSW(avb_nbr).outBufferClassA{node(msg(message).dest).swPortNumber} = insert(avbSW(avb_nbr).outBufferClassA{node(msg(message).dest).swPortNumber}, message);
        elseif msg(message).class == 2
            avbSW(avb_nbr).outBufferClassB{node(msg(message).dest).swPortNumber} = insert(avbSW(avb_nbr).outBufferClassB{node(msg(message).dest).swPortNumber}, message);
        elseif msg(message).class == 3
            avbSW(avb_nbr).outBuffer{node(msg(message).dest).swPortNumber} = insert(avbSW(avb_nbr).outBuffer{node(msg(message).dest).swPortNumber}, message);
        end
    end
end



% put to output of block from the output buffer
for it = 1:avbSW(avb_nbr).port_nbr
    
    % check if the port is busy for transmission of previous message
    if block.CurrentTime <= (avbSW(avb_nbr).timeTag{it} + avbSW(avb_nbr).busyTime{it})
        block.OutputPort(it).Data = 0;
        continue;
    end
    
    % service the buffers
    out_msg = get_head(avbSW(avb_nbr).outBufferClassA{it});
    if out_msg > 0
        if avbSW(avb_nbr).creditA{it} > 0
            block.OutputPort(it).Data = out_msg;
            avbSW(avb_nbr).busyTime{it} = msg(out_msg).exec;
            avbSW(avb_nbr).timeTag{it} = block.CurrentTime;
            avbSW(avb_nbr).outBufferClassA{it} = remove_msg(avbSW(avb_nbr).outBufferClassA{it}, out_msg);
            t = msg(out_msg).exec * 10 * Rate / 1000;
            avbSW(avb_nbr).creditA{it} = avbSW(avb_nbr).creditA{it} - (avbSW(avb_nbr).sendSlopeA{it} * t);
            if avbSW(avb_nbr).creditA{it} <= avbSW(avb_nbr).loCreditA{it}
                avbSW(avb_nbr).creditA{it} = avbSW(avb_nbr).loCreditA{it};
            end
            continue;
        end
    else
        t = maxFrameSize;
        avbSW(avb_nbr).creditA{it} = avbSW(avb_nbr).creditA{it} + (avbSW(avb_nbr).idleSlopeA{it} * t);
        if avbSW(avb_nbr).creditA{it} >= avbSW(avb_nbr).hiCreditA{it};
            avbSW(avb_nbr).creditA{it} = avbSW(avb_nbr).hiCreditA{it};
        end
        block.OutputPort(it).Data = 0;
    end
    
    out_msg = get_head(avbSW(avb_nbr).outBufferClassB{it});
    if out_msg > 0
        if avbSW(avb_nbr).creditB{it} > 0
            block.OutputPort(it).Data = out_msg;
            avbSW(avb_nbr).busyTime{it} = msg(out_msg).exec;
            avbSW(avb_nbr).timeTag{it} = block.CurrentTime;
            avbSW(avb_nbr).outBufferClassB{it} = remove_msg(avbSW(avb_nbr).outBufferClassB{it}, out_msg);
            t = msg(out_msg).exec * 10 * Rate / 1000;
            avbSW(avb_nbr).creditB{it} = avbSW(avb_nbr).creditB{it} - (avbSW(avb_nbr).sendSlopeB{it} * t);
            if avbSW(avb_nbr).creditB{it} <= avbSW(avb_nbr).loCreditB{it}
                avbSW(avb_nbr).creditB{it} = avbSW(avb_nbr).loCreditB{it};
            end
            continue;
        end
    else
        t = maxFrameSize;
        avbSW(avb_nbr).creditB{it} = avbSW(avb_nbr).creditB{it} + (avbSW(avb_nbr).idleSlopeB{it} * t);
        if avbSW(avb_nbr).creditB{it} >= avbSW(avb_nbr).hiCreditB{it};
            avbSW(avb_nbr).creditB{it} = avbSW(avb_nbr).hiCreditB{it};
        end
        block.OutputPort(it).Data = 0;
    end
    
    out_msg = get_head(avbSW(avb_nbr).outBuffer{it});
    if out_msg > 0
        block.OutputPort(it).Data = out_msg;
        avbSW(avb_nbr).busyTime{it} = msg(out_msg).exec;
        avbSW(avb_nbr).timeTag{it} = block.CurrentTime;
        avbSW(avb_nbr).outBuffer{it} = remove_msg(avbSW(avb_nbr).outBuffer{it}, out_msg);
    else
        block.OutputPort(it).Data = 0;
    end

end



function Update(block)


function Terminate(block)


