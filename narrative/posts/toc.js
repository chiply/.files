// Followable, scrollable table of contents
window.addEventListener("DOMContentLoaded", () => {
    const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
            if (entry.target.getAttribute("id") === "text-tldr") {
                return;
            }
            // ignore if entry is child of #content-clone
            if (entry.target.closest("#content-clone")) {
                return;
            }
            let id = "";
            // empty headings
            if (entry.target.tagName.match(/^H[2-6]$/)) {
                id = entry.target.getAttribute("id") || "";

                const tocLink = document.querySelector(
                    `#text-table-of-contents a[href="#${id}"]`,
                );
                const nextSibling = entry.target.nextElementSibling;
                if (tocLink && !nextSibling) {
                    const action =
                        entry.intersectionRatio > 0 ? "add" : "remove";
                    tocLink.parentElement.classList[action]("active");

                    // Scroll active link into view
                    if (entry.intersectionRatio > 0) {
                        tocLink.scrollIntoView({
                            behavior: "smooth",
                            block: "nearest",
                        });
                    }
                }
            }

            // Check if target is an outline-text div
            if (
                entry.target.tagName === "DIV" &&
                entry.target.className.match(/outline-text-[2-6]/)
            ) {
                id =
                    entry.target.previousElementSibling?.getAttribute("id") ||
                    "";

                const tocLink = document.querySelector(
                    `#text-table-of-contents a[href="#${id}"]`,
                );
                if (tocLink) {
                    const action =
                        entry.intersectionRatio > 0 ? "add" : "remove";
                    tocLink.parentElement.classList[action]("active");

                    // Scroll active link into view
                    if (entry.intersectionRatio > 0) {
                        tocLink.scrollIntoView({
                            behavior: "smooth",
                            block: "nearest",
                        });
                    }
                }
            }
        });
    });

    // Collect all headings and outline divs
    const headings = [
        ...document.querySelectorAll("h2[id], h3[id], h4[id], h5[id], h6[id]"),
        ...document.querySelectorAll(
            "div.outline-text-2, div.outline-text-3, div.outline-text-4, div.outline-text-5, div.outline-text-6",
        ),
    ];

    headings.forEach((heading) => observer.observe(heading));
});

// Clickable ToC
document.addEventListener("DOMContentLoaded", function () {
    const tocLinks = document.querySelectorAll(
        "#text-table-of-contents a[href^='#']",
    );

    tocLinks.forEach((link) => {
        link.addEventListener("click", function (event) {
            event.preventDefault();
            const targetId = this.getAttribute("href").substring(1);
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
