// Example bookmarklet to remove some elements from web pages

// Tested on 2025-07-28 with Google Chrome version 138.0.7204.157
// (Official Build) (64-bit)

// javascript:(function(){

function removeByQuery(selectors) {
  return document.querySelectorAll(selectors).forEach((x) => x.remove());
}

if (window.location.hostname.endsWith("youtube.com")) {
  removeByQuery("div.style-scope.ytd-watch-next-secondary-results-renderer");
  removeByQuery("a.ytp-suggestion-set");
}

if (window.location.hostname.endsWith("stackoverflow.com")) {
  removeByQuery("div#hot-network-questions");
}

// })();
