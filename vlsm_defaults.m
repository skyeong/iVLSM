function vlsm_defaults(handles)
global VLSM

VLSM.T1prefix = get(handles.edit_T1prefix,'String');
VLSM.ROIprefix = get(handles.edit_ROIprefix,'String');
VLSM.T1folder = get(handles.edit_T1folder,'String');
VLSM.ROIfolder = get(handles.edit_ROIfolder,'String');
VLSM.modality = '';
VLSM.doSeg = 0;

% Initial values for correlation analysis
VLSM.inputFile = [];
VLSM.nMinSubj = 5;
VLSM.nCovariates = 0;
VLSM.covariate.values = [];
VLSM.covariate.names = [];

% Initialize values for statistical methods
VLSM.statMethods = 'mw';

% Group variable
VLSM.groupVar = 'group';
VLSM.statMethods = 'overlap';
set(handles.edit_groupVar,'String',VLSM.groupVar);
