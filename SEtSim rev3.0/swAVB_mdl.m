%---------------------------------------------------------------------
% Copyright 2013 Mohammad Ashjaei <mohammad.ashjaei@mdh.se>
% This code is written in order to simulate switched Ethernet protocols.
%---------------------------------------------------------------------

function swAVB_mdl(block)

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
global sampleTime;

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
        current_sw_column = find(msg(message).SwitchInRout == avb_nbr);
        if ~isempty(current_sw_column)
            outPort = msg(message).SwitchPort(current_sw_column);
            avbSW(avb_nbr).inBuffer{i} = remove_msg(avbSW(avb_nbr).inBuffer{i}, message);
            if msg(message).class == 1
                avbSW(avb_nbr).outBufferClassA{outPort} = insert(avbSW(avb_nbr).outBufferClassA{outPort}, message);
            elseif msg(message).class == 2
                avbSW(avb_nbr).outBufferClassB{outPort} = insert(avbSW(avb_nbr).outBufferClassB{outPort}, message);
            elseif msg(message).class == 3
                avbSW(avb_nbr).outBuffer{outPort} = insert(avbSW(avb_nbr).outBuffer{outPort}, message);
            end
        elseif (isempty(current_sw_column)) && (msg(message).destMasterNumber == avb_nbr)
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
end



% put to output of block from the output buffer
for it = 1:avbSW(avb_nbr).port_nbr

    % handling credit A
    messageA = get_head(avbSW(avb_nbr).outBufferClassA{it});
    if messageA <= 0
        avbSW(avb_nbr).creditA{it} = 0;
    else
        if avbSW(avb_nbr).creditA{it} >= 0
            if avbSW(avb_nbr).freePort(it) == 0
                avbSW(avb_nbr).outBuffer{it} = insert(avbSW(avb_nbr).outBuffer{it}, messageA);
                avbSW(avb_nbr).creditA{it} = avbSW(avb_nbr).creditA{it} - (msg(messageA).exec * 10 * Rate / 1000 * avbSW(avb_nbr).sendSlopeA{it});
                avbSW(avb_nbr).outBufferClassA{it} = remove_msg(avbSW(avb_nbr).outBufferClassA{it}, messageA);
                avbSW(avb_nbr).freePort(it) = 1;
                avbSW(avb_nbr).currentMsg(it) = messageA;
            elseif avbSW(avb_nbr).freePort(it) == 1
                avbSW(avb_nbr).creditA{it} = avbSW(avb_nbr).creditA{it} + sampleTime * avbSW(avb_nbr).idleSlopeA{it};
            end
        else
            avbSW(avb_nbr).creditA{it} = avbSW(avb_nbr).creditA{it} + sampleTime * avbSW(avb_nbr).idleSlopeA{it};
        end
    end
    
    % handling credit B
    messageB = get_head(avbSW(avb_nbr).outBufferClassB{it});
    if messageB <= 0
        avbSW(avb_nbr).creditB{it} = 0;
    else
        if avbSW(avb_nbr).creditB{it} >= 0
            if avbSW(avb_nbr).freePort(it) == 0
                avbSW(avb_nbr).outBuffer{it} = insert(avbSW(avb_nbr).outBuffer{it}, messageB);
                avbSW(avb_nbr).creditB{it} = avbSW(avb_nbr).creditB{it} - msg(messageB).exec * 10 * Rate / 1000 * avbSW(avb_nbr).sendSlopeB{it};
                avbSW(avb_nbr).outBufferClassB{it} = remove_msg(avbSW(avb_nbr).outBufferClassB{it}, messageB);
                avbSW(avb_nbr).freePort(it) = 1;
                avbSW(avb_nbr).currentMsg(it) = messageB;
            elseif avbSW(avb_nbr).freePort(it) == 1
                avbSW(avb_nbr).creditB{it} = avbSW(avb_nbr).creditB{it} + sampleTime * avbSW(avb_nbr).idleSlopeB{it};
            end
        else
            avbSW(avb_nbr).creditB{it} = avbSW(avb_nbr).creditB{it} + sampleTime * avbSW(avb_nbr).idleSlopeB{it};
        end
    end
    
    % handling traffic BE
    messageBE = get_head(avbSW(avb_nbr).outBufferClassBE{it});
    if messageBE > 0
        if avbSW(avb_nbr).freePort(it) == 0
            avbSW(avb_nbr).outBuffer{it} = insert(avbSW(avb_nbr).outBuffer{it}, messageBE);
            avbSW(avb_nbr).outBufferClassBE{it} = remove_msg(avbSW(avb_nbr).outBufferClassBE{it}, messageBE);
            avbSW(avb_nbr).freePort(it) = 1;
            avbSW(avb_nbr).currentMsg(it) = messageBE;
        end
    end
       
    if avbSW(avb_nbr).currentMsg(it) > 0
        msg(avbSW(avb_nbr).currentMsg(it)).execDyn = msg(avbSW(avb_nbr).currentMsg(it)).execDyn - sampleTime;
        if msg(avbSW(avb_nbr).currentMsg(it)).execDyn < 0
            avbSW(avb_nbr).freePort(it) = 0;
            msg(avbSW(avb_nbr).currentMsg(it)).delay = msg(avbSW(avb_nbr).currentMsg(it)).delay + msg(avbSW(avb_nbr).currentMsg(it)).exec;
        end
    end
    
    out_msg = get_head(avbSW(avb_nbr).outBuffer{it});
    avbSW(avb_nbr).outBuffer{it} = remove_msg(avbSW(avb_nbr).outBuffer{it}, out_msg);
    block.OutputPort(it).Data = out_msg;
    
end



function Update(block)


function Terminate(block)


