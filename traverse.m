function [output, isvis] = traverse(mat, i, j, isvis)

mat(i, j) = 0;
isvis(i, j) = 0;
neighbor = mat(i - 1: i + 1, j - 1: j + 1);

while(sum(sum(neighbor)))
    [x, y] = find(neighbor ~= 0, 1);
    neighbor(x, y) = 0;
    mat(i - 2 + x, j - 2 + y) = 0;
    [mat, isvis] = traverse(mat, i - 2 + x, j - 2 + y, isvis);
end
output = mat;

end

