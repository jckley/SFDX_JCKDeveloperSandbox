const indexGenerator = {
    i : 0,
    getNewIndex() {
        const indexToReturn = this.i;
        this.i = indexToReturn + 1;
        return indexToReturn; 
    }
}

function createWrapperDiv () {
    const mainElement = document.createElement("div");
    mainElement.style.padding = "15px";
    mainElement.style.display = "flex";
    mainElement.style.flexDirection = "row";
    mainElement.style.justifyContent = "center";
    mainElement.style.alignItems = "center";
    
    return mainElement;
}

export { indexGenerator, createWrapperDiv };