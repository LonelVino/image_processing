% find_match [Function]
%   Find the maximum value of IFFT, and find the corresponding position.
%   NB: the image must be squared !
% ---------------------------------------------
%   Args:
%       C_ifft: IFFT of inter-correlation of 2 images
%       trans_x, trans_y: the transformation distance on X axis and Y axis
%       
%   The position in IFFT represents the transformation of the image
%   For example, if the position of IFFT is (181, 192)
%       It means the transformation vector should be (-19, -8)
%       (Here, '-' means left and upper)

function find_match(C_ifft, trans_x, trans_y)
    %% Part 1  Parameters Initialization and find maximum value and corresponding position of IFFT
    global X; global Y; global N;
    trans_xy = [trans_x, trans_y];

    %% Part 2 Patch them together using recovered shift
    %TODO: now the best value is selected from the pos_xy manually
    %   Find the rule to selecte the best position automatically
    range = 1:N;
    R = zeros(2*N, 2*N);
    R(N + range, N + range) = Y;
    R(trans_xy(1)+N + range, trans_xy(2)+N + range) = X;
    disp(['The position of the maximal value: X = ', num2str(trans_xy(1)+N), '; Y = ', num2str(trans_xy(2)+N)]);
    disp([sprintf('The best displacement (transformation) of image X: (X,Y) = (%d, %d)', trans_xy(1), trans_xy(2))]);
    %% Part 3 Illustrate
    figure
    subplot(2,2,1), imagesc(X)
    subplot(2,2,2), imagesc(Y)
    subplot(2,2,3), imagesc(C_ifft)
    rectangle('Position', [trans_xy(2)+N-1 trans_xy(1)+N-1 2 2]), line([N trans_xy(2)+N], [N trans_xy(1)+N])
    subplot(2,2,4), imagesc(R);
end