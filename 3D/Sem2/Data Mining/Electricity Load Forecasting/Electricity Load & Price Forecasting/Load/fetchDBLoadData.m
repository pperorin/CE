function data = fetchDBLoadData(startDate, endDate)

% Set preferences with setdbprefs.
s.DataReturnFormat = 'structure';
s.ErrorHandling = 'store';
s.NullNumberRead = 'NaN';
s.NullNumberWrite = 'NaN';
s.NullStringRead = 'null';
s.NullStringWrite = 'null';
s.JDBCDataSourceFile = '';
s.UseRegistryForSources = 'yes';
s.TempDirForRegistryOutput = 'C:\Temp';
s.DefaultRowPreFetch = '10000';
setdbprefs(s)

% Make connection to database.  Note that the password has been omitted.
% Using ODBC driver.
conn = database('EnergyData','','password');

% Read data from database.
if nargin == 2
    startDate = datestr(startDate, 'yyyy-mm-dd');
    endDate = datestr(endDate, 'yyyy-mm-dd');
    e = exec(conn,['SELECT ALL Date,Hour,DryBulb,DewPnt,SYSLoad FROM NEData WHERE Date BETWEEN #' startDate '# AND #' endDate '#  ']);
else
    e = exec(conn,'SELECT ALL Date,Hour,DryBulb,DewPnt,SYSLoad FROM NEData');
end
e = fetch(e);
close(e)

% Assign data to output variable.
if isscalar(e.Data) && iscellstr(e.Data) && strcmp(e.Data{1}, 'No Data')
    warning('fetchDBLoadData:NoData','No data retrieved');
    data = struct('Date',{''},'Hour',[],'DryBulb',[],'DewPnt',[],'SYSLoad',[],'NumDate',[]);
else
    data = e.Data;
    data.NumDate = datenum(data.Date, 'yyyy-mm-dd') + (data.Hour-1)/24;
end

% Close database connection.
close(conn)
