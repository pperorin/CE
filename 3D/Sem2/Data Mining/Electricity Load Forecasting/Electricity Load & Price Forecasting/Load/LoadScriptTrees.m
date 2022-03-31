%% Load Forecasting using Bagged Regression Trees
% This example demonstrates an alternate model for building relationships
% between historical weather and load data to build and test a short term
% load forecasting. The model used is a set of aggregated Regression Trees.

%% Import Data
% The data set used is a table of historical hourly loads and temperature
% observations from the New England ISO for the years 2004 to 2008. The
% weather information includes the dry bulb temperature and the dew point.

load Data\DBLoadData.mat
addpath ..\Util

%% Import list of holidays
% A list of New England holidays that span the historical date range is
% imported from an Excel spreadsheet

[num, text] = xlsread('..\Data\Holidays.xls');
holidays = text(2:end,1);


%% Generate Predictor Matrix
% The function *genPredictors* generates the predictor variables used as
% inputs for the model. For short-term forecasting these include
% 
% * Dry bulb temperature
% * Dew point
% * Hour of day
% * Day of the week
% * A flag indicating if it is a holiday/weekend
% * Previous day's average load
% * Load from the same hour the previous day
% * Load from the same hour and same day from the previous week
%
% If the goal is medium-term or long-term load forecasting, only the inputs
% hour of day, day of week, time of year and holidays can be used
% deterministically. The weather/load information would need to be
% specified as an average or a distribution

% Select forecast horizon
term = 'short';

[X, dates, labels] = genPredictors(data, term, holidays);

%% Split the dataset to create a Training and Test set
% The dataset is divided into two sets, a _training_ set which includes 
% data from 2004 to 2007 and a _test_ set with data from 2008. The training
% set is used for building the model (estimating its parameters). The test
% set is used only for forecasting to test the performance of the model on 
% out-of-sample data. 

% Create training set
trainInd = data.NumDate < datenum('2008-01-01');
trainX = X(trainInd,:);
trainY = data.SYSLoad(trainInd);

% Create test set and save for later
testInd = data.NumDate >= datenum('2008-01-01');
testX = X(testInd,:);
testY = data.SYSLoad(testInd);
testDates = dates(testInd);

save Data\testSet testDates testX testY
clear X data trainInd testInd term holidays dates ans

%% Build the Load Forecasting Model
% The next few cells builds a Bagged Regression Trees model for day-ahead
% load forecasting given the training data. This model is then used on the
% test data to validate its accuracy. 

%% Build the Bootstrap Aggregated Regression Trees 
% The function TreeBagger is used to build the model, ie. a set of
% regression trees each with a different set of rules for performing the
% non-linear regression. We build an aggregate of 20 such trees, with a
% minimum leaf size of 20. The larger the leaf size the smaller the tree.
% This provides a control for overfitting and performance.

model = TreeBagger(20, trainX, trainY, 'method', 'regression', 'minleaf', 20) 


simpleTree = prune(model.Trees{1}, 500);
simpleTree = prune(simpleTree, simpleTree.prunelist(1)-10);
view(simpleTree, 'names', labels);

%% Save Trained Model
% We can compact the model (to remove any stored training data) and save
% for later reuse

model = compact(model);
save Models\TreeModel model


%% Forecast Using Tree Model
% Once the model is built, perform a forecast on the independent test set. 

load Data\testSet
forecastLoad = predict(model, testX);

%% Compare Forecast Load and Actual Load
% Create a plot to compare the actual load and the predicted load as well
% as compute the forecast error. In addition to the visualization, quantify
% the performance of the forecaster using metrics such as mean absolute
% error (MAE), mean absolute percent error (MAPE) and daily peak forecast
% error.

err = testY-forecastLoad;
fitPlot(testDates, [testY forecastLoad], err);

errpct = abs(err)./testY*100;

fL = reshape(forecastLoad, 24, length(forecastLoad)/24)';
tY = reshape(testY, 24, length(testY)/24)';
peakerrpct = abs(max(tY,[],2) - max(fL,[],2))./max(tY,[],2) * 100;

MAE = mean(abs(err));
MAPE = mean(errpct(~isinf(errpct)));

fprintf('Mean Absolute Percent Error (MAPE): %0.2f%% \nMean Absolute Error (MAE): %0.2f MWh\nDaily Peak MAPE: %0.2f%%\n',...
    MAPE, MAE, mean(peakerrpct))


%% Examine Distribution of Errors
% In addition to reporting scalar error metrics such as MAE and MAPE, the
% plot of the distribution of the error and absolute error can help build
% intuition around the performance of the forecaster

figure;
subplot(3,1,1); hist(err,100); title('Error distribution');
subplot(3,1,2); hist(abs(err),100); title('Absolute error distribution');
line([MAE MAE], ylim); legend('Errors', 'MAE');
subplot(3,1,3); hist(errpct,100); title('Absolute percent error distribution');
line([MAPE MAPE], ylim); legend('Errors', 'MAPE');

%% Group Analysis of Errors
% To get further insight into the performance of the forecaster, we can
% visualize the percent forecast errors by hour of day, day of week and
% month of the year

[yr, mo, da, hr] = datevec(testDates);

% By Hour
clf;
boxplot(errpct, hr+1);
xlabel('Hour'); ylabel('Percent Error Statistics');
title('Breakdown of forecast error statistics by hour');

% By Weekday
figure
boxplot(errpct, weekday(floor(testDates)), 'labels', {'Sun','Mon','Tue','Wed','Thu','Fri','Sat'});
ylabel('Percent Error Statistics');
title('Breakdown of forecast error statistics by weekday');

% By Month
figure
boxplot(errpct, datestr(testDates,'mmm'));
ylabel('Percent Error Statistics');
title('Breakdown of forecast error statistics by month');


%% Generate Weekly Charts
% Create a comparison of forecast and actual load for every week in the
% test set.
generateCharts = true;
if generateCharts
    step = 168*2;
    for i = 0:step:length(testDates)-step
        clf;
        fitPlot(testDates(i+1:i+step), [testY(i+1:i+step) forecastLoad(i+1:i+step)], err(i+1:i+step));
        title(sprintf('MAPE: %0.2f%%', mean(errpct(i+1:i+step))));
        snapnow
        
    end
end
    
%#ok<*NOPTS>
%#ok<*CTCH>