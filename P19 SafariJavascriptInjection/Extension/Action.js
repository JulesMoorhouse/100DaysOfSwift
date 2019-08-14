var Action = function() { }

Action.prototype = {
    
run: function(paramaters) {
    paramaters.completionFunction({"URL": document.URL, "title": document.title});
},
    
finalize: function(paramaters) {
    
}
    
};

var ExtensionPreprocessingJS = new Action
