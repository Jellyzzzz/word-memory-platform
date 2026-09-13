(function () {
    "use strict";

    var tabs = Array.prototype.slice.call(document.querySelectorAll("[data-tab-target]"));
    var panels = Array.prototype.slice.call(document.querySelectorAll("[data-tab-panel]"));

    if (tabs.length > 0 && panels.length > 0) {
        document.body.classList.add("js-ready");

        tabs.forEach(function (tab) {
            tab.addEventListener("click", function () {
                var target = tab.getAttribute("data-tab-target");

                tabs.forEach(function (item) {
                    var active = item === tab;
                    item.classList.toggle("is-active", active);
                    item.setAttribute("aria-selected", String(active));
                });

                panels.forEach(function (panel) {
                    var active = panel.getAttribute("data-tab-panel") === target;
                    panel.classList.toggle("is-active", active);
                    panel.hidden = !active;
                });
            });
        });
    }
}());
