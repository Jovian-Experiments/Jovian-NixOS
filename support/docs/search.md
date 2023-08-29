Search
======

<noscript>

> [!WARNING]
> This search engine requires use of JavaScript.

</noscript>

<div id="search"></div>

<script>
window.addEventListener('DOMContentLoaded', (event) => {
	pagefind = new PagefindUI({
		element: "#search",
		baseUrl: document.baseURI.replace(/search.html/, ""),
		showImages: false,
		translations: {
			placeholder: "",
		},
	});
    // Workaround for the lack of an autofocus option.
    window.setTimeout(function () {
        document.querySelector(".pagefind-ui__search-input").focus();
    }, 1);
});
</script>

<script src="!pagefind/pagefind-ui.js" type="text/javascript"></script>
