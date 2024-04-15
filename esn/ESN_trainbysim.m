classdef ESN_trainbysim < handle
% Echo State Network    
    properties
        Nr
        rho
        tau
        inputScaling
        biasScaling
        lambda
        connectivity
        Win
        Wb
        Wr
        randweight
        initialstate
        
        Wout
        Woutmat
        train_internalState
        train_internalStatedot
        train_reservoirReadout
        train_reservoirReadoutWashed
        train_reservoirTarget
        train_reservoirTargetWashed
        predict_internalState
        predict_internalStatedot
        predict_reservoirReadout
        sizeinput
        nodenuminput
        sizeoutput
        delaylen
        timestep
        ifxnorm
        xnorm
        delaynorm
        normmethod
    end

    methods
        function esn = ESN_trainbysim(Nr, varargin)
            
            esn.Nr = Nr;
            esn.rho = 0.9;
            esn.tau = 10;
            esn.inputScaling = 1;
            esn.biasScaling = 1;
            esn.lambda = 1;
            esn.connectivity = 1;
            esn.sizeinput = 1;
            esn.randweight = true;
            esn.nodenuminput = 1;
            esn.sizeoutput = 1;
            esn.initialstate = zeros(esn.Nr,1);
            esn.delaynorm = nan;
            esn.xnorm = 0;
            esn.train_reservoirReadoutWashed = [];
            esn.Woutmat = [];
            
            numvarargs = length(varargin);
            for i = 1:2:numvarargs
                switch varargin{i}
                    case 'timeConst', esn.tau = varargin{i+1};
                    case 'spectralRadius', esn.rho = varargin{i+1};
                    case 'inputScaling', esn.inputScaling = varargin{i+1};
                    case 'biasScaling', esn.biasScaling = varargin{i+1};
                    case 'regularization', esn.lambda = varargin{i+1};
                    case 'connectivity', esn.connectivity = varargin{i+1};
                    case 'sizeinput', esn.sizeinput = varargin{i+1};
                    case 'nodenuminput', esn.nodenuminput = varargin{i+1};
                    case 'sizeoutput', esn.sizeoutput = varargin{i+1};
                    case 'randweight', esn.randweight = varargin{i+1};
                    case 'delaylen', esn.delaylen = varargin{i+1};
                    case 'timestep', esn.timestep = varargin{i+1};
                    case 'normmethod', esn.normmethod = varargin{i+1};
                    case 'ifxnorm', esn.ifxnorm = varargin{i+1};
                    
                    otherwise, error('the option does not exist');
                end
            end

            esn.train_reservoirTarget = cell(esn.sizeoutput,1);
            esn.train_reservoirTargetWashed = cell(esn.sizeoutput,1);
            for i = 1:esn.sizeoutput
                esn.train_reservoirTargetWashed{i} = [];
            end
            esn.Wout = cell(esn.sizeoutput,1);

            if esn.randweight
                % esn.Win = esn.inputScaling * ((rand(esn.Nr, 1)) * 2 - 1);
                % esn.Win(esn.nodenuminput*esn.sizeinput+1:end) = 0;
                esn.Win = esn.inputScaling * ones(esn.Nr, 1);
                esn.Win(2:2:end) = -esn.Win(2:2:end);
                esn.Wb = esn.biasScaling * (rand(esn.Nr, 1) * 2 - 1);
                esn.Wr = full(sprand(esn.Nr, esn.Nr, esn.connectivity));
                esn.Wr(esn.Wr ~= 0) = esn.Wr(esn.Wr ~= 0) * 2 - 1;
                esn.Wr = esn.Wr * (esn.rho / max(abs(eig(esn.Wr))));
            end

        end

        function [] = clearrecord(esn, varargin)
            numvarargs = length(varargin);
            for i = 1:2:numvarargs
                switch varargin{i}
                    case 'timeConst', esn.tau = varargin{i+1};
                    case 'inputScaling', esn.inputScaling = varargin{i+1};
                    case 'regularization', esn.lambda = varargin{i+1};
                    case 'sizeinput', esn.sizeinput = varargin{i+1};
                    case 'nodenuminput', esn.nodenuminput = varargin{i+1};
                    case 'sizeoutput', esn.sizeoutput = varargin{i+1};
                    case 'randweight', esn.randweight = varargin{i+1};
                    case 'delaylen', esn.delaylen = varargin{i+1};
                    case 'timestep', esn.timestep = varargin{i+1};
                    case 'normmethod', esn.normmethod = varargin{i+1};
                    case 'ifxnorm', esn.ifxnorm = varargin{i+1};
                    
                    otherwise, error('the option does not exist');
                end
            end

            esn.Wout = cell(esn.sizeoutput,1);
            esn.Woutmat = [];

            % esn.Win = esn.inputScaling * ((rand(esn.Nr, 1)) * 2 - 1);
            % esn.Win(esn.nodenuminput*esn.sizeinput+1:end) = 0;

            esn.train_internalState = [];
            esn.train_internalStatedot = [];
            esn.train_reservoirReadout = [];
            esn.train_reservoirReadoutWashed = [];
            esn.train_reservoirTarget = cell(esn.sizeoutput,1);
            esn.train_reservoirTargetWashed = cell(esn.sizeoutput,1);
            for i = 1:esn.sizeoutput
                esn.train_reservoirTargetWashed{i} = [];
            end
            esn.predict_internalState = [];
            esn.predict_internalStatedot = [];
            esn.predict_reservoirReadout = [];
            esn.xnorm = 0;
            esn.delaynorm = nan;
        end

        function [] = traintest(esn, simname)

            [const, x, target, internalState, internalStatedot] = esn.runsim(simname);

            v1 = x(1:end/2,:);
            v2 = x(end/2+1:end,:);
            if esn.ifxnorm
                esn.xnorm = median(abs(v1),2);
                v1 = v1./esn.xnorm;
                v2 = v2./esn.xnorm;
            end
            delaynorms = vecnorm(v2 - v1);
            esn.delaynorm = mean(delaynorms);

        end

        function [] = traindatacollect(esn, simname, washout)

            [const, x, target, internalState, internalStatedot] = esn.runsim(simname);
            
            esn.train_internalState = internalState;
            esn.train_internalStatedot = internalStatedot;

            esn.train_reservoirReadout = [const'; x; esn.train_internalState'];
%             esn.train_reservoirReadout = [const'; esn.train_internalState'];
            esn.train_reservoirReadoutWashed = [esn.train_reservoirReadoutWashed esn.train_reservoirReadout(:,washout+1:end)];
            
            for i = 1:esn.sizeoutput
                esn.train_reservoirTarget{i} = target{i};
                esn.train_reservoirTargetWashed{i} = [esn.train_reservoirTargetWashed{i}; esn.train_reservoirTarget{i}(washout+1:end)];
            end

        end

        function [y, trY] = train(esn)
            y = cell(esn.sizeoutput,1);
            trY = cell(esn.sizeoutput,1);

            for i = 1:esn.sizeoutput
                X = esn.train_reservoirReadoutWashed;
                Y = esn.train_reservoirTargetWashed{i};
    
                esn.Wout{i} = Y'*X'*inv(X*X'+esn.lambda*eye(size(X,1))); 
                esn.Woutmat = [esn.Woutmat; esn.Wout{i}];
    
                y{i} = esn.Wout{i}*esn.train_reservoirReadout;
                y{i} = y{i}';
                trY{i} = esn.train_reservoirTarget{i};
            end

        end

        function [y, prY] = predict(esn, simname)

            y = cell(esn.sizeoutput,1);
            prY = cell(esn.sizeoutput,1);
        
            [const, x, target, internalState, internalStatedot] = esn.runsim(simname);

            esn.predict_internalState = internalState;
            esn.predict_internalStatedot = internalStatedot;

            esn.predict_reservoirReadout = [const'; x; esn.predict_internalState'];
%             esn.predict_reservoirReadout = [const'; esn.predict_internalState'];
            
            for i = 1:esn.sizeoutput
                prY{i} = target{i};
                y{i} = esn.Wout{i}*esn.predict_reservoirReadout;
                y{i} = y{i}';
            end

        end

        function [const, x, target, internalState, internalStatedot] = runsim(esn, simname)
            ti = timer('StartDelay', 60);
            name = split(simname, '.');
            ti.TimerFcn = @(x,y)set_param(name(1), 'SimulationCommand', 'stop');
            start(ti);

            switch simname
                case {"esn_CPtest.slx", "esn_CPtrain.slx"}
                    out = sim(simname);
                    for i = 1:esn.Nr
                        internalState(:,i) = out.yout{2}.Values.S_esn.data(i,1,:);
                        internalStatedot(:,i) = out.yout{2}.Values.Sdot_esn.data(i,1,:);
                    end
                    const = out.yout{2}.Values.const.data(:);
                    x = squeeze(out.yout{2}.Values.xplan.data(:,1,:));
                    target = cell(1);
                    target{1} = out.yout{3}.Values.data;

                case {"esn_CAtest.slx", "esn_CAtrain.slx"}
                    out = sim(simname);
                    for i = 1:esn.Nr
                        internalState(:,i) = out.yout{4}.Values.S_esn.data(i,1,:);
                        internalStatedot(:,i) = out.yout{4}.Values.Sdot_esn.data(i,1,:);
                    end
                    const = out.yout{4}.Values.const.data(:);
                    x = squeeze(out.yout{4}.Values.xplan.data(:,1,:));
                    target = cell(esn.sizeoutput,1);
                    for i = 1:3
                        for j = 1:ceil(esn.sizeoutput/3)
                            target{(j-1)*3+i} = squeeze(out.yout{2}.Values.data(i,j,:));
                        end
                    end

                case "esn.slx"
                    out = sim(simname);
                    for i = 1:esn.Nr
                        internalState(:,i) = out.yout{1}.Values.S_esn.data(i,1,:);
                        internalStatedot(:,i) = out.yout{1}.Values.Sdot_esn.data(i,1,:);
                    end
                    const = out.yout{1}.Values.const.data(:);
                    x = squeeze(out.yout{1}.Values.xplan.data(:,1,:))';
                    target = cell(1);
                    target{1} = squeeze(out.yout{1}.Values.target.data);

                otherwise, error('the simulation does not exist');
            end
            stop(ti);
            delete(ti);

        end

    end
end