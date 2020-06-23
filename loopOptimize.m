clc; clear;

runs = 50;
n = 5;
allSol = [];

for i = 1:runs
    history = Optimize;
    allSol = [allSol; history.popData];
end

writematrix(allSol,'ExcelFile.xlsx','Sheet', 1);