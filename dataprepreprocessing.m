%% Import data

% data = ft_read_data('sub-PD1755_ses-02_task-rest_run-01_meg.ds/sub-PD1755_ses-02_task-rest_run-01_meg.meg4');
% % % unitati in femto-Tesla
addpath D:\Facultate\Licenta\fieldtrip-20231015\fieldtrip-20231015
ft_defaults
pd1755 = [];
pd1755.dataset     = 'sub-pd1755_ses-02_task-rest_run-01_meg.ds';
data_megpd1755 = ft_preprocessing(pd1755);
% 
sensorPositions = data_megpd1755.grad.chanpos(1:273,:);
sensorLabels = data_megpd1755.grad.label(1:273,:);
currentValues = data_megpd1755.trial{1,1};

%% Create figure

fig = figure;
ax = axes('Parent', fig);

% Define the colormap and color axis limits
% custom_colormap = [
%     linspace(1, 1, 254); % Red component (constant at 1, i.e., red)
%     linspace(1, 0.3, 254); % Green component (decreasing from 1 to 0.5, yellow to red)
%     linspace(0, 0, 254);  % Blue component (constant at 0, i.e., no blue)
% ];
colormap('gray');
clim([min(min(currentValues)), max(max(currentValues))]);

% Set axis labels
xlabel('x');
ylabel('y');
zlabel('z');

% Number of time points
numTimePoints = 24000;

% Time delay between frames (adjust as needed, in seconds)
frameDelay = 0.1;

for currentFrame = 1:numTimePoints
    % Extract current values for the frame
    currentValues = data_megpd1755.trial{1,1}(28:300, currentFrame);
    currentValues = log10(currentValues);
    currentValues = abs(currentValues);
    
    % Update the scatter plot for the current frame
    scatter(ax, sensorPositions(:, 1), sensorPositions(:, 2), 10, (currentValues-9)/4*200, 'filled');
    
    % Set the view angle for the top-down view (azimuth = 0, elevation = 90)
    view(0, 90);
    
    colorbar;

    % Set the title to indicate the current frame
    title(sprintf('Frame %d of %d', currentFrame, numTimePoints));
    
    drawnow; % Refresh the plot
    
    pause(frameDelay); % Introduce a pause
end
