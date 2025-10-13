// Keys
document.addEventListener("keydown", function (event) {
    // Check for 'c' key (can modify as needed)
    if (event.key === "c" && !event.ctrlKey && !event.metaKey) {
        console.log("c key pressed");
    }
});
