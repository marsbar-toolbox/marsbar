function varargout = mars_struct(action, varargin)
% multifunction function for manipulating structures
%
% FORMAT c = mars_struct('fillafromb', a, b, fieldns, flags)
% fills structure fields empty or missing in a from those present in b
% a, b are structures
% fieldns (optional) is cell array of field names to fill from in b
% c is returned structure
% Is recursive, will fill struct fields from struct fields
% flags may contain 'f', which Force fills a from b (all non empty
% fields in b overwrite those in a)
% flags may also contain 'r', which Restricts fields to write from b, to
% those that are already present in a
% 
% FORMAT [c, d] = mars_struct('split', a, b)
% split structure a into two, according to fields in b
% so that c becomes a structure which contains the fields
% in a, that are also present in b, and d contains the fields
% in a that are not present in b.  b can be a structure
% or a cell array of fieldnames
%
% FORMAT c = mars_struct('merge', a, b)
% merges structure a and b (fields present in b added to a)
%
% FORMAT [c,d] = mars_struct('fillsplit', a, b)
% fills fields in a from those present in b, returns a, remaining b
% a, b are structures
% c, d are returned structure
%
% FORMAT [c,d] = mars_struct('fillmerge', a, b)
% performs 'fillsplit' on a and b, then merges a and b
%
% $Id$

if nargin < 1
  error('Action needed');
end
if nargin < 3
  error('Must specify a and b')
end
[a b] = deal(varargin{1:2});

switch lower(action)  
 case 'fillafromb'
  % Return for empty passed args
  if isempty(a), varargout = {b}; return, end
  if isempty(b), varargout = {a}; return, end
  
  if nargin < 4, fieldns = []; else fieldns = varargin{3}; end
  if isempty(fieldns), fieldns = fieldnames(b); end
  
  if nargin < 4, flags = ''; else flags = varargin{4}; end
  if isempty(flags), flags = ' ';end
  
  if ischar(fieldns), fieldns=cellstr(fieldns);end
  
  af = fieldnames(a)';
  bf = fieldns';
  
  % classify fields 0 = a~b, 1 = a&b, 2=b~a
  cf = af;
  ftype = ismember(af, bf);
  if ~any(flags == 'r')
    b_not_a = find(~ismember(bf, af));
    cf =  {cf{:} bf{b_not_a}}; 
    ftype = [ftype ones(1, length(b_not_a))*2];
  end
  
  % cope with arrays of structures
  alen = prod(size(a));
  blen = prod(size(b));
  maxlen = max(alen, blen);
  
  for si=1:maxlen
    ctmp = [];
    for i=1:length(cf)
      fn = cf{i};
      switch ftype(i)
       case 0 % a~b
	fval = getfield(a(si), fn);
       case 1 % shared field
	bfc = getfield(b(si), fn);
	if isempty(getfield(a(si), fn)) | ... % a field is empty
	      (any(flags == 'f' & ~isempty(bfc)))% or force fill
	  fval = bfc;
	else % field not empty, could be struct -> recurse
	  fval = getfield(a(si),fn);
	  if isstruct(fval) & isstruct(bfc)
	    fval = mars_struct('fillafromb',fval,bfc);
	  end
	end
       case 2 % b~a
	fval = getfield(b(si), fn);
       case 3 % no field information, see below
	fval = [];
      end
      if isempty(ctmp)
	ctmp = struct(fn, fval);
      else
	ctmp = setfield(ctmp, fn, fval);
      end
    end
    c(si) = ctmp;
    
    if si == blen % reached end of bs, rest of b~a fields are empty
      ftype = (ftype == 2) * 3;
    elseif si == alen % end of a's rest of a~b fields are empty
      ftype = (ftype == 0) * 2 + 1;
    end
    
  end
  varargout = {c};
  
 case 'split'
  stout = a;
  stin = [];
  
  % Return for empty second arg
  if isempty(b), varargout = {stin, stout}; return, end

  if ischar(b), b = {b};end
  if isstruct(b), b = fieldnames(b);end
  
  for bf = b(:)'
    if isfield(a, bf{1})
      stin = setfield(stin, bf{1}, getfield(a, bf{1}));
      stout = rmfield(stout, bf{1});
    end
  end  
  varargout = {stin, stout};
  
 case 'merge'
  c = a;
  if isempty(b), varargout = {c}; return, end
  
  for bf = fieldnames(b)';
    if ~isfield(a, bf{1})
      c = setfield(c, bf{1}, getfield(b, bf{1}));
    end
  end
  varargout = {c};
  
 case 'fillsplit'
   c = a; d = b;
   if isempty(b), varargout = {c,d}; return,  end
   
   cf = fieldnames(c);
   for i=1:length(cf)
     if isfield(d, cf{i})
       dfc = getfield(d,cf{i});
       if ~isempty(dfc) 
	 c = setfield(c, cf{i}, dfc);
       end
       d = rmfield(d, cf{i});
     end
   end
   varargout = {c,d};
   
 case 'fillmerge'
  [a b] = mars_struct('fillsplit', a, b);
  varargout = {mars_struct('merge', a, b)};
  
 case 'otherwise'
  error(['Suspicious action was ' action]);
end % switch