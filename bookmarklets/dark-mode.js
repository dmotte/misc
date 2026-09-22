// Bookmarklet to flip the page to an artificial dark mode. It will reset if
// you refresh the page

// Tested with Google Chrome version 153.0.8010.36 (Official Build) (x86_64)

// javascript:(function(){

"use strict";

function handleBookmarkletError(error) {
  console.error(error);
  alert(`ERROR: ${error}`);
}

try {
  const style = document.createElement("style");
  style.textContent =
    "html { filter: invert(1) hue-rotate(180deg) !important; }";
  document.head.appendChild(style);
} catch (error) {
  handleBookmarkletError(error);
}

// })();
