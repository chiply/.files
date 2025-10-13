// Followable, scrollable footnotes
window.addEventListener("DOMContentLoaded", () => {
    const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
            // ignore if entry is child of #content-clone
            if (entry.target.closest("#content-clone")) {
                return;
            }
            // Check if target is an outline-text div
            id = entry.target.getAttribute("id");

            const fnLink = document
                .querySelector(`#footnotes sup a[href="#${id}"]`)
                .closest("sup")
                .nextElementSibling.querySelector("p");
            const fnLink1 = document.querySelector(
                `#footnotes sup a[href="#${id}"]`,
            );
            if (fnLink) {
                const action = entry.intersectionRatio > 0 ? "add" : "remove";
                fnLink.classList[action]("active");
                fnLink1.classList[action]("active");

                // Scroll active link into view
                if (entry.intersectionRatio > 0) {
                    fnLink.scrollIntoView({
                        behavior: "smooth",
                        block: "nearest",
                    });
                }
            }
        });
    });

    // Collect all headings and outline divs
    const headings = [...document.querySelectorAll("sup a.footref")];

    headings.forEach((heading) => observer.observe(heading));
});

// Clickable Footnotes
document.addEventListener("DOMContentLoaded", function () {
    const tocLinks = document.querySelectorAll("#footnotes a[href^='#']");

    tocLinks.forEach((link) => {
        link.addEventListener("click", function (event) {
            event.preventDefault();
            targetId = this.getAttribute("href").substring(1);
            targetId = CSS.escape(targetId);
            const elements = document.querySelectorAll(`#${targetId}`);
            const targetElement = Array.from(elements).filter(
                (el) => !el.closest("#content-clone"),
            )[0];
            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: "smooth",
                    block: "start",
                });
            }
        });
    });
});


