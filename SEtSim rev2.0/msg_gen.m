% this function generates the messages the same as the AFDX (military)

function [message_nbr, message] = msg_gen(EC)

%structure to show the slave numbers belong to which master
master{1} = [1 10];
master{2} = [11 20];
master{3} = [21 30];
master{4} = [31 40];
master{5} = [41 50];
master{6} = [51 60];
master{7} = [61 70];
master{8} = [71 80];
master{9} = [81 90];
master{10} = [91 100];

%structure to select the possible path in the network (switch numbers)
sel{1} = [5 2];
sel{2} = [6 2];
sel{3} = [7 2];
sel{4} = [2 1];
sel{5} = [3 1];
sel{6} = [1 4];
sel{7} = [8 4];
sel{8} = [9 4];
sel{9} = [10 4];
sel{10} = [4 1];
sel{11} = [1 2];
sel{12} = [5 2 1];
sel{13} = [6 2 1];
sel{14} = [7 2 1];
sel{15} = [2 1 4];
sel{16} = [3 1 4];
sel{17} = [8 4 1];
sel{18} = [9 4 1];
sel{19} = [10 4 1];
sel{20} = [4 1 2];
sel{21} = [5 2 1 4];
sel{22} = [6 2 1 4];
sel{23} = [7 2 1 4];
sel{24} = [8 4 1 2];
sel{25} = [9 4 1 2];
sel{26} = [10 4 1 2];

%number of messages to generate
syncPrio1 = 698;%349;
syncPrio2 = 60;%30;
syncPrio3 = 56;%28;
syncPrio4 = 630;%315;
syncTotal = syncPrio1 + syncPrio2 + syncPrio3 + syncPrio4;
asyncPrio1 = 106;%53;
asyncPrio2 = 420;%210;
asyncPrio3 = 215;%107;
asyncPrio4 = 360;%180;
asyncTotal = asyncPrio1 + asyncPrio2 + asyncPrio3 + asyncPrio4;

%generate periodic msg with prio = 1
for i = 1:syncPrio1
    message(i).id = i;
    message(i).prio = 1;
    message(i).exec = 0.000944; %exec between 0.005 to 0.015
    message(i).pType = 0;
    message(i).period = ceil(20 / EC);
    message(i).deadline = message(i).period;
    message(i).dynPeriod = 0;
    
    message(i).tickCount = message(i).period - 1;
    message(i).readyTime = 0;
    message(i).receiveTime = 0;

    message(i).defNum = 0;
    message(i).part = 0;
    message(i).refMsgID = i;
    message(i).cluster = 0;
    message(i).ClParentMaster = 0;
    message(i).offset = 0;
    
    count = randi([0 4], 1, 1);
    
    if count == 0
        message(i).SwitchInRout = 0;
        message(i).SwitchPort = 0;
        message(i).sourceMasterNumber = randi([1 10], 1, 1);
        message(i).destMasterNumber = message(i).sourceMasterNumber;
        message(i).gType = 0;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1); 
        message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        while message(i).source == message(i).dest
            message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        end
    elseif count == 1
        message(i).SwitchInRout = randi([1 10], 1, 1);
        message(i).sourceMasterNumber = message(i).SwitchInRout;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch message(i).SwitchInRout
            case 1
                message(i).SwitchPort = randi([3 5], 1, 1);
                if message(i).SwitchPort == 3
                    message(i).destMasterNumber = 2;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 3;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 4;
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
                message(i).gType = 0;
            case 2
                message(i).SwitchPort = randi([2 5], 1, 1);
                if message(i).SwitchPort == 2
                    message(i).destMasterNumber = 1;
                    message(i).gType = 0;
                elseif message(i).SwitchPort == 3
                    message(i).destMasterNumber = 5;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 6;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 7;
                    message(i).gType = 1;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 1;
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                message(i).SwitchPort = randi([2 5], 1, 1);
                if message(i).SwitchPort == 2
                    message(i).destMasterNumber = 1;
                    message(i).gType = 0;
                elseif message(i).SwitchPort == 3
                    message(i).destMasterNumber = 8;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 9;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 10;
                    message(i).gType = 1;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 5
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 6
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 7
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 8
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 9
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 10
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 2
        x = randi([1 11], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 1
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                elseif y == 2
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 6;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 7;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 2
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                elseif y == 2
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 5;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 7;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                elseif y == 2
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 5;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 6;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 5
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 6
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 7
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 8
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 9
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
            case 10
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 11
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [3 5];
                    message(i).destMasterNumber = 7;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 3
        x = randi([12 20], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 12
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 13
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 14
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 15
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 16
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 17
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 18
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 19
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 20
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 3 5];
                    message(i).destMasterNumber = 7;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 4
        x = randi([21 26], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 21
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 22
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 23
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 24
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 25
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 26
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    end
%end for       
end

%generate periodic msg with prio = 2
for j = 1:syncPrio2
    i = j + syncPrio1;
    
    message(i).id = i;
    message(i).prio = 2;
    message(i).exec = 0.000944; %exec between 0.005 to 0.015
    message(i).pType = 0;
    message(i).period = ceil(40 / EC);
    message(i).deadline = message(i).period;
    message(i).dynPeriod = 0;
    
    message(i).tickCount = message(i).period - 1;
    message(i).readyTime = 0;
    message(i).receiveTime = 0;

    message(i).defNum = 0;
    message(i).part = 0;
    message(i).refMsgID = i;
    message(i).cluster = 0;
    message(i).ClParentMaster = 0;
    message(i).offset = 0;
    
    count = randi([0 4], 1, 1);
    
    if count == 0
        message(i).SwitchInRout = 0;
        message(i).SwitchPort = 0;
        message(i).sourceMasterNumber = randi([1 10], 1, 1);
        message(i).destMasterNumber = message(i).sourceMasterNumber;
        message(i).gType = 0;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1); 
        message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        while message(i).source == message(i).dest
            message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        end
    elseif count == 1
        message(i).SwitchInRout = randi([1 10], 1, 1);
        message(i).sourceMasterNumber = message(i).SwitchInRout;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch message(i).SwitchInRout
            case 1
                message(i).SwitchPort = randi([3 5], 1, 1);
                if message(i).SwitchPort == 3
                    message(i).destMasterNumber = 2;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 3;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 4;
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
                message(i).gType = 0;
            case 2
                message(i).SwitchPort = randi([2 5], 1, 1);
                if message(i).SwitchPort == 2
                    message(i).destMasterNumber = 1;
                    message(i).gType = 0;
                elseif message(i).SwitchPort == 3
                    message(i).destMasterNumber = 5;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 6;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 7;
                    message(i).gType = 1;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 1;
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                message(i).SwitchPort = randi([2 5], 1, 1);
                if message(i).SwitchPort == 2
                    message(i).destMasterNumber = 1;
                    message(i).gType = 0;
                elseif message(i).SwitchPort == 3
                    message(i).destMasterNumber = 8;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 9;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 10;
                    message(i).gType = 1;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 5
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 6
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 7
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 8
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 9
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 10
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 2
        x = randi([1 11], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 1
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                elseif y == 2
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 6;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 7;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 2
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                elseif y == 2
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 5;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 7;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                elseif y == 2
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 5;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 6;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 5
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 6
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 7
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 8
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 9
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
            case 10
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 11
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [3 5];
                    message(i).destMasterNumber = 7;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 3
        x = randi([12 20], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 12
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 13
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 14
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 15
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 16
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 17
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 18
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 19
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 20
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 3 5];
                    message(i).destMasterNumber = 7;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 4
        x = randi([21 26], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 21
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 22
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 23
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 24
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 25
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 26
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    end
%end for    
end

%generate periodic msg with prio = 3
for j = 1:syncPrio3
    i = j + syncPrio1 + syncPrio2;
    
    message(i).id = i;
    message(i).prio = 3;
    message(i).exec = 0.000944; %exec between 0.005 to 0.015
    message(i).pType = 0;
    message(i).period = ceil(80 / EC);
    message(i).deadline = message(i).period;
    message(i).dynPeriod = 0;
    
    message(i).tickCount = message(i).period - 1;
    message(i).readyTime = 0;
    message(i).receiveTime = 0;

    message(i).defNum = 0;
    message(i).part = 0;
    message(i).refMsgID = i;
    message(i).cluster = 0;
    message(i).ClParentMaster = 0;
    message(i).offset = 0;
    
    count = randi([0 4], 1, 1);
    
    if count == 0
        message(i).SwitchInRout = 0;
        message(i).SwitchPort = 0;
        message(i).sourceMasterNumber = randi([1 10], 1, 1);
        message(i).destMasterNumber = message(i).sourceMasterNumber;
        message(i).gType = 0;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1); 
        message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        while message(i).source == message(i).dest
            message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        end
    elseif count == 1
        message(i).SwitchInRout = randi([1 10], 1, 1);
        message(i).sourceMasterNumber = message(i).SwitchInRout;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch message(i).SwitchInRout
            case 1
                message(i).SwitchPort = randi([3 5], 1, 1);
                if message(i).SwitchPort == 3
                    message(i).destMasterNumber = 2;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 3;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 4;
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
                message(i).gType = 0;
            case 2
                message(i).SwitchPort = randi([2 5], 1, 1);
                if message(i).SwitchPort == 2
                    message(i).destMasterNumber = 1;
                    message(i).gType = 0;
                elseif message(i).SwitchPort == 3
                    message(i).destMasterNumber = 5;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 6;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 7;
                    message(i).gType = 1;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 1;
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                message(i).SwitchPort = randi([2 5], 1, 1);
                if message(i).SwitchPort == 2
                    message(i).destMasterNumber = 1;
                    message(i).gType = 0;
                elseif message(i).SwitchPort == 3
                    message(i).destMasterNumber = 8;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 9;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 10;
                    message(i).gType = 1;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 5
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 6
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 7
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 8
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 9
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 10
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 2
        x = randi([1 11], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 1
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                elseif y == 2
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 6;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 7;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 2
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                elseif y == 2
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 5;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 7;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                elseif y == 2
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 5;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 6;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 5
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 6
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 7
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 8
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 9
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
            case 10
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 11
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [3 5];
                    message(i).destMasterNumber = 7;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 3
        x = randi([12 20], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 12
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 13
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 14
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 15
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 16
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 17
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 18
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 19
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 20
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 3 5];
                    message(i).destMasterNumber = 7;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 4
        x = randi([21 26], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 21
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 22
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 23
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 24
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 25
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 26
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    end
    
% end for    
end


%generate periodic msg with prio = 4
for j = 1:syncPrio4
    i = j + syncPrio1 + syncPrio2 + syncPrio3;
    
    message(i).id = i;
    message(i).prio = 4;
    message(i).exec = 0.012144; %exec between 0.005 to 0.015
    message(i).pType = 0;
    message(i).period = ceil(160 / EC);
    message(i).deadline = message(i).period;
    message(i).dynPeriod = 0;
    
    message(i).tickCount = message(i).period - 1;
    message(i).readyTime = 0;
    message(i).receiveTime = 0;

    message(i).defNum = 0;
    message(i).part = 0;
    message(i).refMsgID = i;
    message(i).cluster = 0;
    message(i).ClParentMaster = 0;
    message(i).offset = 0;
    
    count = randi([0 4], 1, 1);
    
    if count == 0
        message(i).SwitchInRout = 0;
        message(i).SwitchPort = 0;
        message(i).sourceMasterNumber = randi([1 10], 1, 1);
        message(i).destMasterNumber = message(i).sourceMasterNumber;
        message(i).gType = 0;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1); 
        message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        while message(i).source == message(i).dest
            message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        end
    elseif count == 1
        message(i).SwitchInRout = randi([1 10], 1, 1);
        message(i).sourceMasterNumber = message(i).SwitchInRout;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch message(i).SwitchInRout
            case 1
                message(i).SwitchPort = randi([3 5], 1, 1);
                if message(i).SwitchPort == 3
                    message(i).destMasterNumber = 2;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 3;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 4;
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
                message(i).gType = 0;
            case 2
                message(i).SwitchPort = randi([2 5], 1, 1);
                if message(i).SwitchPort == 2
                    message(i).destMasterNumber = 1;
                    message(i).gType = 0;
                elseif message(i).SwitchPort == 3
                    message(i).destMasterNumber = 5;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 6;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 7;
                    message(i).gType = 1;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 1;
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                message(i).SwitchPort = randi([2 5], 1, 1);
                if message(i).SwitchPort == 2
                    message(i).destMasterNumber = 1;
                    message(i).gType = 0;
                elseif message(i).SwitchPort == 3
                    message(i).destMasterNumber = 8;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 9;
                    message(i).gType = 1;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 10;
                    message(i).gType = 1;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 5
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 6
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 7
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 8
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 9
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 10
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 2
        x = randi([1 11], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 1
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                elseif y == 2
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 6;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 7;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 2
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                elseif y == 2
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 5;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 7;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                elseif y == 2
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 5;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 6;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 5
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 6
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 7
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 8
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 9
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
            case 10
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 11
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [3 5];
                    message(i).destMasterNumber = 7;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 3
        x = randi([12 20], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 12
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 13
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 14
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 15
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 16
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 17
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 18
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 19
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 20
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 3 5];
                    message(i).destMasterNumber = 7;    
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 4
        x = randi([21 26], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 21
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 22
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 23
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 24
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 7;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 25
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 26
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    end
    
%end for    
end

%generate aperiodic msg with prio = 1
for j = 1:asyncPrio1
    i = j + syncTotal;
    
    message(i).id = i;
    message(i).prio = 1;
    message(i).exec = 0.000576; %exec between 0.005 to 0.015
    message(i).pType = 1;
    message(i).period = ceil(20 / EC);
    message(i).deadline = message(i).period;
    message(i).dynPeriod = message(i).period;
    
    message(i).tickCount = message(i).period - 1;
    message(i).readyTime = 0;
    message(i).receiveTime = 0;

    message(i).defNum = 0;
    message(i).part = 0;
    message(i).refMsgID = i;
    message(i).offset = 0;
    message(i).cluster = 0;
    message(i).ClParentMaster = 0;
    
    count = randi([0 1], 1, 1);
    
    if count == 0
        message(i).SwitchInRout = 0;
        message(i).SwitchPort = 0;
        message(i).sourceMasterNumber = randi([1 10], 1, 1);
        message(i).destMasterNumber = message(i).sourceMasterNumber;
        message(i).gType = 0;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1); 
        message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        while message(i).source == message(i).dest
            message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        end
    elseif count == 1
        message(i).SwitchInRout = randi([1 4], 1, 1);
        message(i).sourceMasterNumber = message(i).SwitchInRout;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch message(i).SwitchInRout
            case 1
                message(i).SwitchPort = randi([3 5], 1, 1);
                if message(i).SwitchPort == 3
                    message(i).destMasterNumber = 2;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 3;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 4;
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
                message(i).gType = 0;
            case 2
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 1;
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 1;
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 1;
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);   
        end
    end
        
%end for    
end


%generate aperiodic msg with prio = 2
for j = 1:asyncPrio2
    i = j + syncTotal + asyncPrio1;
    
    message(i).id = i;
    message(i).prio = 2;
    message(i).exec = 0.000944; %exec between 0.005 to 0.015
    message(i).pType = 1;
    message(i).period = ceil(20 / EC);
    message(i).deadline = message(i).period;
    message(i).dynPeriod = message(i).period;
    
    message(i).tickCount = message(i).period - 1;
    message(i).readyTime = 0;
    message(i).receiveTime = 0;

    message(i).defNum = 0;
    message(i).part = 0;
    message(i).refMsgID = i;
    message(i).offset = 0;
    message(i).cluster = 0;
    message(i).ClParentMaster = 0;
    
    count = randi([0 4], 1, 1);
    
    if count == 0
        message(i).SwitchInRout = 0;
        message(i).SwitchPort = 0;
        message(i).sourceMasterNumber = randi([1 10], 1, 1);
        message(i).destMasterNumber = message(i).sourceMasterNumber;
        message(i).gType = 0;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1); 
        message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        while message(i).source == message(i).dest
            message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        end
    elseif count == 1
        message(i).SwitchInRout = randi([1 10], 1, 1);
        message(i).sourceMasterNumber = message(i).SwitchInRout;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch message(i).SwitchInRout
            case 1
                message(i).SwitchPort = randi([3 5], 1, 1);
                if message(i).SwitchPort == 3
                    message(i).destMasterNumber = 2;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 3;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 4;
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
                message(i).gType = 0;
            case 2
                message(i).SwitchPort = randi([2 5], 1, 1);
                if message(i).SwitchPort == 2
                    message(i).destMasterNumber = 1;
                    message(i).gType = 0;
                elseif message(i).SwitchPort == 3
                    message(i).destMasterNumber = 5;
                    message(i).gType = 1;
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 6;
                    message(i).gType = 1;
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 7;
                    message(i).gType = 1;    
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 1;
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                message(i).SwitchPort = randi([2 5], 1, 1);
                if message(i).SwitchPort == 2
                    message(i).destMasterNumber = 1;
                    message(i).gType = 0;
                elseif message(i).SwitchPort == 3
                    message(i).destMasterNumber = 8;
                    message(i).gType = 1;
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 9;
                    message(i).gType = 1;
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 10;
                    message(i).gType = 1;    
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 5
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 6
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 7
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 8
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 9
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 10
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 2
        x = randi([1 11], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 1
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                    message(i).cluster = 2;
                    message(i).ClParentMaster = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 6;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 7;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 2
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                    message(i).cluster = 2;
                    message(i).ClParentMaster = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 5;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 7;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                    message(i).cluster = 2;
                    message(i).ClParentMaster = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 5;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 6;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 5
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 6
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 7
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 8
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 9
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
            case 10
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 11
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [3 5];
                    message(i).destMasterNumber = 7;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 3
        x = randi([12 20], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 12
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 13
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 14
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 15
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 16
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 17
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 18
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 19
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 20
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 3 5];
                    message(i).destMasterNumber = 7;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 4
        x = randi([21 26], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 21
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 22
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 23
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 24
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 25
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 26
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    end
    
%end for    
end

%generate aperiodic msg with prio = 3
for j = 1:asyncPrio3
    i = j + syncTotal + asyncPrio1 + asyncPrio2;
    
    message(i).id = i;
    message(i).prio = 3;
    message(i).exec = 0.000944; %exec between 0.005 to 0.015
    message(i).pType = 1;
    message(i).period = ceil(20 / EC);
    message(i).deadline = message(i).period;
    message(i).dynPeriod = message(i).period;
    
    message(i).tickCount = message(i).period - 1;
    message(i).readyTime = 0;
    message(i).receiveTime = 0;

    message(i).defNum = 0;
    message(i).part = 0;
    message(i).refMsgID = i;
    message(i).offset = 0;
    message(i).cluster = 0;
    message(i).ClParentMaster = 0;
    
    count = randi([0 4], 1, 1);
    
    if count == 0
        message(i).SwitchInRout = 0;
        message(i).SwitchPort = 0;
        message(i).sourceMasterNumber = randi([1 10], 1, 1);
        message(i).destMasterNumber = message(i).sourceMasterNumber;
        message(i).gType = 0;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1); 
        message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        while message(i).source == message(i).dest
            message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        end
    elseif count == 1
        message(i).SwitchInRout = randi([1 10], 1, 1);
        message(i).sourceMasterNumber = message(i).SwitchInRout;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch message(i).SwitchInRout
            case 1
                message(i).SwitchPort = randi([3 5], 1, 1);
                if message(i).SwitchPort == 3
                    message(i).destMasterNumber = 2;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 3;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 4;
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
                message(i).gType = 0;
            case 2
                message(i).SwitchPort = randi([2 5], 1, 1);
                if message(i).SwitchPort == 2
                    message(i).destMasterNumber = 1;
                    message(i).gType = 0;
                elseif message(i).SwitchPort == 3
                    message(i).destMasterNumber = 5;
                    message(i).gType = 1;
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 6;
                    message(i).gType = 1;
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 7;
                    message(i).gType = 1;    
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 1;
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                message(i).SwitchPort = randi([2 5], 1, 1);
                if message(i).SwitchPort == 2
                    message(i).destMasterNumber = 1;
                    message(i).gType = 0;
                elseif message(i).SwitchPort == 3
                    message(i).destMasterNumber = 8;
                    message(i).gType = 1;
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 9;
                    message(i).gType = 1;
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 10;
                    message(i).gType = 1;    
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 5
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 6
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 7
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 8
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 9
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 10
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 2
        x = randi([1 11], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 1
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                    message(i).cluster = 2;
                    message(i).ClParentMaster = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 6;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 7;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 2
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                    message(i).cluster = 2;
                    message(i).ClParentMaster = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 5;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 7;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                    message(i).cluster = 2;
                    message(i).ClParentMaster = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 5;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 6;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 5
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 6
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 7
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 8
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 9
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
            case 10
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 11
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [3 5];
                    message(i).destMasterNumber = 7;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 3
        x = randi([12 20], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 12
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 13
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 14
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 15
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 16
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 17
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 18
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 19
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 20
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 3 5];
                    message(i).destMasterNumber = 7;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 4
        x = randi([21 26], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 21
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 22
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 23
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 24
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 25
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 26
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    end
    
%end for
end

%generate aperiodic msg with prio = 4
%we generate these messages as internal messages, not external type
for j = 1:asyncPrio4
    i = j + syncTotal + asyncPrio1 + asyncPrio2 + asyncPrio3;
    
    message(i).id = i;
    message(i).prio = 4;
    message(i).exec = 0.0121; %exec between 0.005 to 0.015
    message(i).pType = 1;
    message(i).period = ceil(20 / EC);
    message(i).deadline = message(i).period;
    message(i).dynPeriod = message(i).period;
    
    message(i).tickCount = message(i).period - 1;
    message(i).readyTime = 0;
    message(i).receiveTime = 0;

    message(i).defNum = 0;
    message(i).part = 0;
    message(i).refMsgID = i;
    message(i).offset = 0;
    message(i).cluster = 0;
    message(i).ClParentMaster = 0;
    
    count = randi([0 4], 1, 1);
    
    if count == 0
        message(i).SwitchInRout = 0;
        message(i).SwitchPort = 0;
        message(i).sourceMasterNumber = randi([1 10], 1, 1);
        message(i).destMasterNumber = message(i).sourceMasterNumber;
        message(i).gType = 0;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1); 
        message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        while message(i).source == message(i).dest
            message(i).dest = randi(master{message(i).destMasterNumber},1,1);
        end
    elseif count == 1
        message(i).SwitchInRout = randi([1 10], 1, 1);
        message(i).sourceMasterNumber = message(i).SwitchInRout;
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch message(i).SwitchInRout
            case 1
                message(i).SwitchPort = randi([3 5], 1, 1);
                if message(i).SwitchPort == 3
                    message(i).destMasterNumber = 2;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 3;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 4;
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
                message(i).gType = 0;
            case 2
                message(i).SwitchPort = randi([2 5], 1, 1);
                if message(i).SwitchPort == 2
                    message(i).destMasterNumber = 1;
                    message(i).gType = 0;
                elseif message(i).SwitchPort == 3
                    message(i).destMasterNumber = 5;
                    message(i).gType = 1;
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 6;
                    message(i).gType = 1;
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 7;
                    message(i).gType = 1;    
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 1;
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                message(i).SwitchPort = randi([2 5], 1, 1);
                if message(i).SwitchPort == 2
                    message(i).destMasterNumber = 1;
                    message(i).gType = 0;
                elseif message(i).SwitchPort == 3
                    message(i).destMasterNumber = 8;
                    message(i).gType = 1;
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                elseif message(i).SwitchPort == 4
                    message(i).destMasterNumber = 9;
                    message(i).gType = 1;
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                elseif message(i).SwitchPort == 5
                    message(i).destMasterNumber = 10;
                    message(i).gType = 1;    
                    message(i).cluster = 1;
                    message(i).ClParentMaster = 1;
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 5
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 6
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 7
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 2;
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 8
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 9
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 10
                message(i).SwitchPort = 2;
                message(i).destMasterNumber = 4;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 2
        x = randi([1 11], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 1
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                    message(i).cluster = 2;
                    message(i).ClParentMaster = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 6;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 7;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 2
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                    message(i).cluster = 2;
                    message(i).ClParentMaster = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 5;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 7;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 3
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2];
                    message(i).destMasterNumber = 1;
                    message(i).gType = 1;
                    message(i).cluster = 2;
                    message(i).ClParentMaster = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 5;
                    message(i).gType = 0;
                elseif y == 3
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 6;
                    message(i).gType = 0;    
                end
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 4
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 5
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 6
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 7
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 8
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 9
                message(i).SwitchPort = [2 2];
                message(i).destMasterNumber = 1;
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
            case 10
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 0;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 11
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [3 5];
                    message(i).destMasterNumber = 7;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 3
        x = randi([12 20], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 12
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 13
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 14
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5];
                    message(i).destMasterNumber = 4;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 15
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 16
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 5 5];
                    message(i).destMasterNumber = 10;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 17
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 18
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 19
                y = randi([1 2], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3];
                    message(i).destMasterNumber = 2;
                elseif y == 2
                    message(i).SwitchPort = [2 2 4];
                    message(i).destMasterNumber = 3;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 20
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 3 5];
                    message(i).destMasterNumber = 7;    
                end
                message(i).gType = 1;
                message(i).cluster = 1;
                message(i).ClParentMaster = 1;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    elseif count == 4
        x = randi([21 26], 1, 1);
        message(i).SwitchInRout = sel{x};
        message(i).sourceMasterNumber = message(i).SwitchInRout(1);
        message(i).source = randi(master{message(i).sourceMasterNumber},1,1);
        switch x
            case 21
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 22
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 23
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 5 3];
                    message(i).destMasterNumber = 8;
                elseif y == 2
                    message(i).SwitchPort = [2 2 5 4];
                    message(i).destMasterNumber = 9;
                elseif y == 3
                    message(i).SwitchPort = [2 2 5 5];
                    message(i).destMasterNumber = 10;
                end
                message(i).gType = 1;
                message(i).cluster = 2;
                message(i).ClParentMaster = 2;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 24
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 25
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);
            case 26
                y = randi([1 3], 1, 1);
                if y == 1
                    message(i).SwitchPort = [2 2 3 3];
                    message(i).destMasterNumber = 5;
                elseif y == 2
                    message(i).SwitchPort = [2 2 3 4];
                    message(i).destMasterNumber = 6;
                elseif y == 3
                    message(i).SwitchPort = [2 2 3 5];
                    message(i).destMasterNumber = 7;
                end
                message(i).gType = 1;
                message(i).cluster = 3;
                message(i).ClParentMaster = 4;
                message(i).dest = randi(master{message(i).destMasterNumber},1,1);    
        end
    end
    
%end for
end

% %some changes due to JSA evaluation part
% message(10).exec = 0.005;
% message(10).gType = 0;
% message(10).source = 1;
% message(10).dest = 3;
% message(10).sourceMasterNumber = 1;
% message(10).destMasterNumber = 1;
% message(10).SwitchInRout = 0;
% message(10).SwitchPort = 0;
% 
% message(14).exec = 0.008;
% message(14).gType = 0;
% message(14).source = 1;
% message(14).dest = 11;
% message(14).sourceMasterNumber = 1;
% message(14).destMasterNumber = 2;
% message(14).SwitchInRout = 1;
% message(14).SwitchPort = 3;
% 
% message(20).exec = 0.010;
% message(20).gType = 1;
% message(20).source = 1;
% message(20).dest = 41;
% message(20).sourceMasterNumber = 1;
% message(20).destMasterNumber = 5;
% message(20).SwitchInRout = [1 2];
% message(20).SwitchPort = [3 3];

message_nbr = syncTotal + asyncTotal;

% to change the network speed to 1Gbps
% for it = 1:message_nbr
%     message(it).exec = message(it).exec / 10;
% end

save('message_struct', 'message');
end