function [rate,X_,Y_,tY_] = descriptorMatchforz_relaxed(X,Y,pixshift,iadj,params)
%DESCRIPTORMATCH Summary of this function goes here
%
% [OUTPUTARGS] = DESCRIPTORMATCH(INPUTARGS) Explain usage here
%
% Inputs:
%
% Outputs:
%
% Examples:
%
% Provide sample usage code here
%
% See also: List related files here

% $Author: base $	$Date: 2016/09/23 14:09:29 $	$Revision: 0.1 $
% Copyright: HHMI 2016
tY_ = [];
opt = params.opt;
model = params.model;
optimopts = params.optimopts;
projectionThr = params.projectionThr;
debug = params.viz;
%%
% initial match based on point drift
[Transform, C]=cpd_register(X,Y,opt);
%% check if match is found
pD = pdist2(X,Transform.Y);
[aa1,bb1]=min(pD,[],1);
[aa2,bb2]=min(pD,[],2);
keeptheseY = find([1:length(bb1)]'==bb2(bb1));
keeptheseX = bb1(keeptheseY)';

disttrim = aa1(keeptheseY)'<projectionThr;
X_ = X(keeptheseX(disttrim),:);
Y_ = Y(keeptheseY(disttrim),:);
tY_= Transform.Y(keeptheseY(disttrim),:);
rate = sum(disttrim)/length(disttrim);
% [pixshift rate]
if rate < .5 % dont need to continue
    [X_,Y_,out] = deal(0);
    return
end
%%
% Y_(:,iadj) = Y_(:,iadj)- pixshift(iadj);% move it back to original location after CDP
Y_ = Y_- ones(size(Y_,1),1)*pixshift;% move it back to original location after CDP
end

