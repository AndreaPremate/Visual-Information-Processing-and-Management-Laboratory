function idx = find_interval(bounds, vals)
% Given the two sorted arrays bounds and vals, the function 
% idx = FIND_INTERVAL(bounds, vals) identifies for each vals(i) the index 
% idx(i) s.t. bounds(idx(i)) <= vals(i) < bounds(idx(i) + 1).

m = 0;
bounds = [bounds(:); inf];
idx = zeros(numel(vals), 1);

for i = 1:numel(vals)
    while bounds(m+1) <= vals(i)
        m = m + 1;
    end
    idx(i) = m;
end
end