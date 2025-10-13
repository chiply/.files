// Foldable divs
document.addEventListener("DOMContentLoaded", function () {
    const foldableDivs = document.querySelectorAll('[class^="outline-"]');

    foldableDivs.forEach((div) => {
        div.addEventListener("click", function () {
            event.stopPropagation(); // Prevents the event from bubbling up to parent divs
            this.classList.toggle("folded");
        });
    });
});
