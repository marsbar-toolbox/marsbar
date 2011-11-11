function out_o = as_summary_only(o)
% returns object with region data removed
%
% Useful to save memory
if ~is_summarized(o)
    out_o = resummarize(o);
else
    out_o = o;
end
st = y_struct(o);
if ~isfield(st, 'regions')
    return
end
for rno = 1:length(st.regions)
    st.regions{rno} = mars_struct('strip', st.regions{rno}, ...
        {'Y', 'weights','vXYZ'});
end
out_o = y_struct(out_o, st);
return
