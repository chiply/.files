// progress bar
// script.js
document.addEventListener("DOMContentLoaded", () => {
    const progressBar = document.getElementById("progressBar");

    const updateProgressBar = () => {
        const scrollTop =
            document.documentElement.scrollTop || document.body.scrollTop;
        const scrollHeight =
            document.documentElement.scrollHeight -
            document.documentElement.clientHeight;
        const scrollPercentage = (scrollTop / scrollHeight) * 100;

        progressBar.style.width = `${scrollPercentage}%`;
    };

    // Initial call to set progress bar on page load
    updateProgressBar();

    // Add scroll event listener to update the progress bar
    window.addEventListener("scroll", updateProgressBar);
});
