// Example bookmarklet to remove some elements from web pages

// Tested on 2025-07-28 with Google Chrome version 138.0.7204.157
// (Official Build) (64-bit)

// javascript:(function(){

const rules = {
  "stackoverflow.com": ["div#hot-network-questions"],
  "youtube.com": [
    "div.style-scope.ytd-watch-next-secondary-results-renderer",
    "div.html5-endscreen.ytp-player-content.videowall-endscreen",
  ],
};

const hostname = window.location.hostname;

for (const [hn, selectors] of Object.entries(rules)) {
  if (hostname.endsWith(hn))
    for (const s of selectors)
      document.querySelectorAll(s).forEach((elem) => elem.remove());
}

// })();
