# Flutter run script with Samsung system message filtering (PowerShell)
# Filters out MSHandlerLifeCycle and isMultiSplitHandlerRequested spam

flutter run 2>&1 | Where-Object { 
    $_ -notmatch "MSHandlerLifeCycle" -and 
    $_ -notmatch "isMultiSplitHandlerRequested" 
}

