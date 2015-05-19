function S = catstruct(S1, S2)
%CATSTRUCT very similar to catstruct from matlab exchange
% The matlabexchange catstruct deletes the children of the root fields if
% they exist in S2
%
% S2 wins

%TODO: to be tested if you change a cell
% 11/12/21 created

%-----------------%
%-input check
S = [];
%-----------------%

%-----------------%
%-find common and unique fields
fn1 = fieldnames(S1);
fn2 = fieldnames(S2);

f = intersect(fn1, fn2); % common
f1 = setdiff(fn1, fn2); % only in S1
f2 = setdiff(fn2, fn1); % only in S2
%-----------------%

%-----------------%
%add unique f1 and f2
for i = 1:numel(f1)
  S.( f1{i} ) = S1.( f1{i} );
end

for i = 1:numel(f2)
  S.( f2{i} ) = S2.( f2{i} );
end
%-----------------%

%-----------------%
%-go down
for i = 1:numel(f)
  if isstruct(S1.( f{i} )) && isstruct(S2.( f{i} ))
    S.( f{i} ) = catstruct(S1.( f{i} ), S2.( f{i} ));
  else
    S.( f{i} ) = S2.( f{i} ); % S2 wins
  end
end
%-----------------%
