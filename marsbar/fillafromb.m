function c = fillafromb(a, b,fieldns, flags)
% fills structure fields empty or missing in a from those present in b
% FORMAT c = fillafromb(a, b,fieldns)
% a, b are structures
% fieldns (optional) is cell array of field names to fill from in b
% c is returned structure
% Is recursive, will fill struct fields from struct fields
% flags may contain 'f', which Force fills a from b (all non empty
% fields in b overwrite those in a)
% flags may also contain 'r', which Restricts fields to write from b, to
% those that are already present in a
%
% $Id$
  
if nargin < 2
  error('Must specify a and b')
end

% Return for empty passed args
if isempty(a)
  c = b;
  return
end
if isempty(b)
  c = a;
  return
end

if nargin < 3
  fieldns = [];
end
if isempty(fieldns)
  fieldns = fieldnames(b);
end

if nargin < 4
  flags = '';
end
if isempty(flags), flags = ' ';end

if ischar(fieldns), fieldns=cellstr(fieldns);end

% name for initializing structure
funnyname = 'wombat_tongue';

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

% test for funny name
if strcmp(funnyname, cf)
  error(['Whoops - undexpected use of ' funnyname ]);
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
	  fval = fillafromb(fval,bfc);
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
  
return